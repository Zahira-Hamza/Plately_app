import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../domain/usecases/meal_plan_usecases.dart';

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

abstract class MealPlanState extends Equatable {
  const MealPlanState();
  @override
  List<Object?> get props => [];
}

class MealPlanInitial extends MealPlanState {
  const MealPlanInitial();
}

class MealPlanLoading extends MealPlanState {
  const MealPlanLoading();
}

class MealPlanLoaded extends MealPlanState {
  const MealPlanLoaded({
    required this.plan,
    required this.selectedDay,
    required this.currentWeekStart,
  });
  final MealPlan plan;
  final DateTime selectedDay;
  final DateTime currentWeekStart;

  MealPlanLoaded copyWith({
    MealPlan? plan,
    DateTime? selectedDay,
    DateTime? currentWeekStart,
  }) =>
      MealPlanLoaded(
        plan: plan ?? this.plan,
        selectedDay: selectedDay ?? this.selectedDay,
        currentWeekStart: currentWeekStart ?? this.currentWeekStart,
      );

  @override
  List<Object?> get props => [plan, selectedDay, currentWeekStart];
}

class MealPlanGenerating extends MealPlanState {
  const MealPlanGenerating(this.loadingText);
  final String loadingText;
  @override
  List<Object?> get props => [loadingText];
}

class MealPlanError extends MealPlanState {
  const MealPlanError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

class MealPlanCubit extends Cubit<MealPlanState> {
  MealPlanCubit({
    required GetWeekPlan getWeekPlan,
    required AddMealToDay addMealToDay,
    required RemoveMealFromDay removeMealFromDay,
    required GenerateAIPlan generateAIPlan,
    required SharedPreferences prefs,
  })  : _getWeekPlan = getWeekPlan,
        _addMealToDay = addMealToDay,
        _removeMealFromDay = removeMealFromDay,
        _generateAIPlan = generateAIPlan,
        _prefs = prefs,
        super(const MealPlanInitial());

  final GetWeekPlan _getWeekPlan;
  final AddMealToDay _addMealToDay;
  final RemoveMealFromDay _removeMealFromDay;
  final GenerateAIPlan _generateAIPlan;
  final SharedPreferences _prefs;

  Timer? _loadingTextTimer;

  static const _loadingTexts = [
    'Analyzing your preferences…',
    'Finding the best recipes…',
    'Building your week…',
  ];

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadWeekPlan([DateTime? weekStart]) async {
    final start = _mondayOf(weekStart ?? DateTime.now());
    final weekKey = start.toWeekKey();

    emit(const MealPlanLoading());

    final result = await _getWeekPlan(weekKey);
    if (isClosed) return;

    result.fold(
      (f) => emit(MealPlanError(_mapFailure(f))),
      (plan) => emit(MealPlanLoaded(
        plan: plan,
        selectedDay: _todayOrFirstDay(start),
        currentWeekStart: start,
      )),
    );
  }

  // ── Day selection ─────────────────────────────────────────────────────────

  void selectDay(DateTime day) {
    final current = state;
    if (current is! MealPlanLoaded) return;
    emit(current.copyWith(selectedDay: day));
  }

  // ── Week navigation ───────────────────────────────────────────────────────

  Future<void> nextWeek() async {
    final current = state;
    if (current is! MealPlanLoaded) return;
    await loadWeekPlan(current.currentWeekStart.add(const Duration(days: 7)));
  }

  Future<void> previousWeek() async {
    final current = state;
    if (current is! MealPlanLoaded) return;
    await loadWeekPlan(
        current.currentWeekStart.subtract(const Duration(days: 7)));
  }

  // ── Meal CRUD ─────────────────────────────────────────────────────────────

  Future<void> addMeal(
      DateTime date, String mealType, MealItem item) async {
    final current = state;
    if (current is! MealPlanLoaded) return;

    final result = await _addMealToDay(
        current.plan.weekKey, date, mealType, item);
    if (isClosed) return;

    result.fold(
      (f) => emit(MealPlanError(_mapFailure(f))),
      (_) => loadWeekPlan(current.currentWeekStart),
    );
  }

  Future<void> removeMeal(
      DateTime date, String mealType, int recipeId) async {
    final current = state;
    if (current is! MealPlanLoaded) return;

    final result = await _removeMealFromDay(
        current.plan.weekKey, date, mealType, recipeId);
    if (isClosed) return;

    result.fold(
      (f) => emit(MealPlanError(_mapFailure(f))),
      (_) => loadWeekPlan(current.currentWeekStart),
    );
  }

  // ── AI generation ─────────────────────────────────────────────────────────

  Future<void> generateAIPlan({
    required String goal,
    required int calorieTarget,
    required int mealsPerDay,
    bool usePreferences = true,
  }) async {
    final weekStart = _mondayOf(DateTime.now());
    final weekKey = weekStart.toWeekKey();

    // Read saved dietary preferences if requested.
    final dietaryPrefs = usePreferences
        ? (_prefs.getStringList('dietary_preferences') ?? [])
        : <String>[];

    // Start cycling loading text.
    int textIndex = 0;
    emit(MealPlanGenerating(_loadingTexts[0]));

    _loadingTextTimer?.cancel();
    _loadingTextTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (isClosed) return;
      textIndex = (textIndex + 1) % _loadingTexts.length;
      emit(MealPlanGenerating(_loadingTexts[textIndex]));
    });

    final result = await _generateAIPlan(
      goal: goal,
      calorieTarget: calorieTarget,
      mealsPerDay: mealsPerDay,
      dietaryPrefs: dietaryPrefs,
      weekKey: weekKey,
      weekStart: weekStart,
    );

    _loadingTextTimer?.cancel();
    if (isClosed) return;

    result.fold(
      (f) => emit(MealPlanError(_mapFailure(f))),
      (plan) => emit(MealPlanLoaded(
        plan: plan,
        selectedDay: _todayOrFirstDay(weekStart),
        currentWeekStart: weekStart,
      )),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the Monday of the week containing [date].
  static DateTime _mondayOf(DateTime date) {
    final weekday = date.weekday; // 1=Mon … 7=Sun
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  DateTime _todayOrFirstDay(DateTime weekStart) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (!todayOnly.isBefore(weekStart) && !todayOnly.isAfter(weekEnd)) {
      return todayOnly;
    }
    return weekStart;
  }

  String _mapFailure(Failure f) => switch (f) {
        NetworkFailure(:final message) => message,
        QuotaExceededFailure() =>
          'API quota exceeded. Please try again later.',
        TimeoutFailure() => 'Request timed out. Check your connection.',
        ServerFailure(:final message) => message,
        _ => 'Something went wrong. Please try again.',
      };

  @override
  Future<void> close() {
    _loadingTextTimer?.cancel();
    return super.close();
  }
}
