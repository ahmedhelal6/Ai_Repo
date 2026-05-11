import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/core/service_locator.dart';
import 'package:ai_fitness_coach/models/exercise_model.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/services/favorite_service.dart';
import 'package:ai_fitness_coach/services/workout_service.dart';

class WorkoutController {
  final AuthService authService = ServiceLocator.authService;

  late final WorkoutService workoutService = WorkoutService(authService);

  final FavoriteService favoriteService = FavoriteService();

  Future<Map<String, List<ExerciseModel>>> loadExercisesByMuscle() async {
    return workoutService.getExercisesByMuscle();
  }

  Future<Set<String>> loadFavorites() async {
    return favoriteService.getFavoriteIds();
  }

  Future<Set<String>> toggleFavorite(String exerciseId) async {
    return favoriteService.toggleFavorite(exerciseId);
  }

  Future<void> saveWorkout({
    required String name,
    required List<ExerciseModel> selectedExercises,
  }) async {
    if (name.trim().isEmpty) {
      throw Failure('Workout name is required.');
    }

    if (selectedExercises.isEmpty) {
      throw Failure('Choose at least one exercise.');
    }

    await workoutService.createPlan(
      name: name.trim(),
      exerciseIds: selectedExercises.map((exercise) {
        return exercise.exerciseId;
      }).toList(),
    );
  }

  List<ExerciseModel> filterExercises({
    required List<ExerciseModel> exercises,
    required String searchQuery,
    required String? selectedEquipment,
    required bool showFavoritesOnly,
    required Set<String> favoriteIds,
  }) {
    return exercises.where((exercise) {
      final name = exercise.name.toLowerCase();
      final type = exercise.exerciseType.toLowerCase();
      final muscles = exercise.targetMuscles.join(' ').toLowerCase();
      final equipments = exercise.equipments.join(' ').toLowerCase();

      final query = searchQuery.toLowerCase().trim();

      final matchesSearch = query.isEmpty ||
          name.contains(query) ||
          type.contains(query) ||
          muscles.contains(query) ||
          equipments.contains(query);

      final matchesEquipment = selectedEquipment == null ||
          exercise.equipments.any((equipment) {
            return equipment.toLowerCase().trim() ==
                selectedEquipment.toLowerCase().trim();
          });

      final matchesFavorite =
          !showFavoritesOnly || favoriteIds.contains(exercise.exerciseId);

      return matchesSearch && matchesEquipment && matchesFavorite;
    }).toList();
  }

  List<String> getAvailableEquipments(List<ExerciseModel> exercises) {
    final equipments = <String>{};

    for (final exercise in exercises) {
      for (final equipment in exercise.equipments) {
        if (equipment.trim().isNotEmpty) {
          equipments.add(equipment.trim());
        }
      }
    }

    final list = equipments.toList();
    list.sort();

    return list;
  }

  String getErrorMessage(Object error) {
    if (error is Failure) {
      return error.message;
    }

    final message = error.toString().replaceFirst('Exception: ', '').trim();

    if (message.isNotEmpty && message != 'null') {
      return message;
    }

    return 'Something went wrong';
  }
}