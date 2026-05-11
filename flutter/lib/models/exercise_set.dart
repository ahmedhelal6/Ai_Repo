class ExerciseSet {
  double weight;
  int reps;
  bool isCompleted;

  ExerciseSet({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });
  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }
}