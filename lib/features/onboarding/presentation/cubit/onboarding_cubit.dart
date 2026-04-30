import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/check_onboarding_status.dart';
import '../../domain/usecases/complete_onboarding.dart';
import 'onboarding_state.dart';

/// Drives all onboarding logic: status checking, preference saving.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required CheckOnboardingStatus checkOnboardingStatus,
    required CompleteOnboarding completeOnboarding,
  })  : _checkStatus = checkOnboardingStatus,
        _completeOnboarding = completeOnboarding,
        super(const OnboardingInitial());

  final CheckOnboardingStatus _checkStatus;
  final CompleteOnboarding _completeOnboarding;

  /// Checks whether the user has already completed onboarding.
  Future<void> checkStatus() async {
    emit(const OnboardingChecking());
    // Simulate a brief delay so the splash animation is visible.
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    final done = _checkStatus();
    emit(done ? const OnboardingDone() : const OnboardingNotDone());
  }

  /// Saves preferences (if any) and marks onboarding as complete.
  Future<void> savePreferencesAndComplete({
    List<String> preferences = const [],
    List<String> allergies = const [],
  }) async {
    await _completeOnboarding(
      preferences: preferences,
      allergies: allergies,
    );
    emit(const PreferencesSaved());
  }
}
