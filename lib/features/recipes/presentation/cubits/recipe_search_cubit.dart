import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/recipe_usecases.dart';
import '../../../../core/error/failures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

abstract class RecipeSearchState extends Equatable {
  const RecipeSearchState();
  @override
  List<Object?> get props => [];
}

class RecipeSearchInitial extends RecipeSearchState {
  const RecipeSearchInitial();
}

class RecipeSearchLoading extends RecipeSearchState {
  const RecipeSearchLoading();
}

class RecipeSearchLoaded extends RecipeSearchState {
  const RecipeSearchLoaded(this.recipes);
  final List<Recipe> recipes;
  @override
  List<Object?> get props => [recipes];
}

class RecipeSearchEmpty extends RecipeSearchState {
  const RecipeSearchEmpty(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class RecipeSearchError extends RecipeSearchState {
  const RecipeSearchError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

class RecipeSearchCubit extends Cubit<RecipeSearchState> {
  RecipeSearchCubit({
    required SearchRecipes searchRecipes,
    required SearchByIngredients searchByIngredients,
  })  : _searchRecipes = searchRecipes,
        _searchByIngredients = searchByIngredients,
        super(const RecipeSearchInitial());

  final SearchRecipes _searchRecipes;
  final SearchByIngredients _searchByIngredients;

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 300);

  // ── Text search (debounced) ────────────────────────────────────────────────

  /// Debounced search — waits 300 ms after the last keystroke before firing.
  void search(String query, {String? diet}) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(const RecipeSearchInitial());
      return;
    }

    _debounce = Timer(_debounceDuration, () => _doSearch(query, diet: diet));
  }

  Future<void> _doSearch(String query, {String? diet}) async {
    emit(const RecipeSearchLoading());

    final result = await _searchRecipes(query, diet: diet);
    if (isClosed) return;

    result.fold(
      (failure) => emit(RecipeSearchError(_mapFailure(failure))),
      (recipes) => recipes.isEmpty
          ? emit(RecipeSearchEmpty(query))
          : emit(RecipeSearchLoaded(recipes)),
    );
  }

  // ── Ingredient search ──────────────────────────────────────────────────────

  Future<void> searchByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) return;
    emit(const RecipeSearchLoading());

    final result = await _searchByIngredients(ingredients);
    if (isClosed) return;

    result.fold(
      (failure) => emit(RecipeSearchError(_mapFailure(failure))),
      (recipes) => recipes.isEmpty
          ? emit(const RecipeSearchEmpty(''))
          : emit(RecipeSearchLoaded(recipes)),
    );
  }

  // ── Misc ───────────────────────────────────────────────────────────────────

  void clearSearch() {
    _debounce?.cancel();
    emit(const RecipeSearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _mapFailure(Failure f) => switch (f) {
        NetworkFailure(:final message) => message,
        QuotaExceededFailure() =>
          'API quota exceeded. Please try again later.',
        TimeoutFailure() => 'Request timed out. Check your connection.',
        ServerFailure(:final message) => message,
        _ => 'Something went wrong. Please try again.',
      };
}
