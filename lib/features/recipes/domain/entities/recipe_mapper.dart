import '../../data/models/recipe_model.dart';
import '../entities/recipe.dart';

/// Converts between [RecipeModel] (data layer) and [Recipe] (domain layer).
extension RecipeMapper on RecipeModel {
  Recipe toEntity() => Recipe(
        id: id,
        title: title,
        image: image,
        readyInMinutes: readyInMinutes,
        servings: servings,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        summary: summary,
        dishTypes: dishTypes,
        diets: diets,
        cuisines: cuisines,
        ingredients: extendedIngredients,
        instructions: analyzedInstructions,
        isSaved: isSaved,
      );
}
