import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/meal_plan_entities.dart';
import '../repositories/meal_plan_repository.dart';

class GetWeekPlan {
  const GetWeekPlan(this._repo);
  final MealPlanRepository _repo;
  Future<Either<Failure, MealPlan>> call(String weekKey) =>
      _repo.getWeekPlan(weekKey);
}

class AddMealToDay {
  const AddMealToDay(this._repo);
  final MealPlanRepository _repo;
  Future<Either<Failure, void>> call(
          String weekKey, DateTime date, String mealType, MealItem item) =>
      _repo.addMealToDay(weekKey, date, mealType, item);
}

class RemoveMealFromDay {
  const RemoveMealFromDay(this._repo);
  final MealPlanRepository _repo;
  Future<Either<Failure, void>> call(
          String weekKey, DateTime date, String mealType, int recipeId) =>
      _repo.removeMealFromDay(weekKey, date, mealType, recipeId);
}

class GenerateAIPlan {
  const GenerateAIPlan(this._repo);
  final MealPlanRepository _repo;
  Future<Either<Failure, MealPlan>> call({
    required String goal,
    required int calorieTarget,
    required int mealsPerDay,
    required List<String> dietaryPrefs,
    required String weekKey,
    required DateTime weekStart,
  }) =>
      _repo.generateAIPlan(
        goal: goal,
        calorieTarget: calorieTarget,
        mealsPerDay: mealsPerDay,
        dietaryPrefs: dietaryPrefs,
        weekKey: weekKey,
        weekStart: weekStart,
      );
}
