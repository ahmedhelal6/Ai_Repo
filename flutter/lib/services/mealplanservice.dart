import 'dart:convert';

import 'package:ai_fitness_coach/core/errors/error_handler.dart';
import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/models/mealplan_model.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';

class MealPlanService {
  MealPlanService(this.authService);

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

  Map<String, dynamic> _extractMealPlanData(Map<String, dynamic> data) {
    final possibleContainers = [
      data['data'],
      data['result'],
      data['value'],
      data['mealPlan'],
      data['plan'],
    ];

    for (final item in possibleContainers) {
      final mapped = _toMap(item);

      if (mapped.isNotEmpty) {
        return mapped;
      }
    }

    return data;
  }

  Future<MealPlan> generatePlan() async {
    try {
      final response = await authService.dio.get<dynamic>(
        '/api/MealGenerator/generate-plan',
      );

      final responseData = _toMap(response.data);

      if (responseData.isEmpty) {
        throw Failure('Meal plan data is empty');
      }

      final mealPlanData = _extractMealPlanData(responseData);

      if (mealPlanData.isEmpty) {
        throw Failure('Meal plan data is empty');
      }

      return MealPlan.fromJson(mealPlanData);
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Generate meal plan failed',
      );
    }
  }
}