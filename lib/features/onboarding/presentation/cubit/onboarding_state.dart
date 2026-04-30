import 'package:equatable/equatable.dart';

/// All possible states for [OnboardingCubit].
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state — cubit just constructed, no work started.
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Checking SharedPreferences for onboarding flag.
class OnboardingChecking extends OnboardingState {
  const OnboardingChecking();
}

/// Onboarding has NOT been completed — show onboarding flow.
class OnboardingNotDone extends OnboardingState {
  const OnboardingNotDone();
}

/// Onboarding is already done — go straight to /home.
class OnboardingDone extends OnboardingState {
  const OnboardingDone();
}

/// Dietary preferences were saved successfully.
class PreferencesSaved extends OnboardingState {
  const PreferencesSaved();
}
