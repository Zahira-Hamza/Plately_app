import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SearchRecipes
// ─────────────────────────────────────────────────────────────────────────────

class SearchRecipes {
  const SearchRecipes(this._repository);
  final RecipeRepository _repository;

  Future<Either<Failure, List<Recipe>>> call(
    String query, {
    String? diet,
  }) =>
      _repository.searchRecipes(query, diet: diet);
}

// ─────────────────────────────────────────────────────────────────────────────
// GetRecipeDetail
// ─────────────────────────────────────────────────────────────────────────────

class GetRecipeDetail {
  const GetRecipeDetail(this._repository);
  final RecipeRepository _repository;

  Future<Either<Failure, Recipe>> call(int id) =>
      _repository.getRecipeById(id);
}

// ─────────────────────────────────────────────────────────────────────────────
// SearchByIngredients
// ─────────────────────────────────────────────────────────────────────────────

class SearchByIngredients {
  const SearchByIngredients(this._repository);
  final RecipeRepository _repository;

  Future<Either<Failure, List<Recipe>>> call(List<String> ingredients) =>
      _repository.searchByIngredients(ingredients);
}

// ─────────────────────────────────────────────────────────────────────────────
// GetRandomRecipe
// ─────────────────────────────────────────────────────────────────────────────

class GetRandomRecipe {
  const GetRandomRecipe(this._repository);
  final RecipeRepository _repository;

  Future<Either<Failure, Recipe>> call() => _repository.getRandomRecipe();
}
