import 'dart:convert';

import 'package:ai_fitness_coach/core/errors/error_handler.dart';
import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';

class ProfileService {
  ProfileService(this.authService);

  final AuthService authService;

  Map<String, dynamic> _toMap(dynamic data) {
    if (data == null) return {};

    if (data is Map<String, dynamic>) return data;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);

        if (decoded is Map<String, dynamic>) return decoded;

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return {};
      }
    }

    return {};
  }

  Map<String, dynamic> _extractProfileData(Map<String, dynamic> data) {
    final possibleContainers = [
      data['data'],
      data['result'],
      data['value'],
      data['user'],
      data['profile'],
    ];

    for (final item in possibleContainers) {
      final mapped = _toMap(item);

      if (mapped.isNotEmpty) {
        return mapped;
      }
    }

    return data;
  }

  Future<UserData> getProfile() async {
    try {
      final response = await authService.dio.get<dynamic>(
        '/api/Profile',
      );

      final responseData = _toMap(response.data);

      if (responseData.isEmpty) {
        throw Failure('Profile data is empty');
      }

      final profileData = _extractProfileData(responseData);

      if (profileData.isEmpty) {
        throw Failure('Profile data is empty');
      }

      return UserData.fromJson(profileData);
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Get profile failed',
      );
    }
  }

  Future<UserData> updateProfile({
    required String username,
    required String goal,
    required int age,
    required int height,
    required int weight,
  }) async {
    try {
      final response = await authService.dio.put<dynamic>(
        '/api/Profile/edit',
        data: {
          'username': username.trim(),
          'goal': goal,
          'age': age,
          'height': height,
          'weight': weight,
        },
      );

      final responseData = _toMap(response.data);

      if (responseData.isEmpty) {
        return UserData(
          userName: username.trim(),
          goal: goal,
          age: age,
          height: height,
          weight: weight,
        );
      }

      final profileData = _extractProfileData(responseData);

      if (profileData.isEmpty) {
        return UserData(
          userName: username.trim(),
          goal: goal,
          age: age,
          height: height,
          weight: weight,
        );
      }

      return UserData.fromJson(profileData);
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Update profile failed',
      );
    }
  }

  Future<void> logoutFromServer() async {
    try {
      await authService.dio.post<dynamic>(
        '/api/Profile/logout',
      );
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Logout failed',
      );
    }
  }
}