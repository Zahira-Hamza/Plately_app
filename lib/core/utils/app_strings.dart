/// All user-visible strings in one place.
/// Import this class wherever localised text is needed.
abstract final class AppStrings {
  // ── App Identity ─────────────────────────────────────────────────────────
  static const String appName = 'Plately';
  static const String tagline = 'Your AI-powered recipe & meal planner';

  // ── Greetings ────────────────────────────────────────────────────────────
  static const String greetingMorning = 'Good morning';
  static const String greetingAfternoon = 'Good afternoon';
  static const String greetingEvening = 'Good evening';

  // ── Search ───────────────────────────────────────────────────────────────
  static const String searchHint = 'Search recipes, ingredients…';

  // ── Empty / No Results ───────────────────────────────────────────────────
  static const String noResultsTitle = 'No results found';
  static const String noResultsSubtitle =
      'Try different keywords or adjust your filters';

  // ── Offline ──────────────────────────────────────────────────────────────
  static const String offlineTitle = 'You\'re offline';
  static const String offlineSubtitle =
      'Check your internet connection and try again';

  // ── Saved Recipes (empty state) ──────────────────────────────────────────
  static const String savedEmptyTitle = 'No saved recipes yet';
  static const String savedEmptySubtitle =
      'Tap the heart on any recipe to save it here';

  // ── Meal Plan (empty state) ──────────────────────────────────────────────
  static const String mealPlanEmptyTitle = 'No meal plan yet';
  static const String mealPlanEmptySubtitle =
      'Generate a personalised weekly plan with AI';

  // ── AI Generation Loading ─────────────────────────────────────────────────
  static const String generatePlanLoading1 = 'Analyzing your preferences…';
  static const String generatePlanLoading2 = 'Finding the best recipes…';
  static const String generatePlanLoading3 = 'Building your week…';

  // ── Toast / Snackbar ──────────────────────────────────────────────────────
  static const String toastSaveSuccess = 'Recipe saved!';
  static const String toastError = 'Something went wrong. Please try again.';
  static const String toastPlanGenerated = 'Your meal plan is ready!';

  // ── Errors ────────────────────────────────────────────────────────────────
  static const String errorInvalidKey =
      'Invalid API key. Please check your settings.';
  static const String errorQuotaExceeded =
      'API quota exceeded. Please try again later.';
  static const String errorNoInternet =
      'No internet connection. Check your network and retry.';
  static const String errorTimeout =
      'The request timed out. Please try again.';
}
