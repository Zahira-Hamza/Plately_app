import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/meal_plan_entities.dart';

abstract class MealPlanRepository {
  Future<Either<Failure, MealPlan>> getWeekPlan(String weekKey);
  Future<Either<Failure, void>> addMealToDay(
      String weekKey, DateTime date, String mealType, MealItem item);
  Future<Either<Failure, void>> removeMealFromDay(
      String weekKey, DateTime date, String mealType, int recipeId);
  Future<Either<Failure, MealPlan>> generateAIPlan({
    required String goal,
    required int calorieTarget,
    required int mealsPerDay,
    required List<String> dietaryPrefs,
    required String weekKey,
    required DateTime weekStart,
  });
  int getAllPlansCount();
}
