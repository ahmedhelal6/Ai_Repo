import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/core/service_locator.dart';
import 'package:ai_fitness_coach/models/workout_model.dart';
import 'package:ai_fitness_coach/models/workout_progress_model.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/services/workout_service.dart';

class HomeController {
  final AuthService authService = ServiceLocator.authService;

  late final WorkoutService workoutService = WorkoutService(authService);

  Future<(List<WorkoutModel>, WorkoutProgressModel?)> loadData() async {
    final workouts = await workoutService.getPlans();
    final progress = await workoutService.getProgress();

    return (workouts.reversed.toList(), progress);
  }

  Future<void> deleteWorkout(String workoutId) async {
    await workoutService.deletePlan(workoutId);
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