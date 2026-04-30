import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe.dart';

/// Abstract contract for all recipe data operations.
/// The presentation layer depends only on this interface — never on the impl.
abstract class RecipeRepository {
  /// Search recipes by [query] with optional [diet] filter.
  Future<Either<Failure, List<Recipe>>> searchRecipes(
    String query, {
    String? diet,
  });

  /// Fetch full recipe detail by [id].
  Future<Either<Failure, Recipe>> getRecipeById(int id);

  /// Find recipes that use the provided [ingredients].
  Future<Either<Failure, List<Recipe>>> searchByIngredients(
    List<String> ingredients,
  );

  /// Fetch a single random recipe (used for the home hero card).
  Future<Either<Failure, Recipe>> getRandomRecipe();
}
