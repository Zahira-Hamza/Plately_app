import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../domain/meal_plan_mapper.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../datasources/grok_datasource.dart';
import '../datasources/meal_plan_local_datasource.dart';
import '../models/meal_item_model.dart';
import '../models/meal_plan_day_model.dart';
import '../models/meal_plan_model.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  const MealPlanRepositoryImpl({
    required MealPlanLocalDatasource local,
    required GrokDatasource grok,
  })  : _local = local,
        _grok = grok;

  final MealPlanLocalDatasource _local;
  final GrokDatasource _grok;

  @override
  Future<Either<Failure, MealPlan>> getWeekPlan(String weekKey) async {
    try {
      final model = _local.getMealPlan(weekKey);
      if (model == null) {
        return Right(MealPlan(weekKey: weekKey, days: []));
      }
      return Right(model.toEntity());
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addMealToDay(
    String weekKey,
    DateTime date,
    String mealType,
    MealItem item,
  ) async {
    try {
      await _local.addMealToDay(weekKey, date, mealType, item.toModel());
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeMealFromDay(
    String weekKey,
    DateTime date,
    String mealType,
    int recipeId,
  ) async {
    try {
      await _local.removeMealFromDay(weekKey, date, mealType, recipeId);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, MealPlan>> generateAIPlan({
    required String goal,
    required int calorieTarget,
    required int mealsPerDay,
    required List<String> dietaryPrefs,
    required String weekKey,
    required DateTime weekStart,
  }) async {
    try {
      final grokPlan = await _grok.generateMealPlan(
        goal: goal,
        calorieTarget: calorieTarget,
        mealsPerDay: mealsPerDay,
        dietaryPrefs: dietaryPrefs,
      );

      final dayNames = [
        'Monday', 'Tuesday', 'Wednesday',
        'Thursday', 'Friday', 'Saturday', 'Sunday',
      ];

      final days = grokPlan.days.map((gDay) {
        final dayIndex = dayNames.indexOf(gDay.day);
        final date =
            weekStart.add(Duration(days: dayIndex < 0 ? 0 : dayIndex));

        // Build typed meal buckets directly from the typed GrokMeal list —
        // avoids the fragile name-matching approach used with Gemini.
        final breakfast = gDay.meals
            .where((m) => m.type == 'breakfast')
            .map((m) => MealItemModel(
                  recipeId: 0,
                  recipeName: m.name,
                  recipeImage: '',
                  calories: m.calories,
                  addedAt: DateTime.now(),
                ))
            .toList();

        final lunch = gDay.meals
            .where((m) => m.type == 'lunch')
            .map((m) => MealItemModel(
                  recipeId: 0,
                  recipeName: m.name,
                  recipeImage: '',
                  calories: m.calories,
                  addedAt: DateTime.now(),
                ))
            .toList();

        final dinner = gDay.meals
            .where((m) => m.type == 'dinner')
            .map((m) => MealItemModel(
                  recipeId: 0,
                  recipeName: m.name,
                  recipeImage: '',
                  calories: m.calories,
                  addedAt: DateTime.now(),
                ))
            .toList();

        final snacks = gDay.meals
            .where((m) => m.type == 'snacks')
            .map((m) => MealItemModel(
                  recipeId: 0,
                  recipeName: m.name,
                  recipeImage: '',
                  calories: m.calories,
                  addedAt: DateTime.now(),
                ))
            .toList();

        return MealPlanDayModel(
          date: date,
          breakfast: breakfast,
          lunch: lunch,
          dinner: dinner,
          snacks: snacks,
        );
      }).toList();

      final plan = MealPlanModel(weekKey: weekKey, days: days);
      await _local.saveMealPlan(plan);
      return Right(plan.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString(), 0));
    }
  }

  @override
  int getAllPlansCount() => _local.getAllPlansCount();
}
