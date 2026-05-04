import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/extensions.dart';
import '../../../meal_plan/data/datasources/meal_plan_local_datasource.dart';
import '../../../meal_plan/domain/entities/meal_plan_entities.dart';
import '../../../meal_plan/domain/meal_plan_mapper.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/domain/usecases/recipe_usecases.dart';

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.heroRecipe,
    required this.trendingRecipes,
    required this.weekPreview,
    required this.userName,
    required this.greeting,
  });

  final Recipe heroRecipe;
  final List<Recipe> trendingRecipes;

  /// Today + next 2 days from the current week plan (may be empty).
  final List<MealPlanDay> weekPreview;
  final String userName;
  final String greeting;

  @override
  List<Object?> get props =>
      [heroRecipe, trendingRecipes, weekPreview, userName, greeting];
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetRandomRecipe getRandomRecipe,
    required SearchRecipes searchRecipes,
    required SharedPreferences prefs,
    required MealPlanLocalDatasource mealPlanDatasource,
  })  : _getRandomRecipe = getRandomRecipe,
        _searchRecipes = searchRecipes,
        _prefs = prefs,
        _mealPlanDatasource = mealPlanDatasource,
        super(const HomeInitial());

  final GetRandomRecipe _getRandomRecipe;
  final SearchRecipes _searchRecipes;
  final SharedPreferences _prefs;
  final MealPlanLocalDatasource _mealPlanDatasource;

  Future<void> loadHome() async {
    emit(const HomeLoading());

    // ── User info ──────────────────────────────────────────────────────────
    final userName =
        _prefs.getString(AppConstants.prefUserName) ?? 'there';
    final greeting = DateTime.now().greeting();

    // ── Hero recipe (random) ───────────────────────────────────────────────
    final heroResult = await _getRandomRecipe();
    if (isClosed) return;

    if (heroResult.isLeft()) {
      final failure = heroResult.fold((f) => f, (_) => null)!;
      emit(HomeError(_mapFailure(failure)));
      return;
    }
    final heroRecipe = heroResult.fold((_) => null, (r) => r)!;

    // ── Trending (search with empty query) ─────────────────────────────────
    final trendingResult = await _searchRecipes('', diet: null);
    if (isClosed) return;
    final trending = trendingResult.fold((_) => <Recipe>[], (r) => r);

    // ── Week preview from local Hive ───────────────────────────────────────
    final today = DateTime.now();
    final weekKey = today.toWeekKey();
    final planModel = _mealPlanDatasource.getMealPlan(weekKey);
    final weekPreview = <MealPlanDay>[];

    if (planModel != null) {
      for (int i = 0; i < 3; i++) {
        final date = today.add(Duration(days: i));
        final dayModel = planModel.dayFor(date);
        if (dayModel != null) {
          weekPreview.add(dayModel.toEntity());
        }
      }
    }

    emit(HomeLoaded(
      heroRecipe: heroRecipe,
      trendingRecipes: trending.take(6).toList(),
      weekPreview: weekPreview,
      userName: userName,
      greeting: greeting,
    ));
  }

  Future<void> refresh() => loadHome();

  String _mapFailure(Failure f) => switch (f) {
        NetworkFailure(:final message) => message,
        QuotaExceededFailure() =>
          'API quota exceeded. Please try again later.',
        TimeoutFailure() => 'Request timed out. Check your connection.',
        _ => 'Could not load home. Please try again.',
      };
}
