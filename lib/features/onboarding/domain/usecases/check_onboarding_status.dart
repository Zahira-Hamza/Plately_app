import '../../data/local_datasource.dart';

/// Returns `true` if the user has already completed onboarding.
class CheckOnboardingStatus {
  const CheckOnboardingStatus(this._datasource);

  final OnboardingLocalDatasource _datasource;

  bool call() => _datasource.getOnboardingComplete();
}
