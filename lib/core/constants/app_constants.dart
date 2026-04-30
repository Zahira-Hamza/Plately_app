/// Global application constants.
abstract final class AppConstants {
  // ── API Endpoints ───────────────────────────────────────────────────────
  static const String spoonacularBaseUrl = 'https://api.spoonacular.com';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // ── API Keys (replace before shipping) ──────────────────────────────────
  // TODO: replace with real keys via dart-define or env file
  static const String spoonacularApiKey = 'YOUR_SPOONACULAR_KEY';
  static const String geminiApiKey = 'YOUR_GEMINI_KEY';

  // ── Hive Box Names ──────────────────────────────────────────────────────
  static const String hiveRecipesBox = 'saved_recipes';
  static const String hiveMealPlanBox = 'meal_plans';
  static const String hiveCacheBox = 'recipe_cache';

  // ── SharedPreferences Keys ──────────────────────────────────────────────
  static const String prefOnboardingDone = 'onboarding_complete';
  static const String prefUserName = 'user_name';
  static const String prefDietaryPrefs = 'dietary_preferences';
  static const String prefAllergyPrefs = 'allergy_preferences';
  static const String prefCalorieTarget = 'calorie_target';
  static const String prefThemeMode = 'theme_mode';
}
