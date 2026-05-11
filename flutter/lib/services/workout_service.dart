import 'dart:convert';

import 'package:ai_fitness_coach/core/errors/error_handler.dart';
import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/models/exercise_model.dart';
import 'package:ai_fitness_coach/models/workout_model.dart';
import 'package:ai_fitness_coach/models/workout_progress_model.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';

class WorkoutService {
  WorkoutService(this.authService);

  final AuthService authService;

  dynamic _decodeIfString(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }

    return data;
  }

  Map<String, dynamic> _toMap(dynamic data) {
    final decoded = _decodeIfString(data);

    if (decoded == null) return {};

    if (decoded is Map<String, dynamic>) return decoded;

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return {};
  }

  List<dynamic> _toList(dynamic data) {
    final decoded = _decodeIfString(data);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);

      final possibleLists = [
        map['data'],
        map['result'],
        map['value'],
        map['items'],
        map['plans'],
        map['exercises'],
        map['workouts'],
      ];

      for (final item in possibleLists) {
        final list = _toList(item);

        if (list.isNotEmpty) {
          return list;
        }
      }
    }

    return [];
  }

  Map<String, dynamic> _extractMapData(Map<String, dynamic> data) {
    final possibleContainers = [
      data['data'],
      data['result'],
      data['value'],
      data['progress'],
      data['workoutProgress'],
    ];

    for (final item in possibleContainers) {
      final mapped = _toMap(item);

      if (mapped.isNotEmpty) {
        return mapped;
      }
    }

    return data;
  }

  // ====================== Get Exercises ======================

  Future<Map<String, List<ExerciseModel>>> getExercisesByMuscle() async {
    try {
      final response = await authService.dio.get<dynamic>(
        '/api/Workout/exercises',
      );

      final data = _toMap(response.data);

      if (data.isEmpty) {
        return {};
      }

      final Map<String, List<ExerciseModel>> result = {};

      for (final entry in data.entries) {
        final muscleName = entry.key.toLowerCase().trim();
        final exercises = _toList(entry.value);

        if (exercises.isEmpty) continue;

        final exerciseList = <ExerciseModel>[];

        for (final exercise in exercises) {
          final exerciseMap = _toMap(exercise);

          if (exerciseMap.isEmpty) continue;

          try {
            exerciseList.add(
              ExerciseModel.fromJson(exerciseMap),
            );
          } catch (_) {
            continue;
          }
        }

        if (exerciseList.isNotEmpty) {
          result[muscleName] = exerciseList;
        }
      }

      return result;
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Failed to load exercises',
      );
    }
  }

  // ====================== Create Plan ======================

  Future<void> createPlan({
    required String name,
    required List<String> exerciseIds,
  }) async {
    try {
      final ids = exerciseIds
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .where((e) => e > 0)
          .toList();

      if (name.trim().isEmpty) {
        throw Failure('Plan name is required');
      }

      if (ids.isEmpty) {
        throw Failure('Please select at least one exercise');
      }

      await authService.dio.post<dynamic>(
        '/api/Workout/plan',
        data: {
          'name': name.trim(),
          'exerciseIds': ids,
        },
      );
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Failed to create workout plan',
      );
    }
  }

  // ====================== Get Plans ======================

  Future<List<WorkoutModel>> getPlans() async {
    try {
      final response = await authService.dio.get<dynamic>(
        '/api/Workout/plans',
      );

      final data = _toList(response.data);

      if (data.isEmpty) {
        return [];
      }

      final plans = <WorkoutModel>[];

      for (final item in data) {
        final planMap = _toMap(item);

        if (planMap.isEmpty) continue;

        try {
          plans.add(
            WorkoutModel.fromJson(planMap),
          );
        } catch (_) {
          continue;
        }
      }

      return plans;
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Failed to load workout plans',
      );
    }
  }

  // ====================== Create Session ======================

  Future<void> createSession({
    required String workoutPlanId,
    required List<ExerciseModel> exercises,
  }) async {
    try {
      final planId = int.tryParse(workoutPlanId);

      if (planId == null || planId <= 0) {
        throw Failure('Invalid workout plan id');
      }

      if (exercises.isEmpty) {
        throw Failure('Please add at least one exercise');
      }

      final exercisesData = exercises.map((exercise) {
        final exerciseId = int.tryParse(exercise.exerciseId) ?? 0;

        final setsData = exercise.sets.map((set) {
          return {
            'weight': set.weight,
            'reps': set.reps,
            'isCompleted': set.isCompleted,
          };
        }).toList();

        return {
          'exerciseId': exerciseId,
          'sets': setsData,
        };
      }).where((exercise) {
        final exerciseId = exercise['exerciseId'];

        return exerciseId is int && exerciseId > 0;
      }).toList();

      if (exercisesData.isEmpty) {
        throw Failure('No valid exercises found');
      }

      await authService.dio.post<dynamic>(
        '/api/Workout/session',
        data: {
          'workoutPlanId': planId,
          'exercises': exercisesData,
        },
      );
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Failed to create workout session',
      );
    }
  }

  // ====================== Delete Plan ======================

  Future<void> deletePlan(String planId) async {
    try {
      final id = int.tryParse(planId);

      if (id == null || id <= 0) {
        throw Failure('Invalid plan id');
      }

      await authService.dio.delete<dynamic>(
        '/api/Workout/plan/$id',
      );
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Failed to delete workout plan',
      );
    }
  }

  // ====================== Get Progress ======================

  Future<WorkoutProgressModel> getProgress() async {
    try {
      final response = await authService.dio.get<dynamic>(
        '/api/Workout/progress',
      );

      final responseData = _toMap(response.data);

      if (responseData.isEmpty) {
        throw Failure('Workout progress data is empty');
      }

      final progressData = _extractMapData(responseData);

      if (progressData.isEmpty) {
        throw Failure('Workout progress data is empty');
      }

      return WorkoutProgressModel.fromJson(progressData);
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Failed to load workout progress',
      );
    }
  }
}