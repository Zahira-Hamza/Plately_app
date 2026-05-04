import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MealItem
// ─────────────────────────────────────────────────────────────────────────────

class MealItem extends Equatable {
  const MealItem({
    required this.recipeId,
    required this.recipeName,
    required this.recipeImage,
    required this.calories,
    required this.addedAt,
  });

  final int recipeId;
  final String recipeName;
  final String recipeImage;
  final double calories;
  final DateTime addedAt;

  @override
  List<Object?> get props => [recipeId, addedAt];
}

// ─────────────────────────────────────────────────────────────────────────────
// MealPlanDay
// ─────────────────────────────────────────────────────────────────────────────

class MealPlanDay extends Equatable {
  const MealPlanDay({
    required this.date,
    this.breakfast = const [],
    this.lunch = const [],
    this.dinner = const [],
    this.snacks = const [],
  });

  final DateTime date;
  final List<MealItem> breakfast;
  final List<MealItem> lunch;
  final List<MealItem> dinner;
  final List<MealItem> snacks;

  List<MealItem> get allMeals =>
      [...breakfast, ...lunch, ...dinner, ...snacks];

  double get totalCalories =>
      allMeals.fold(0, (sum, m) => sum + m.calories);

  bool get isEmpty => allMeals.isEmpty;

  List<MealItem> mealsFor(String type) => switch (type) {
        'breakfast' => breakfast,
        'lunch' => lunch,
        'dinner' => dinner,
        'snacks' => snacks,
        _ => [],
      };

  @override
  List<Object?> get props => [date, breakfast, lunch, dinner, snacks];
}

// ─────────────────────────────────────────────────────────────────────────────
// MealPlan
// ─────────────────────────────────────────────────────────────────────────────

class MealPlan extends Equatable {
  const MealPlan({
    required this.weekKey,
    required this.days,
  });

  final String weekKey;
  final List<MealPlanDay> days;

  bool get isEmpty => days.every((d) => d.isEmpty);

  MealPlanDay? dayFor(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    try {
      return days.firstWhere(
        (d) => DateTime(d.date.year, d.date.month, d.date.day) == target,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [weekKey, days];
}
