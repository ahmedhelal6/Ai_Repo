import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/core/service_locator.dart';
import 'package:ai_fitness_coach/models/exercise_model.dart';
import 'package:ai_fitness_coach/models/exercise_set.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/services/workout_service.dart';

class SessionController {
  final AuthService authService = ServiceLocator.authService;

  late final WorkoutService workoutService = WorkoutService(authService);

  double calculateCompletion(List<ExerciseSet> sets) {
    if (sets.isEmpty) return 0.0;

    final completed = sets.where((set) => set.isCompleted).length;

    return completed / sets.length;
  }

  Future<void> submitSession({
    required String workoutId,
    required List<ExerciseModel> baseExercises,
    required List<List<ExerciseSet>> sets,
  }) async {
    if (workoutId.trim().isEmpty) {
      throw Failure('Invalid workout id');
    }

    if (baseExercises.isEmpty) {
      throw Failure('No exercises found');
    }

    if (sets.length != baseExercises.length) {
      throw Failure('Invalid workout sets data');
    }

    final performed = <ExerciseModel>[];

    for (int i = 0; i < baseExercises.length; i++) {
      final base = ExerciseModel.fromJson(baseExercises[i].toJson());
      final newSets = sets[i];

      base.sets = newSets;
      base.completionPercentage = calculateCompletion(newSets);
      base.completed = newSets.isNotEmpty && newSets.every((set) => set.isCompleted);

      performed.add(base);
    }

    await workoutService.createSession(
      workoutPlanId: workoutId,
      exercises: performed,
    );
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