import 'package:ai_fitness_coach/core/service_locator.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/services/profile_service.dart';

class AuthController {
  final AuthService authService = ServiceLocator.authService;

  late final ProfileService profileService = ProfileService(authService);

  Future<UserData> login({
    required String email,
    required String password,
  }) async {
    final oldUser = await UserData.load();

    await authService.login(
      email: email.trim(),
      password: password,
    );

    final fetchedUser = await profileService.getProfile();

    final user = UserData(
      email: fetchedUser.email ?? email.trim(),
      userName: fetchedUser.userName ?? email.trim().split('@').first,
      gender: fetchedUser.gender,
      age: fetchedUser.age,
      height: fetchedUser.height,
      weight: fetchedUser.weight,
      goal: fetchedUser.goal,
      imagePath: fetchedUser.imagePath ?? oldUser?.imagePath,
    );

    await user.save();

    return user;
  }

  Future<UserData> register({
    required UserData userData,
    required String username,
    required String email,
    required String password,
  }) async {
    if (userData.age == null ||
        userData.height == null ||
        userData.weight == null ||
        userData.gender == null) {
      throw Exception('Complete onboarding data first');
    }

    await authService.register(
      email: email.trim(),
      password: password,
      username: username.trim(),
      goal: userData.goal ?? 'general',
      height: userData.height!,
      weight: userData.weight!,
      age: userData.age!,
      gender: userData.gender!,
    );

    final updatedUser = userData.copyWith(
      userName: username.trim(),
      email: email.trim(),
    );

    await updatedUser.save();

    return updatedUser;
  }
}