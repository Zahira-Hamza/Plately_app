import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Global application constants.
///
/// API keys are loaded from the `.env` file at runtime via [flutter_dotenv].
/// Never hardcode keys here.
abstract final class AppConstants {
  // ── API Endpoints ────────────────────────────────────────────────────────

  static const String spoonacularBaseUrl = 'https://api.spoonacular.com';

  static const String grokBaseUrl = 'https://api.groq.com/openai/v1';

  // ── API Keys (loaded from .env at runtime) ───────────────────────────────

  /// Spoonacular key — set SPOONACULAR_API_KEY in .env
  static String get spoonacularApiKey =>
      dotenv.env['SPOONACULAR_API_KEY'] ?? '';

  /// xAI Grok key — set GROK_API_KEY in .env
  static String get grokApiKey => dotenv.env['GROK_API_KEY'] ?? '';

  // ── Hive Box Names ───────────────────────────────────────────────────────

  static const String hiveRecipesBox = 'saved_recipes';
  static const String hiveMealPlanBox = 'meal_plans';
  static const String hiveCacheBox = 'recipe_cache';

  // ── SharedPreferences Keys ───────────────────────────────────────────────

  static const String prefOnboardingDone = 'onboarding_complete';
  static const String prefUserName = 'user_name';
  static const String prefDietaryPrefs = 'dietary_preferences';
  static const String prefAllergyPrefs = 'allergy_preferences';
  static const String prefCalorieTarget = 'calorie_target';
  static const String prefThemeMode = 'theme_mode';
}
