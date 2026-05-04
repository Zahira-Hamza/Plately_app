import 'package:hive_flutter/hive_flutter.dart';
import 'meal_item_model.dart';

part 'meal_plan_day_model.g.dart';

@HiveType(typeId: 5)
class MealPlanDayModel extends HiveObject {
  MealPlanDayModel({
    required this.date,
    List<MealItemModel>? breakfast,
    List<MealItemModel>? lunch,
    List<MealItemModel>? dinner,
    List<MealItemModel>? snacks,
  })  : breakfast = breakfast ?? [],
        lunch = lunch ?? [],
        dinner = dinner ?? [],
        snacks = snacks ?? [];

  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<MealItemModel> breakfast;

  @HiveField(2)
  final List<MealItemModel> lunch;

  @HiveField(3)
  final List<MealItemModel> dinner;

  @HiveField(4)
  final List<MealItemModel> snacks;

  /// Total calories across all meal types for this day.
  double get totalCalories =>
      [...breakfast, ...lunch, ...dinner, ...snacks]
          .fold(0, (sum, item) => sum + item.calories);

  /// Returns the list for the given [mealType] string.
  List<MealItemModel> mealsFor(String mealType) => switch (mealType) {
        'breakfast' => breakfast,
        'lunch' => lunch,
        'dinner' => dinner,
        'snacks' => snacks,
        _ => [],
      };

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'breakfast': breakfast.map((m) => m.toJson()).toList(),
        'lunch': lunch.map((m) => m.toJson()).toList(),
        'dinner': dinner.map((m) => m.toJson()).toList(),
        'snacks': snacks.map((m) => m.toJson()).toList(),
      };

  factory MealPlanDayModel.fromJson(Map<String, dynamic> json) {
    List<MealItemModel> _parse(dynamic raw) => (raw as List? ?? [])
        .map((e) => MealItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MealPlanDayModel(
      date: DateTime.parse(json['date'] as String),
      breakfast: _parse(json['breakfast']),
      lunch: _parse(json['lunch']),
      dinner: _parse(json['dinner']),
      snacks: _parse(json['snacks']),
    );
  }
}
