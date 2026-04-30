import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys for onboarding persistence.
abstract final class _Keys {
  static const String onboardingComplete = 'onboarding_complete';
  static const String dietaryPreferences = 'dietary_preferences';
  static const String allergies = 'allergies';
}

/// Handles all onboarding-related local storage operations.
class OnboardingLocalDatasource {
  const OnboardingLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  /// Returns `true` if the user has completed onboarding.
  bool getOnboardingComplete() =>
      _prefs.getBool(_Keys.onboardingComplete) ?? false;

  /// Marks onboarding as completed.
  Future<void> setOnboardingComplete() =>
      _prefs.setBool(_Keys.onboardingComplete, true);

  /// Saves dietary preference selections and allergy selections.
  Future<void> saveDietaryPreferences(
    List<String> prefs,
    List<String> allergyList,
  ) async {
    await _prefs.setStringList(_Keys.dietaryPreferences, prefs);
    await _prefs.setStringList(_Keys.allergies, allergyList);
  }

  /// Returns saved dietary preferences (empty list if none saved).
  List<String> getDietaryPreferences() =>
      _prefs.getStringList(_Keys.dietaryPreferences) ?? [];

  /// Returns saved allergy list (empty list if none saved).
  List<String> getAllergies() =>
      _prefs.getStringList(_Keys.allergies) ?? [];
}
