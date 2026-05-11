import 'exercise_set.dart';

class ExerciseModel {
  final String exerciseId;
  final String name;
  final List<String> targetMuscles;
  final List<String> equipments;
  final String imageUrl;
  final String videoUrl;
  final String exerciseType;
   bool completed;
   List<ExerciseSet> sets;
   double completionPercentage;

   ExerciseModel({
    required this.exerciseId,
    required this.name,
    required this.targetMuscles,
    required this.equipments,
    required this.imageUrl,
    required this.videoUrl,
    required this.exerciseType,
    this.completed = false,
    this.sets = const [],
    this.completionPercentage = 0.0,
  });


  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      exerciseId: json['exerciseId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetMuscles: (json['targetMuscles'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      equipments: (json['equipments'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['imageUrl']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      exerciseType: json['exerciseType']?.toString() ?? '',
      completed: json['completed'] == true,
      sets: (json['sets'] as List?)
              ?.map((e) =>
                  ExerciseSet.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'targetMuscles': targetMuscles,
      'equipments': equipments,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'exerciseType': exerciseType,
      'completed': completed,
      'sets': sets.map((e) => e.toJson()).toList(),
      'completionPercentage': completionPercentage,
    };
  }
}