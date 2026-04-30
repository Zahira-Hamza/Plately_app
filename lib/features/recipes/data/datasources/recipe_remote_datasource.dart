import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/recipe_model.dart';

/// All Spoonacular API calls for the recipes feature.
class RecipeRemoteDatasource {
  const RecipeRemoteDatasource(this._dio);

  final Dio _dio;

  // ──────────────────────────────────────────────────────────────────────────
  // Search
  // ──────────────────────────────────────────────────────────────────────────

  /// `GET /recipes/complexSearch`
  ///
  /// Returns up to [number] recipes matching [query] and optional [diet].
  /// Nutrition is included in the response (`addRecipeNutrition=true`).
  Future<List<RecipeModel>> searchRecipes(
    String query, {
    String? diet,
    int number = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.spoonacularBaseUrl}/recipes/complexSearch',
        queryParameters: {
          'query': query,
          if (diet != null && diet.isNotEmpty) 'diet': diet,
          'number': number,
          'addRecipeNutrition': true,
          'apiKey': AppConstants.spoonacularApiKey,
        },
      );
      final results = response.data['results'] as List? ?? [];
      return results
          .map((r) => RecipeModel.fromSearchJson(r as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Detail
  // ──────────────────────────────────────────────────────────────────────────

  /// `GET /recipes/{id}/information`
  ///
  /// Returns full recipe detail including nutrition, ingredients, and steps.
  Future<RecipeModel> getRecipeById(int id) async {
    try {
      final response = await _dio.get(
        '${AppConstants.spoonacularBaseUrl}/recipes/$id/information',
        queryParameters: {
          'includeNutrition': true,
          'apiKey': AppConstants.spoonacularApiKey,
        },
      );
      return RecipeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Ingredient search
  // ──────────────────────────────────────────────────────────────────────────

  /// `GET /recipes/findByIngredients`
  ///
  /// Returns recipes that use the provided [ingredients].
  /// This endpoint returns a lighter payload (no full nutrition). We enrich
  /// the top [enrichLimit] results with full detail via [getRecipeById]; the
  /// rest are returned with partial data.
  Future<List<RecipeModel>> searchByIngredients(
    List<String> ingredients, {
    int number = 20,
    int enrichLimit = 5,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.spoonacularBaseUrl}/recipes/findByIngredients',
        queryParameters: {
          'ingredients': ingredients.join(','),
          'number': number,
          'apiKey': AppConstants.spoonacularApiKey,
        },
      );

      final results = response.data as List? ?? [];
      final partialRecipes = results
          .map((r) => _partialFromIngredientSearch(r as Map<String, dynamic>))
          .toList();

      // Enrich top results with full detail in parallel.
      final toEnrich = partialRecipes.take(enrichLimit).toList();
      final enriched = await Future.wait(
        toEnrich.map((r) => getRecipeById(r.id).catchError((_) => r)),
      );

      return [
        ...enriched,
        ...partialRecipes.skip(enrichLimit),
      ];
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Random
  // ──────────────────────────────────────────────────────────────────────────

  /// `GET /recipes/random`
  ///
  /// Returns a single random recipe (used for the home hero card).
  Future<RecipeModel> getRandomRecipe() async {
    try {
      final response = await _dio.get(
        '${AppConstants.spoonacularBaseUrl}/recipes/random',
        queryParameters: {
          'number': 1,
          'includeNutrition': true,
          'apiKey': AppConstants.spoonacularApiKey,
        },
      );
      final recipes = response.data['recipes'] as List? ?? [];
      if (recipes.isEmpty) throw Exception('No random recipe returned');
      return RecipeModel.fromJson(recipes.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Builds a minimal [RecipeModel] from the lightweight ingredient-search
  /// response (which only contains id, title, image, and match counts).
  RecipeModel _partialFromIngredientSearch(Map<String, dynamic> json) {
    return RecipeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      imageType: (json['imageType'] as String?) ?? 'jpg',
      readyInMinutes: 0,
      servings: 1,
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      summary: '',
      dishTypes: const [],
      diets: const [],
      cuisines: const [],
      extendedIngredients: const [],
      analyzedInstructions: const [],
    );
  }
}
