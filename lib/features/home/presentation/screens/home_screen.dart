import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/recipe_card.dart';
import '../../../../shared/widgets/shimmer/recipe_shimmers.dart';
import '../../../meal_plan/domain/entities/meal_plan_entities.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../cubit/home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..loadHome(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeCubit, HomeState>(
        bloc: context.read<HomeCubit>(),
        builder: (context, state) {
          // ignore: invalid_use_of_visible_for_testing_member
          return BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return _buildShimmer();
              }
              if (state is HomeLoaded) {
                return state.trendingRecipes.isEmpty &&
                        state.weekPreview.isEmpty
                    ? _EmptyView(state: state)
                    : _LoadedView(state: state);
              }
              if (state is HomeError) {
                return _ErrorView(message: state.message);
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting shimmer
            const ShimmerRecipeListItem(),
            const SizedBox(height: 16),
            // Search bar shimmer
            const ShimmerHeroCard(),
            const SizedBox(height: 16),
            const ShimmerRecipeGrid(itemCount: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loaded view
// ─────────────────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});
  final HomeLoaded state;

  static const _categories = [
    ('🍝', 'Pasta', 'pasta'),
    ('🥗', 'Salads', 'salad'),
    ('🍜', 'Asian', 'asian'),
    ('🍕', 'Pizza', 'pizza'),
    ('🥩', 'Grill', 'bbq'),
    ('🥣', 'Breakfast', 'breakfast'),
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<HomeCubit>().refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildSearchBar(context)),
          SliverToBoxAdapter(child: _buildHeroCard(context, state.heroRecipe)),
          if (state.weekPreview.isNotEmpty)
            SliverToBoxAdapter(child: _buildWeekPreview(context)),
          SliverToBoxAdapter(child: _buildCategories(context)),
          SliverToBoxAdapter(child: _buildTrendingHeader(context)),
          _buildTrendingGrid(context),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.greeting}, ${state.userName} 👋',
                  style: AppTypography.displayMedium,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 4),
                Text(
                  "What are we cooking today?",
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                state.userName.isNotEmpty
                    ? state.userName[0].toUpperCase()
                    : 'P',
                style: AppTypography.labelMedium
                    .copyWith(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => context.go('/home/search'),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: AppColors.outline, size: 20),
              const SizedBox(width: 10),
              Text('Search recipes, ingredients…',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.outline)),
              const Spacer(),
              const Icon(Icons.mic_rounded, color: AppColors.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero card ────────────────────────────────────────────────────────────

  Widget _buildHeroCard(BuildContext context, Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => context.push('/recipe/${recipe.id}'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                recipe.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: recipe.image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFFFE8D6)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFFFE8D6),
                          child: const Center(
                              child:
                                  Text('🍽️', style: TextStyle(fontSize: 60))),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFFFE8D6),
                        child: const Center(
                            child: Text('🍽️', style: TextStyle(fontSize: 60))),
                      ),
                // Gradient
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC1C1B1B)],
                      stops: [0.3, 1.0],
                    ),
                  ),
                ),
                // AI badge top-left
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('AI Suggested',
                        style: AppTypography.labelSmall
                            .copyWith(color: Colors.white)),
                  ),
                ),
                // Bookmark top-right
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark_border_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                // Title + chips bottom
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: AppTypography.titleLarge
                            .copyWith(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _InfoPill('⏱ ${recipe.readyInMinutes} min'),
                          const SizedBox(width: 8),
                          if (recipe.calories > 0)
                            _InfoPill('🔥 ${recipe.calories.toInt()} kcal'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.06, duration: 500.ms),
      ),
    );
  }

  // ── Week preview ─────────────────────────────────────────────────────────

  Widget _buildWeekPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Continue Planning',
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.weekPreview.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final day = state.weekPreview[i];
                final isToday = _sameDay(day.date, DateTime.now());
                final firstMeal = day.allMeals.firstOrNull;

                return Container(
                  width: 88,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🍽️', style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(
                        _dayAbbr(day.date),
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      if (firstMeal != null)
                        Text(
                          firstMeal.recipeName,
                          style:
                              AppTypography.labelSmall.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Categories ───────────────────────────────────────────────────────────

  Widget _buildCategories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text('Popular Categories',
                style: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/home/search?q=${cat.$3}');
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text('${cat.$1} ${cat.$2}',
                        style: AppTypography.labelMedium),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Trending header ───────────────────────────────────────────────────────

  Widget _buildTrendingHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Trending Recipes',
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w600)),
          GestureDetector(
            onTap: () => context.go('/home/search'),
            child: Text('See All',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ── Trending grid ─────────────────────────────────────────────────────────

  Widget _buildTrendingGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => RecipeCard(
            recipe: state.trendingRecipes[i],
            onTap: () => context.push('/recipe/${state.trendingRecipes[i].id}'),
          ),
          childCount: state.trendingRecipes.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayAbbr(DateTime date) {
    const abbrs = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return abbrs[date.weekday - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty view
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.state});
  final HomeLoaded state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('${state.greeting}, ${state.userName} 👋',
                style: AppTypography.displayMedium),
            const SizedBox(height: 4),
            Text("What are we cooking today?",
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppColors.tagBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                        child: Text('🍽️', style: TextStyle(fontSize: 52))),
                  ),
                  const SizedBox(height: 20),
                  Text('No meal plan yet', style: AppTypography.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Let AI build your week in seconds',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.push('/generate'),
                      child: const Text('Generate My Meal Plan'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/home/search'),
                    child: Text('Or explore recipes',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text(message,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().loadHome(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info pill (hero card)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  const _InfoPill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: AppTypography.labelSmall.copyWith(color: Colors.white)),
    );
  }
}
