class WorkoutProgressModel {
  final int overallCompletion;
  final int totalVolume;
  final int avgSessionVolume;
  final int sessionsThisWeek;
  final int weeklyVolume;
  final int avgWeeklyVolume;
  final String topVolumeExercise;
  final String topWorkout;
  final int savedWorkouts;
  final int exercisesInsidePlans;
  final List<VolumeTrendModel> volumeTrend;

  const WorkoutProgressModel({
    required this.overallCompletion,
    required this.totalVolume,
    required this.avgSessionVolume,
    required this.sessionsThisWeek,
    required this.weeklyVolume,
    required this.avgWeeklyVolume,
    required this.topVolumeExercise,
    required this.topWorkout,
    required this.savedWorkouts,
    required this.exercisesInsidePlans,
    required this.volumeTrend,
  });

  factory WorkoutProgressModel.fromJson(Map<String, dynamic> json) {
    return WorkoutProgressModel(
      overallCompletion: _toInt(json['overallCompletion']),
      totalVolume: _toInt(json['totalVolume']),
      avgSessionVolume: _toInt(json['avgSessionVolume']),
      sessionsThisWeek: _toInt(json['sessionsThisWeek']),
      weeklyVolume: _toInt(json['weeklyVolume']),
      avgWeeklyVolume: _toInt(json['avgWeeklyVolume']),
      topVolumeExercise: json['topVolumeExercise']?.toString() ?? 'None',
      topWorkout: json['topWorkout']?.toString() ?? 'None',
      savedWorkouts: _toInt(json['savedWorkouts']),
      exercisesInsidePlans: _toInt(json['exercisesInsidePlans']),
      volumeTrend: _parseVolumeTrend(json['volumeTrend']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<VolumeTrendModel> _parseVolumeTrend(dynamic value) {
    if (value is! List) {
      return [];
    }

    List<VolumeTrendModel> result = [];

    for (var item in value) {
      if (item is Map<String, dynamic>) {
        result.add(VolumeTrendModel.fromJson(item));
      } else if (item is Map) {
        result.add(VolumeTrendModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return result;
  }
}

class VolumeTrendModel {
  final String dateLabel;
  final int volume;

  const VolumeTrendModel({
    required this.dateLabel,
    required this.volume,
  });

  factory VolumeTrendModel.fromJson(Map<String, dynamic> json) {
    return VolumeTrendModel(
      dateLabel: json['dateLabel']?.toString() ?? '',
      volume: WorkoutProgressModel._toInt(json['volume']),
    );
  }
}