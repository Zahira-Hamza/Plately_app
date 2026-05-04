import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal_item_model.dart';
import '../models/meal_plan_day_model.dart';
import '../models/meal_plan_model.dart';

/// Handles all local persistence for meal plans using Hive.
///
/// Each [MealPlanModel] is stored under its [weekKey] (e.g. "2024-W18").
class MealPlanLocalDatasource {
  const MealPlanLocalDatasource(this._box);
  final Box _box;

  // ── Read ─────────────────────────────────────────────────────────────────

  MealPlanModel? getMealPlan(String weekKey) {
    final raw = _box.get(weekKey);
    if (raw == null) return null;
    if (raw is MealPlanModel) return raw;
    return null;
  }

  List<MealPlanModel> getAllPlans() {
    return _box.values.whereType<MealPlanModel>().toList();
  }

  int getAllPlansCount() => getAllPlans().length;

  // ── Write ────────────────────────────────────────────────────────────────

  Future<void> saveMealPlan(MealPlanModel plan) =>
      _box.put(plan.weekKey, plan);

  Future<void> addMealToDay(
    String weekKey,
    DateTime date,
    String mealType,
    MealItemModel item,
  ) async {
    final existing = getMealPlan(weekKey) ??
        MealPlanModel(weekKey: weekKey, days: []);
    final updated = existing.withAddedMeal(date, mealType, item);
    await saveMealPlan(updated);
  }

  Future<void> removeMealFromDay(
    String weekKey,
    DateTime date,
    String mealType,
    int recipeId,
  ) async {
    final existing = getMealPlan(weekKey);
    if (existing == null) return;
    final updated = existing.withRemovedMeal(date, mealType, recipeId);
    await saveMealPlan(updated);
  }

  Future<void> deletePlan(String weekKey) => _box.delete(weekKey);
}
