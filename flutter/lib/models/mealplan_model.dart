class MealPlan {
  final int totalCalories;
  final int protein;
  final int carbs;
  final int fats;
  final List<Meal> meals;

  MealPlan({
    required this.totalCalories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.meals,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      totalCalories: json['totalCalories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
      meals: (json['meals'] as List? ?? [])
          .map((e) => Meal.fromJson(e))
          .toList(),
    );
  }
}

class Meal {
  final String type;
  final String name;
  final int calories;

  Meal({
    required this.type,
    required this.name,
    required this.calories,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      calories: json['calories'] ?? 0,
    );
  }
}