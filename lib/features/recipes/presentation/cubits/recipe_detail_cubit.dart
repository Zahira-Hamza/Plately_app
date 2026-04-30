import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/recipe_usecases.dart';
import '../../data/models/ingredient_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

abstract class RecipeDetailState extends Equatable {
  const RecipeDetailState();
  @override
  List<Object?> get props => [];
}

class RecipeDetailInitial extends RecipeDetailState {
  const RecipeDetailInitial();
}

class RecipeDetailLoading extends RecipeDetailState {
  const RecipeDetailLoading();
}

class RecipeDetailLoaded extends RecipeDetailState {
  const RecipeDetailLoaded({
    required this.recipe,
    required this.isSaved,
    required this.currentServings,
    required this.scaledIngredients,
    this.activeStepIndex = 0,
  });

  final Recipe recipe;
  final bool isSaved;
  final int currentServings;

  /// Ingredients with amounts scaled to [currentServings].
  final List<IngredientModel> scaledIngredients;
  final int activeStepIndex;

  RecipeDetailLoaded copyWith({
    bool? isSaved,
    int? currentServings,
    List<IngredientModel>? scaledIngredients,
    int? activeStepIndex,
  }) =>
      RecipeDetailLoaded(
        recipe: recipe,
        isSaved: isSaved ?? this.isSaved,
        currentServings: currentServings ?? this.currentServings,
        scaledIngredients: scaledIngredients ?? this.scaledIngredients,
        activeStepIndex: activeStepIndex ?? this.activeStepIndex,
      );

  @override
  List<Object?> get props =>
      [recipe, isSaved, currentServings, scaledIngredients, activeStepIndex];
}

class RecipeDetailError extends RecipeDetailState {
  const RecipeDetailError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  RecipeDetailCubit({
    required GetRecipeDetail getRecipeDetail,
    required Box savedBox,
  })  : _getRecipeDetail = getRecipeDetail,
        _savedBox = savedBox,
        super(const RecipeDetailInitial());

  final GetRecipeDetail _getRecipeDetail;
  final Box _savedBox;

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> loadRecipe(int id) async {
    emit(const RecipeDetailLoading());

    final result = await _getRecipeDetail(id);
    if (isClosed) return;

    result.fold(
      (failure) => emit(RecipeDetailError(_mapFailure(failure))),
      (recipe) {
        final saved = _savedBox.containsKey(recipe.id.toString());
        emit(RecipeDetailLoaded(
          recipe: recipe,
          isSaved: saved,
          currentServings: recipe.servings,
          scaledIngredients: recipe.ingredients,
        ));
      },
    );
  }

  // ── Save / unsave ──────────────────────────────────────────────────────────

  Future<void> toggleSave() async {
    final current = state;
    if (current is! RecipeDetailLoaded) return;

    final newSaved = !current.isSaved;

    if (newSaved) {
      await _savedBox.put(
        current.recipe.id.toString(),
        current.recipe.id,
      );
    } else {
      await _savedBox.delete(current.recipe.id.toString());
    }

    emit(current.copyWith(isSaved: newSaved));
  }

  // ── Servings scaling ───────────────────────────────────────────────────────

  /// Scales all ingredient amounts proportionally to [newServings].
  void updateServings(int newServings) {
    final current = state;
    if (current is! RecipeDetailLoaded) return;
    if (newServings < 1) return;

    final originalServings = current.recipe.servings;
    final ratio = newServings / originalServings;

    final scaled = current.recipe.ingredients
        .map((ing) => IngredientModel(
              id: ing.id,
              name: ing.name,
              amount: ing.amount * ratio,
              unit: ing.unit,
              image: ing.image,
            ))
        .toList();

    emit(current.copyWith(
      currentServings: newServings,
      scaledIngredients: scaled,
    ));
  }

  // ── Steps ──────────────────────────────────────────────────────────────────

  void setActiveStep(int index) {
    final current = state;
    if (current is! RecipeDetailLoaded) return;
    emit(current.copyWith(activeStepIndex: index));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _mapFailure(Failure f) => switch (f) {
        NetworkFailure(:final message) => message,
        QuotaExceededFailure() => 'API quota exceeded. Try again later.',
        TimeoutFailure() => 'Request timed out. Check your connection.',
        ServerFailure(:final message) => message,
        _ => 'Could not load recipe. Please try again.',
      };
}
