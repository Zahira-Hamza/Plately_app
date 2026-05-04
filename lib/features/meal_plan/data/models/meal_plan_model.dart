import 'package:hive_flutter/hive_flutter.dart';
import 'meal_plan_day_model.dart';
import 'meal_item_model.dart';

part 'meal_plan_model.g.dart';

@HiveType(typeId: 4)
class MealPlanModel extends HiveObject {
  MealPlanModel({
    required this.weekKey,
    required this.days,
  });

  /// ISO week key, e.g. "2024-W18".
  @HiveField(0)
  final String weekKey;

  @HiveField(1)
  final List<MealPlanDayModel> days;

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Returns the day matching [date] (date-only comparison), or null.
  MealPlanDayModel? dayFor(DateTime date) {
    final d = _dateOnly(date);
    try {
      return days.firstWhere((day) => _dateOnly(day.date) == d);
    } catch (_) {
      return null;
    }
  }

  /// Returns a copy with [item] added to [mealType] on [date].
  MealPlanModel withAddedMeal(
      DateTime date, String mealType, MealItemModel item) {
    final updatedDays = days.map((day) {
      if (_dateOnly(day.date) != _dateOnly(date)) return day;
      return _addToDay(day, mealType, item);
    }).toList();

    // If no day exists for this date, create one.
    if (!days.any((d) => _dateOnly(d.date) == _dateOnly(date))) {
      final newDay = _addToDay(
        MealPlanDayModel(date: date),
        mealType,
        item,
      );
      updatedDays.add(newDay);
    }

    return MealPlanModel(weekKey: weekKey, days: updatedDays);
  }

  /// Returns a copy with the meal matching [recipeId] removed from [mealType]
  /// on [date].
  MealPlanModel withRemovedMeal(
      DateTime date, String mealType, int recipeId) {
    final updatedDays = days.map((day) {
      if (_dateOnly(day.date) != _dateOnly(date)) return day;
      return _removeFromDay(day, mealType, recipeId);
    }).toList();
    return MealPlanModel(weekKey: weekKey, days: updatedDays);
  }

  // ── Private ──────────────────────────────────────────────────────────────

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static MealPlanDayModel _addToDay(
      MealPlanDayModel day, String mealType, MealItemModel item) {
    return MealPlanDayModel(
      date: day.date,
      breakfast: mealType == 'breakfast'
          ? [...day.breakfast, item]
          : day.breakfast,
      lunch: mealType == 'lunch' ? [...day.lunch, item] : day.lunch,
      dinner: mealType == 'dinner' ? [...day.dinner, item] : day.dinner,
      snacks: mealType == 'snacks' ? [...day.snacks, item] : day.snacks,
    );
  }

  static MealPlanDayModel _removeFromDay(
      MealPlanDayModel day, String mealType, int recipeId) {
    List<MealItemModel> _remove(List<MealItemModel> list) =>
        list.where((m) => m.recipeId != recipeId).toList();

    return MealPlanDayModel(
      date: day.date,
      breakfast:
          mealType == 'breakfast' ? _remove(day.breakfast) : day.breakfast,
      lunch: mealType == 'lunch' ? _remove(day.lunch) : day.lunch,
      dinner: mealType == 'dinner' ? _remove(day.dinner) : day.dinner,
      snacks: mealType == 'snacks' ? _remove(day.snacks) : day.snacks,
    );
  }
}
