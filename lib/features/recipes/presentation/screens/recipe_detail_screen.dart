import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/shimmer/recipe_shimmers.dart';
import '../../data/models/ingredient_model.dart';
import '../../data/models/instruction_model.dart';
import '../../data/models/step_model.dart';
import '../../domain/entities/recipe.dart';
import '../cubits/recipe_detail_cubit.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});
  final int recipeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RecipeDetailCubit>()..loadRecipe(recipeId),
      child: const _RecipeDetailView(),
    );
  }
}

class _RecipeDetailView extends StatelessWidget {
  const _RecipeDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
        builder: (context, state) {
          if (state is RecipeDetailLoading || state is RecipeDetailInitial) {
            return const ShimmerRecipeDetail();
          }
          if (state is RecipeDetailLoaded) {
            return _LoadedView(state: state);
          }
          if (state is RecipeDetailError) {
            return _ErrorView(message: state.message,
                onRetry: () =>
                    context.read<RecipeDetailCubit>().loadRecipe(0));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loaded view
// ─────────────────────────────────────────────────────────────────────────────

class _LoadedView extends StatefulWidget {
  const _LoadedView({required this.state});
  final RecipeDetailLoaded state;

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.state.recipe;
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _HeroSliver(recipe: recipe, state: widget.state),
            SliverToBoxAdapter(
              child: _RecipeBody(
                state: widget.state,
                tabController: _tabController,
              ),
            ),
            // Bottom padding for sticky button
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        // Sticky Add to Plan button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _StickyBottom(recipe: recipe),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero sliver
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSliver extends StatelessWidget {
  const _HeroSliver({required this.recipe, required this.state});
  final Recipe recipe;
  final RecipeDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: _FrostedButton(
        icon: Icons.chevron_left_rounded,
        onTap: () => context.pop(),
      ),
      actions: [
        _FrostedButton(
          icon: state.isSaved
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          iconColor: state.isSaved ? AppColors.primary : Colors.white,
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<RecipeDetailCubit>().toggleSave();
          },
        ),
        _FrostedButton(
          icon: Icons.share_rounded,
          onTap: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            recipe.image.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: recipe.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: const Color(0xFFFFE8D6)),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFFFE8D6),
                      child: const Center(
                          child: Text('🍽️',
                              style: TextStyle(fontSize: 60))),
                    ),
                  )
                : Container(
                    color: const Color(0xFFFFE8D6),
                    child: const Center(
                        child:
                            Text('🍽️', style: TextStyle(fontSize: 60))),
                  ),
            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x80000000)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrostedButton extends StatelessWidget {
  const _FrostedButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recipe body
// ─────────────────────────────────────────────────────────────────────────────

class _RecipeBody extends StatelessWidget {
  const _RecipeBody({required this.state, required this.tabController});
  final RecipeDetailLoaded state;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final recipe = state.recipe;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(recipe.title, style: AppTypography.displayMedium),
            const SizedBox(height: 8),
            // Rating row
            Row(children: [
              ...List.generate(
                  5,
                  (_) => const Icon(Icons.star_rounded,
                      color: AppColors.primary, size: 16)),
              const SizedBox(width: 6),
              Text('4.9 (124 reviews)',
                  style: AppTypography.statsStyle
                      .copyWith(color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 12),
            // Info chips
            _InfoChipsRow(recipe: recipe),
            const SizedBox(height: 16),
            // Macro cards
            _MacroCardsRow(recipe: recipe),
            const SizedBox(height: 20),
            // Tab bar
            TabBar(
              controller: tabController,
              labelStyle: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w600),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.outline,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'Ingredients'),
                Tab(text: 'Steps'),
                Tab(text: 'Nutrition'),
              ],
            ),
            const SizedBox(height: 16),
            // Tab content — fixed height to avoid nested scroll issues
            SizedBox(
              height: 600,
              child: TabBarView(
                controller: tabController,
                children: [
                  _IngredientsTab(state: state),
                  _StepsTab(state: state),
                  _NutritionTab(recipe: recipe),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info chips row
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChipsRow extends StatelessWidget {
  const _InfoChipsRow({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final chips = [
      ('⏱', '${recipe.readyInMinutes} min'),
      ('👥', '${recipe.servings} servings'),
      if (recipe.calories > 0) ('🔥', '${recipe.calories.toInt()} kcal'),
      ('📊', _difficulty(recipe.readyInMinutes)),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips
          .map((c) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.surfaceContainer),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c.$1,
                        style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(c.$2,
                        style: AppTypography.statsStyle.copyWith(
                            color: AppColors.textSecondary)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  String _difficulty(int mins) {
    if (mins <= 20) return 'Easy';
    if (mins <= 45) return 'Medium';
    return 'Hard';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Macro cards row
// ─────────────────────────────────────────────────────────────────────────────

class _MacroCardsRow extends StatelessWidget {
  const _MacroCardsRow({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final macros = [
      ('🔥', 'Calories', recipe.calories.toInt().toString(), 'kcal',
          const Color(0xFFFF6B35)),
      ('💪', 'Protein', recipe.protein.toInt().toString(), 'g',
          const Color(0xFF2196F3)),
      ('🌾', 'Carbs', recipe.carbs.toInt().toString(), 'g',
          const Color(0xFFFF9800)),
      ('🥑', 'Fat', recipe.fat.toInt().toString(), 'g',
          const Color(0xFF4CAF50)),
    ];

    return Row(
      children: macros
          .map((m) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _MacroCard(
                    emoji: m.$1,
                    label: m.$2,
                    value: m.$3,
                    unit: m.$4,
                    color: m.$5,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
  final String emoji, label, value, unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: AppTypography.statsStyle.copyWith(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          Text(unit,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ingredients tab
// ─────────────────────────────────────────────────────────────────────────────

class _IngredientsTab extends StatelessWidget {
  const _IngredientsTab({required this.state});
  final RecipeDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Servings adjuster
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded,
                  color: AppColors.primary, size: 28),
              onPressed: () => context
                  .read<RecipeDetailCubit>()
                  .updateServings(state.currentServings - 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${state.currentServings} servings',
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.primary),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primary, size: 28),
              onPressed: () => context
                  .read<RecipeDetailCubit>()
                  .updateServings(state.currentServings + 1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: state.scaledIngredients.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.outlineVariant, height: 1),
            itemBuilder: (_, i) =>
                _IngredientRow(ingredient: state.scaledIngredients[i]),
          ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatefulWidget {
  const _IngredientRow({required this.ingredient});
  final IngredientModel ingredient;

  @override
  State<_IngredientRow> createState() => _IngredientRowState();
}

class _IngredientRowState extends State<_IngredientRow> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Custom checkbox
          GestureDetector(
            onTap: () => setState(() => _checked = !_checked),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _checked ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      _checked ? AppColors.primary : AppColors.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: _checked
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Amount
          Text(
            _formatAmount(widget.ingredient.amount),
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          Text(widget.ingredient.unit,
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.primary)),
          const SizedBox(width: 8),
          // Name
          Expanded(
            child: Text(
              widget.ingredient.name,
              style: AppTypography.bodyMedium.copyWith(
                decoration: _checked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: _checked
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          // Image
          if (widget.ingredient.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.ingredient.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox(width: 40),
              ),
            ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(1);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Steps tab
// ─────────────────────────────────────────────────────────────────────────────

class _StepsTab extends StatelessWidget {
  const _StepsTab({required this.state});
  final RecipeDetailLoaded state;

  List<StepModel> get _allSteps => state.recipe.instructions
      .expand((ins) => ins.steps)
      .toList();

  @override
  Widget build(BuildContext context) {
    final steps = _allSteps;
    if (steps.isEmpty) {
      return Center(
        child: Text('No steps available.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      itemCount: steps.length,
      itemBuilder: (_, i) => _StepCard(
        step: steps[i],
        isActive: i == state.activeStepIndex,
        onTap: () =>
            context.read<RecipeDetailCubit>().setActiveStep(i),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.isActive,
    required this.onTap,
  });
  final StepModel step;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.tagBackground
              : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 3))
              : Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number circle
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${step.number}',
                  style: AppTypography.labelMedium
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.step,
                      style: AppTypography.bodyMedium),
                  if (step.lengthMinutes != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showTimer(context, step.lengthMinutes!),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Set Timer ${step.lengthMinutes} min',
                            style: AppTypography.labelMedium
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimer(BuildContext context, int minutes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Timer set for $minutes min'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nutrition tab
// ─────────────────────────────────────────────────────────────────────────────

class _NutritionTab extends StatelessWidget {
  const _NutritionTab({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final total = recipe.protein + recipe.carbs + recipe.fat;
    if (total == 0) {
      return Center(
        child: Text('Nutrition data unavailable.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
      );
    }

    final sections = [
      PieChartSectionData(
        value: recipe.protein,
        color: const Color(0xFF2196F3),
        radius: 40,
        showTitle: false,
      ),
      PieChartSectionData(
        value: recipe.carbs,
        color: const Color(0xFFFF9800),
        radius: 40,
        showTitle: false,
      ),
      PieChartSectionData(
        value: recipe.fat,
        color: const Color(0xFF4CAF50),
        radius: 40,
        showTitle: false,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(PieChartData(
                  sections: sections,
                  centerSpaceRadius: 60,
                  sectionsSpace: 3,
                )),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.calories.toInt().toString(),
                      style: AppTypography.statsStyle.copyWith(
                          fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    Text('kcal',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _NutritionRow(
              label: 'Protein',
              value: recipe.protein,
              color: const Color(0xFF2196F3),
              total: total),
          _NutritionRow(
              label: 'Carbohydrates',
              value: recipe.carbs,
              color: const Color(0xFFFF9800),
              total: total),
          _NutritionRow(
              label: 'Fat',
              value: recipe.fat,
              color: const Color(0xFF4CAF50),
              total: total),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({
    required this.label,
    required this.value,
    required this.color,
    required this.total,
  });
  final String label;
  final double value;
  final Color color;
  final double total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total * 100).toInt() : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label, style: AppTypography.bodyMedium)),
          Text('${value.toInt()}g',
              style: AppTypography.statsStyle),
          const SizedBox(width: 8),
          Text('$pct%',
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky bottom bar
// ─────────────────────────────────────────────────────────────────────────────

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(
            top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.calendar_month_rounded,
              color: Colors.white, size: 18),
          label: const Text('Add to Meal Plan'),
          onPressed: () {
            // TODO Module 4: open AddToPlanBottomSheet
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: AppColors.outlineVariant),
              const SizedBox(height: 16),
              Text(message,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try Again')),
            ],
          ),
        ),
      ),
    );
  }
}
