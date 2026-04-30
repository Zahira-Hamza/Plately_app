import '../../data/local_datasource.dart';

/// Persists dietary selections and marks onboarding as complete.
class CompleteOnboarding {
  const CompleteOnboarding(this._datasource);

  final OnboardingLocalDatasource _datasource;

  Future<void> call({
    List<String> preferences = const [],
    List<String> allergies = const [],
  }) async {
    if (preferences.isNotEmpty || allergies.isNotEmpty) {
      await _datasource.saveDietaryPreferences(preferences, allergies);
    }
    await _datasource.setOnboardingComplete();
  }
}
