import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../cubit/meal_plan_cubit.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MealPlanCubit>()..loadWeekPlan(),
      child: const _MealPlanView(),
    );
  }
}

class _MealPlanView extends StatelessWidget {
  const _MealPlanView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<MealPlanCubit, MealPlanState>(
        builder: (context, state) {
          if (state is MealPlanLoading || state is MealPlanInitial) {
            return const _LoadingView();
          }
          if (state is MealPlanLoaded) {
            return state.plan.isEmpty
                ? _EmptyView(weekStart: state.currentWeekStart)
                : _LoadedView(state: state);
          }
          if (state is MealPlanError) {
            return _ErrorView(message: state.message);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton:
          BlocBuilder<MealPlanCubit, MealPlanState>(
        builder: (context, state) {
          if (state is MealPlanLoaded || state is MealPlanError) {
            return FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Text('✨',
                  style: TextStyle(fontSize: 18)),
              label: Text('Generate with AI',
                  style: AppTypography.labelMedium
                      .copyWith(color: Colors.white)),
              onPressed: () async {
                final result = await context.push('/generate');
                if (result == true && context.mounted) {
                  context.read<MealPlanCubit>().loadWeekPlan();
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.weekStart});
  final DateTime weekStart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.tagBackground,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: Text('📅',
                        style: TextStyle(fontSize: 52))),
              ),
              const SizedBox(height: 24),
              Text('No meals planned yet',
                  style: AppTypography.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Generate a personalised weekly plan with AI\nor add meals manually.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Text('✨',
                      style: TextStyle(fontSize: 16)),
                  label: const Text('Generate Full Week with AI'),
                  onPressed: () async {
                    final result = await context.push('/generate');
                    if (result == true && context.mounted) {
                      context.read<MealPlanCubit>().loadWeekPlan();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home/search'),
                child: Text('Add meals manually',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loaded state
// ─────────────────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});
  final MealPlanLoaded state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── AppBar area ────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Meal Plan',
                    style: AppTypography.titleLarge),
                const SizedBox(height: 12),
                _WeekNavigator(state: state),
                const SizedBox(height: 12),
                _DaySelector(state: state),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(
              color: AppColors.outlineVariant, height: 1),

          // ── Day content ────────────────────────────────────────────────
          Expanded(
            child: _DayContent(state: state),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Week navigator
// ─────────────────────────────────────────────────────────────────────────────

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({required this.state});
  final MealPlanLoaded state;

  @override
  Widget build(BuildContext context) {
    final label =
        'Week of ${DateFormat('MMM d').format(state.currentWeekStart)}';
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded,
              color: AppColors.textPrimary),
          onPressed: () =>
              context.read<MealPlanCubit>().previousWeek(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: AppTypography.labelMedium
                .copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textPrimary),
          onPressed: () =>
              context.read<MealPlanCubit>().nextWeek(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day selector pills
// ─────────────────────────────────────────────────────────────────────────────

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.state});
  final MealPlanLoaded state;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = state.currentWeekStart.add(Duration(days: i));
        final isSelected = _sameDay(day, state.selectedDay);
        final isToday = _sameDay(day, today);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<MealPlanCubit>().selectDay(day);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                _dayLabels[i],
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? AppColors.primary
                          : AppColors.textSecondary,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─────────────────────────────────────────────────────────────────────────────
// Day content — 4 meal sections
// ─────────────────────────────────────────────────────────────────────────────

class _DayContent extends StatelessWidget {
  const _DayContent({required this.state});
  final MealPlanLoaded state;

  static const _mealTypes = [
    ('breakfast', 'Breakfast', '🌅'),
    ('lunch', 'Lunch', '☀️'),
    ('dinner', 'Dinner', '🌙'),
    ('snacks', 'Snacks', '🍎'),
  ];

  @override
  Widget build(BuildContext context) {
    final day = state.plan.dayFor(state.selectedDay);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          context.read<MealPlanCubit>().loadWeekPlan(
                state.currentWeekStart,
              ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: _mealTypes.map((mt) {
          final meals = day?.mealsFor(mt.$1) ?? [];
          return _MealSection(
            mealType: mt.$1,
            label: mt.$2,
            emoji: mt.$3,
            meals: meals,
            selectedDay: state.selectedDay,
            weekKey: state.plan.weekKey,
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meal section
// ─────────────────────────────────────────────────────────────────────────────

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.mealType,
    required this.label,
    required this.emoji,
    required this.meals,
    required this.selectedDay,
    required this.weekKey,
  });

  final String mealType;
  final String label;
  final String emoji;
  final List<MealItem> meals;
  final DateTime selectedDay;
  final String weekKey;

  @override
  Widget build(BuildContext context) {
    final totalCal =
        meals.fold(0.0, (sum, m) => sum + m.calories);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Text(emoji,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              if (totalCal > 0)
                Text(
                  '${totalCal.toInt()} kcal',
                  style: AppTypography.statsStyle
                      .copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Meal items
          ...meals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MealItemCard(
                  meal: meal,
                  onDelete: () {
                    HapticFeedback.lightImpact();
                    context.read<MealPlanCubit>().removeMeal(
                          selectedDay,
                          mealType,
                          meal.recipeId,
                        );
                  },
                ),
              )),

          // Add button
          GestureDetector(
            onTap: () => context.push('/home/search'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.outlineVariant,
                    style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded,
                      color: AppColors.outline, size: 18),
                  const SizedBox(width: 6),
                  Text('Add $label',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.outline)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meal item card (swipe to delete)
// ─────────────────────────────────────────────────────────────────────────────

class _MealItemCard extends StatelessWidget {
  const _MealItemCard({
    required this.meal,
    required this.onDelete,
  });

  final MealItem meal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${meal.recipeId}_${meal.addedAt.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: meal.recipeImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: meal.recipeImage,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          _imageFallback(),
                    )
                  : _imageFallback(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.recipeName,
                    style: AppTypography.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meal.calories.toInt()} kcal',
                    style: AppTypography.statsStyle
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Delete icon
            GestureDetector(
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
        width: 64,
        height: 64,
        color: AppColors.tagBackground,
        child: const Center(
            child: Text('🍽️',
                style: TextStyle(fontSize: 28))),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading / Error views
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

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
              onPressed: () =>
                  context.read<MealPlanCubit>().loadWeekPlan(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
