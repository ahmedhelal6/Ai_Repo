import 'package:ai_fitness_coach/core/service_locator.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/services/profile_service.dart';

class ProfileController {
  final AuthService authService = ServiceLocator.authService;

  late final ProfileService profileService = ProfileService(authService);

  Future<UserData> loadProfile(UserData oldUser) async {
    final localUser = await UserData.load();
    final baseUser = localUser ?? oldUser;

    final fetchedUser = await profileService.getProfile();

    final updatedUser = baseUser.copyWith(
      gender: fetchedUser.gender ?? baseUser.gender,
      age: fetchedUser.age ?? baseUser.age,
      height: fetchedUser.height ?? baseUser.height,
      weight: fetchedUser.weight ?? baseUser.weight,
      goal: _textOrOld(fetchedUser.goal, baseUser.goal),
      email: fetchedUser.email ?? baseUser.email,
      userName: _textOrOld(fetchedUser.userName, baseUser.userName),
      imagePath: _textOrOld(fetchedUser.imagePath, baseUser.imagePath),
    );

    await updatedUser.save();
    return updatedUser;
  }

  Future<UserData> updateProfile({
    required UserData userData,
    required String userName,
    required String goal,
    required int age,
    required int height,
    required int weight,
  }) async {
    final fetchedUser = await profileService.updateProfile(
      username: userName.trim(),
      goal: goal,
      age: age,
      height: height,
      weight: weight,
    );

    final updatedUser = userData.copyWith(
      userName: _textOrOld(fetchedUser.userName, userName),
      goal: _textOrOld(fetchedUser.goal, goal),
      age: fetchedUser.age ?? age,
      height: fetchedUser.height ?? height,
      weight: fetchedUser.weight ?? weight,
      imagePath: userData.imagePath,
    );

    await updatedUser.save();
    return updatedUser;
  }

  Future<UserData> updateProfileImage({
    required UserData userData,
    required String imagePath,
  }) async {
    final updatedUser = userData.copyWith(imagePath: imagePath);

    await updatedUser.save();
    return updatedUser;
  }

  Future<UserData> removeProfileImage({
    required UserData userData,
  }) async {
    final updatedUser = userData.copyWith(imagePath: null);

    await updatedUser.save();
    return updatedUser;
  }

  Future<void> logout() async {
    try {
      await profileService.logoutFromServer();
    } catch (_) {}

    await authService.logout();
  }

  String? _textOrOld(String? newValue, String? oldValue) {
    if (newValue != null && newValue.trim().isNotEmpty) {
      return newValue.trim();
    }

    return oldValue;
  }
}