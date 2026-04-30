import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/network/dio_client.dart';
import 'core/theme/theme_cubit.dart';
// ── Module 2 imports ──────────────────────────────────────────────────────────
import 'features/onboarding/data/local_datasource.dart';
import 'features/onboarding/domain/usecases/check_onboarding_status.dart';
import 'features/onboarding/domain/usecases/complete_onboarding.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/onboarding/presentation/screens/dietary_preferences_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';
// ── Module 3 imports ──────────────────────────────────────────────────────────
import 'features/recipes/data/datasources/recipe_local_datasource.dart';
import 'features/recipes/data/datasources/recipe_remote_datasource.dart';
import 'features/recipes/data/repositories/recipe_repository_impl.dart';
import 'features/recipes/domain/repositories/recipe_repository.dart';
import 'features/recipes/domain/usecases/recipe_usecases.dart';
import 'features/recipes/presentation/cubits/recipe_detail_cubit.dart';
import 'features/recipes/presentation/cubits/recipe_search_cubit.dart';
import 'features/recipes/presentation/screens/ingredient_search_screen.dart';
import 'features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'features/recipes/presentation/screens/search_screen.dart';

final GetIt sl = GetIt.instance;

/// Initialises and registers all dependencies.
/// Call `await init()` from [main] before [runApp].
Future<void> init() async {
  // ── External: SharedPreferences ───────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // ── External: Dio ─────────────────────────────────────────────────────────
  sl.registerSingleton<Dio>(DioClient.create());

  // ── External: Hive Boxes ──────────────────────────────────────────────────
  sl.registerSingleton<Box>(
    Hive.box(AppConstants.hiveRecipesBox),
    instanceName: AppConstants.hiveRecipesBox,
  );
  sl.registerSingleton<Box>(
    Hive.box(AppConstants.hiveMealPlanBox),
    instanceName: AppConstants.hiveMealPlanBox,
  );
  sl.registerSingleton<Box>(
    Hive.box(AppConstants.hiveCacheBox),
    instanceName: AppConstants.hiveCacheBox,
  );

  // ── Core: ThemeCubit ──────────────────────────────────────────────────────
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<SharedPreferences>()),
  );

  // ── Module 2: Onboarding ──────────────────────────────────────────────────
  sl.registerLazySingleton<OnboardingLocalDatasource>(
    () => OnboardingLocalDatasource(sl<SharedPreferences>()),
  );
  sl.registerFactory<CheckOnboardingStatus>(
    () => CheckOnboardingStatus(sl<OnboardingLocalDatasource>()),
  );
  sl.registerFactory<CompleteOnboarding>(
    () => CompleteOnboarding(sl<OnboardingLocalDatasource>()),
  );
  sl.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(
      checkOnboardingStatus: sl<CheckOnboardingStatus>(),
      completeOnboarding: sl<CompleteOnboarding>(),
    ),
  );

  // ── Module 3: Recipes ─────────────────────────────────────────────────────

  sl.registerLazySingleton<RecipeRemoteDatasource>(
    () => RecipeRemoteDatasource(sl<Dio>()),
  );
  sl.registerLazySingleton<RecipeLocalDatasource>(
    () => RecipeLocalDatasource(
      sl<Box>(instanceName: AppConstants.hiveCacheBox),
    ),
  );
  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(
      remote: sl<RecipeRemoteDatasource>(),
      local: sl<RecipeLocalDatasource>(),
    ),
  );
  sl.registerFactory<SearchRecipes>(
    () => SearchRecipes(sl<RecipeRepository>()),
  );
  sl.registerFactory<GetRecipeDetail>(
    () => GetRecipeDetail(sl<RecipeRepository>()),
  );
  sl.registerFactory<SearchByIngredients>(
    () => SearchByIngredients(sl<RecipeRepository>()),
  );
  sl.registerFactory<GetRandomRecipe>(
    () => GetRandomRecipe(sl<RecipeRepository>()),
  );
  sl.registerFactory<RecipeSearchCubit>(
    () => RecipeSearchCubit(
      searchRecipes: sl<SearchRecipes>(),
      searchByIngredients: sl<SearchByIngredients>(),
    ),
  );
  sl.registerFactory<RecipeDetailCubit>(
    () => RecipeDetailCubit(
      getRecipeDetail: sl<GetRecipeDetail>(),
      savedBox: sl<Box>(instanceName: AppConstants.hiveRecipesBox),
    ),
  );

  // TODO Module 4: Register meal plan datasources and repositories
  // TODO Module 5: Register saved datasources
  // TODO Module 6: Register profile datasources

  // ── Navigation: GoRouter ──────────────────────────────────────────────────
  sl.registerSingleton<GoRouter>(_buildRouter());
}

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/preferences',
          builder: (_, state) {
            final editMode = state.uri.queryParameters['editMode'] == 'true';
            return DietaryPreferencesScreen(editMode: editMode);
          },
        ),

        // ── Shell (bottom nav) ───────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => _ShellScaffold(child: child),
          routes: [
            GoRoute(
              path: '/home',
              // TODO Module 4: replace with HomeScreen
              builder: (_, __) => const _PlaceholderTab('Home'),
            ),
            GoRoute(
              path: '/home/search',
              builder: (_, __) => const SearchScreen(),
            ),
            GoRoute(
              path: '/home/plan',
              // TODO Module 4: replace with MealPlanScreen
              builder: (_, __) => const _PlaceholderTab('Meal Plan'),
            ),
            GoRoute(
              path: '/home/saved',
              // TODO Module 5: replace with SavedScreen
              builder: (_, __) => const _PlaceholderTab('Saved'),
            ),
            GoRoute(
              path: '/home/profile',
              // TODO Module 5: replace with ProfileScreen
              builder: (_, __) => const _PlaceholderTab('Profile'),
            ),
          ],
        ),

        GoRoute(
          path: '/recipe/:id',
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return RecipeDetailScreen(recipeId: id);
          },
        ),
        GoRoute(
          path: '/ingredients',
          builder: (_, __) => const IngredientSearchScreen(),
        ),
        GoRoute(
          path: '/generate',
          // TODO Module 4: replace with AIMealPlanGenerationScreen
          builder: (_, __) => const _PlaceholderTab('AI Generation — Module 4'),
        ),
      ],
    );

// ─────────────────────────────────────────────────────────────────────────────
// Shell scaffold
// ─────────────────────────────────────────────────────────────────────────────

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.child});
  final Widget child;

  static const _tabs = [
    '/home',
    '/home/search',
    '/home/plan',
    '/home/saved',
    '/home/profile',
  ];
  static const _icons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.calendar_month_rounded,
    Icons.bookmark_border_rounded,
    Icons.account_circle_outlined,
  ];
  static const _labels = ['Home', 'Search', 'Plan', 'Saved', 'Profile'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0EDED))),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final isActive = i == current;
                return GestureDetector(
                  onTap: () => context.go(_tabs[i]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[i],
                        size: 24,
                        color: isActive
                            ? const Color(0xFFA63500)
                            : const Color(0xFF8D7168),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? const Color(0xFFA63500)
                              : const Color(0xFF8D7168),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder tab
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$name\n(Coming in the next module)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
