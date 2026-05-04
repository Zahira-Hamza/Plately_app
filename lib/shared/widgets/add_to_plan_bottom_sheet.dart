import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions.dart';
import '../../features/meal_plan/domain/entities/meal_plan_entities.dart';
import '../../features/meal_plan/presentation/cubit/meal_plan_cubit.dart';
import '../../injection_container.dart';

/// Shows a bottom sheet that lets the user pick a day + meal type,
/// then adds the recipe to the meal plan via [MealPlanCubit].
///
/// Usage:
/// ```dart
/// AddToPlanBottomSheet.show(
///   context,
///   recipeId: recipe.id,
///   recipeName: recipe.title,
///   recipeImage: recipe.image,
///   calories: recipe.calories,
/// );
/// ```
class AddToPlanBottomSheet extends StatefulWidget {
  const AddToPlanBottomSheet({
    super.key,
    required this.recipeId,
    required this.recipeName,
    required this.recipeImage,
    required this.calories,
  });

  final int recipeId;
  final String recipeName;
  final String recipeImage;
  final double calories;

  static Future<void> show(
    BuildContext context, {
    required int recipeId,
    required String recipeName,
    required String recipeImage,
    required double calories,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<MealPlanCubit>()..loadWeekPlan(),
        child: AddToPlanBottomSheet(
          recipeId: recipeId,
          recipeName: recipeName,
          recipeImage: recipeImage,
          calories: calories,
        ),
      ),
    );
  }

  @override
  State<AddToPlanBottomSheet> createState() => _AddToPlanBottomSheetState();
}

class _AddToPlanBottomSheetState extends State<AddToPlanBottomSheet> {
  DateTime _selectedDay = DateTime.now();
  String _selectedMealType = 'lunch';
  bool _isAdding = false;

  static const _mealTypes = [
    ('breakfast', 'Breakfast', '🌅'),
    ('lunch', 'Lunch', '☀️'),
    ('dinner', 'Dinner', '🌙'),
    ('snacks', 'Snack', '🍎'),
  ];

  List<DateTime> get _weekDays {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Future<void> _addToplan() async {
    setState(() => _isAdding = true);
    HapticFeedback.lightImpact();

    final weekKey = _selectedDay.toWeekKey();
    final item = MealItem(
      recipeId: widget.recipeId,
      recipeName: widget.recipeName,
      recipeImage: widget.recipeImage,
      calories: widget.calories,
      addedAt: DateTime.now(),
    );

    await context
        .read<MealPlanCubit>()
        .addMeal(_selectedDay, _selectedMealType, item);

    if (!mounted) return;
    setState(() => _isAdding = false);

    // Show success feedback then close.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Added to ${_mealTypeLabel(_selectedMealType)} on ${_dayLabel(_selectedDay)}',
                style: AppTypography.labelMedium
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),

          // ── Title ────────────────────────────────────────────────────────
          Text('Add to Meal Plan', style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          Text(
            widget.recipeName,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // ── Day selector ─────────────────────────────────────────────────
          Text('SELECT DAY',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              )),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map((day) {
              final isSelected = _sameDay(day, _selectedDay);
              final isToday = _sameDay(day, DateTime.now());
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDay = day);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _dayAbbr(day),
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${day.day}',
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── Meal type selector ───────────────────────────────────────────
          Text('MEAL TYPE',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              )),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: _mealTypes.map((mt) {
              final isSelected = mt.$1 == _selectedMealType;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedMealType = mt.$1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.tagBackground
                        : AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mt.$3,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(
                        mt.$2,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // ── Add button ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: _isAdding
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.add_rounded,
                      color: Colors.white, size: 20),
              label: Text(_isAdding ? 'Adding…' : 'Add to Plan'),
              onPressed: _isAdding ? null : _addToplan,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayAbbr(DateTime d) {
    const abbrs = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return abbrs[d.weekday - 1];
  }

  String _dayLabel(DateTime d) {
    const names = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return names[d.weekday - 1];
  }

  String _mealTypeLabel(String type) => switch (type) {
        'breakfast' => 'Breakfast',
        'lunch' => 'Lunch',
        'dinner' => 'Dinner',
        'snacks' => 'Snacks',
        _ => type,
      };
}
