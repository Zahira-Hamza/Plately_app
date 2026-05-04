import '../data/models/meal_item_model.dart';
import '../data/models/meal_plan_day_model.dart';
import '../data/models/meal_plan_model.dart';
import 'entities/meal_plan_entities.dart';

extension MealItemMapper on MealItemModel {
  MealItem toEntity() => MealItem(
        recipeId: recipeId,
        recipeName: recipeName,
        recipeImage: recipeImage,
        calories: calories,
        addedAt: addedAt,
      );
}

extension MealPlanDayMapper on MealPlanDayModel {
  MealPlanDay toEntity() => MealPlanDay(
        date: date,
        breakfast: breakfast.map((m) => m.toEntity()).toList(),
        lunch: lunch.map((m) => m.toEntity()).toList(),
        dinner: dinner.map((m) => m.toEntity()).toList(),
        snacks: snacks.map((m) => m.toEntity()).toList(),
      );
}

extension MealPlanMapper on MealPlanModel {
  MealPlan toEntity() => MealPlan(
        weekKey: weekKey,
        days: days.map((d) => d.toEntity()).toList(),
      );
}

extension MealItemEntityMapper on MealItem {
  MealItemModel toModel() => MealItemModel(
        recipeId: recipeId,
        recipeName: recipeName,
        recipeImage: recipeImage,
        calories: calories,
        addedAt: addedAt,
      );
}
