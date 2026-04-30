import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_mapper.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_datasource.dart';
import '../datasources/recipe_remote_datasource.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  const RecipeRepositoryImpl({
    required RecipeRemoteDatasource remote,
    required RecipeLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  final RecipeRemoteDatasource _remote;
  final RecipeLocalDatasource _local;

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  Future<bool> get _isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Search
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipes(
    String query, {
    String? diet,
  }) async {
    if (!await _isOnline) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final models = await _remote.searchRecipes(query, diet: diet);
      return Right(models.map((m) => m.toEntity()).toList());
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Unexpected error during search', 0));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Detail — cache-first
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Recipe>> getRecipeById(int id) async {
    // 1. Try the local cache first.
    final cached = _local.getCachedRecipe(id);
    if (cached != null) return Right(cached.toEntity());

    // 2. Need network.
    if (!await _isOnline) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final model = await _remote.getRecipeById(id);
      await _local.cacheRecipe(model);
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(ServerFailure('Could not load recipe $id', 0));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Ingredient search
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Recipe>>> searchByIngredients(
    List<String> ingredients,
  ) async {
    if (!await _isOnline) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final models = await _remote.searchByIngredients(ingredients);
      return Right(models.map((m) => m.toEntity()).toList());
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(
          ServerFailure('Unexpected error during ingredient search', 0));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Random
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Recipe>> getRandomRecipe() async {
    if (!await _isOnline) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final model = await _remote.getRandomRecipe();
      await _local.cacheRecipe(model);
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Could not load random recipe', 0));
    }
  }
}
