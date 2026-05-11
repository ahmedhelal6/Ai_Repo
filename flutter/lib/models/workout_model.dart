import 'exercise_model.dart';

class WorkoutModel {
  final String id;
  final String name;
  final List<ExerciseModel> exercises;

  const WorkoutModel({
    required this.id,
    required this.name,
    required this.exercises,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: _getId(json),
      name: (json['name'] ?? json['workoutName'] ?? 'Workout').toString(),
      exercises: _parseExercises(json['exercises']),
    );
  }

  static String _getId(Map<String, dynamic> json) {
    return (json['id'] ??
            json['workoutPlanId'] ??
            json['planId'] ??
            json['workoutId'] ??
            '')
        .toString();
  }

  static List<ExerciseModel> _parseExercises(dynamic value) {
    if (value is! List) return [];

    List<ExerciseModel> result = [];

    for (var item in value) {
      if (item is Map<String, dynamic>) {
        result.add(ExerciseModel.fromJson(item));
      } else if (item is Map) {
        result.add(ExerciseModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return result;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}