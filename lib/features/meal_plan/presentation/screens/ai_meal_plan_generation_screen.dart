import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection_container.dart';
import '../cubit/meal_plan_cubit.dart';

/// Full-screen modal that collects generation params and triggers Gemini.
/// Push with: context.push('/generate')
class AIMealPlanGenerationScreen extends StatefulWidget {
  const AIMealPlanGenerationScreen({super.key});

  @override
  State<AIMealPlanGenerationScreen> createState() =>
      _AIMealPlanGenerationScreenState();
}

class _AIMealPlanGenerationScreenState
    extends State<AIMealPlanGenerationScreen> {
  String _goal = 'maintain';
  int _calories = 2000;
  int _mealsPerDay = 3;
  bool _usePreferences = true;

  static const _goals = [
    ('lose_weight', 'Lose Weight'),
    ('maintain', 'Maintain'),
    ('build_muscle', 'Build Muscle'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MealPlanCubit>(),
      child: BlocConsumer<MealPlanCubit, MealPlanState>(
        listener: (context, state) {
          if (state is MealPlanLoaded) {
            // Generation done — pop back with success flag.
            Navigator.of(context).pop(true);
          } else if (state is MealPlanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHandle(),
                  Expanded(
                    child: state is MealPlanGenerating
                        ? _GeneratingView(text: state.loadingText)
                        : _FormView(
                            goal: _goal,
                            calories: _calories,
                            mealsPerDay: _mealsPerDay,
                            usePreferences: _usePreferences,
                            onGoalChanged: (v) =>
                                setState(() => _goal = v),
                            onCaloriesChanged: (v) =>
                                setState(() => _calories = v),
                            onMealsChanged: (v) =>
                                setState(() => _mealsPerDay = v),
                            onPrefsToggled: (v) =>
                                setState(() => _usePreferences = v),
                            onGenerate: () => context
                                .read<MealPlanCubit>()
                                .generateAIPlan(
                                  goal: _goal,
                                  calorieTarget: _calories,
                                  mealsPerDay: _mealsPerDay,
                                  usePreferences: _usePreferences,
                                ),
                            onCancel: () => Navigator.of(context).pop(),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text('Generate My Meal Plan ✨',
                  style: AppTypography.titleLarge),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form view
// ─────────────────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.goal,
    required this.calories,
    required this.mealsPerDay,
    required this.usePreferences,
    required this.onGoalChanged,
    required this.onCaloriesChanged,
    required this.onMealsChanged,
    required this.onPrefsToggled,
    required this.onGenerate,
    required this.onCancel,
  });

  final String goal;
  final int calories;
  final int mealsPerDay;
  final bool usePreferences;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<int> onCaloriesChanged;
  final ValueChanged<int> onMealsChanged;
  final ValueChanged<bool> onPrefsToggled;
  final VoidCallback onGenerate;
  final VoidCallback onCancel;

  static const _goals = [
    ('lose_weight', 'Lose Weight'),
    ('maintain', 'Maintain'),
    ('build_muscle', 'Build Muscle'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Goal selector ────────────────────────────────────────────────
          _SectionLabel('YOUR GOAL'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _goals.map((g) {
                final isActive = g.$1 == goal;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onGoalChanged(g.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          g.$2,
                          style: AppTypography.labelMedium.copyWith(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // ── Calorie slider ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel('DAILY CALORIES'),
              Text(
                '$calories kcal',
                style: AppTypography.statsStyle.copyWith(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.outlineVariant,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.12),
              trackHeight: 4,
            ),
            child: Slider(
              value: calories.toDouble(),
              min: 1200,
              max: 3000,
              divisions: 18,
              onChanged: (v) => onCaloriesChanged(v.toInt()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1200', style: AppTypography.labelSmall
                  .copyWith(color: AppColors.outline)),
              Text('3000', style: AppTypography.labelSmall
                  .copyWith(color: AppColors.outline)),
            ],
          ),

          const SizedBox(height: 24),

          // ── Meals per day ────────────────────────────────────────────────
          _SectionLabel('MEALS PER DAY'),
          const SizedBox(height: 10),
          Row(
            children: [2, 3, 4].map((n) {
              final isActive = n == mealsPerDay;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onMealsChanged(n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 72,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: isActive
                          ? null
                          : Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Center(
                      child: Text(
                        '$n',
                        style: AppTypography.labelMedium.copyWith(
                          color: isActive
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // ── Use preferences toggle ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Use my dietary preferences',
                          style: AppTypography.bodyMedium),
                      Text('Applies your saved diet settings',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: usePreferences,
                  onChanged: onPrefsToggled,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Generate button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Text('✨',
                  style: TextStyle(fontSize: 16)),
              label: const Text('Generate Plan'),
              onPressed: onGenerate,
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: onCancel,
              child: Text('Cancel',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generating view
// ─────────────────────────────────────────────────────────────────────────────

class _GeneratingView extends StatelessWidget {
  const _GeneratingView({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              text,
              style: AppTypography.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label helper
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.08 * 12,
      ),
    );
  }
}
