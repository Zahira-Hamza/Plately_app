import 'package:flutter/material.dart';

/// Plately color palette — locked design tokens.
///
/// Never reference raw hex values anywhere else in the codebase.
/// Always use these named constants.
abstract final class AppColors {
  // ── Backgrounds ───────────────────────────────────────────────────────────

  /// Warm off-white — screen scaffold background.
  static const Color background = Color(0xFFFCFAF8);

  /// Pure white — cards and surfaces only.
  static const Color cardSurface = Color(0xFFFFFFFF);

  /// Slightly tinted surface — used for input backgrounds, tab bar, etc.
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);

  /// Light surface container — chip borders, divider-adjacent fills.
  static const Color surfaceContainer = Color(0xFFF0EDED);

  /// Dark inverse surface — info toasts, dark overlays.
  static const Color inverseSurface = Color(0xFF313030);

  // ── Brand ─────────────────────────────────────────────────────────────────

  /// Terracotta — primary buttons, active states, badges.
  static const Color primary = Color(0xFFA63500);

  /// Lighter terracotta — pressed / hover states.
  static const Color primaryContainer = Color(0xFFCC4911);

  /// Sage green — saved/success states, secondary actions.
  static const Color secondary = Color(0xFF2C694E);

  // ── Text ──────────────────────────────────────────────────────────────────

  /// Near-black — primary headings and body text.
  static const Color textPrimary = Color(0xFF1C1B1B);

  /// Warm brown — subtitles, captions, secondary labels.
  static const Color textSecondary = Color(0xFF594139);

  // ── Border & divider ──────────────────────────────────────────────────────

  /// Default border / icon color.
  static const Color outline = Color(0xFF8D7168);

  /// Light warm divider / chip border.
  static const Color outlineVariant = Color(0xFFE1BFB4);

  // ── Accent fills ──────────────────────────────────────────────────────────

  /// Light terracotta tint — dietary tag backgrounds.
  static const Color tagBackground = Color(0xFFFFF3EE);

  // ── Semantic ──────────────────────────────────────────────────────────────

  /// Error red.
  static const Color error = Color(0xFFBA1A1A);

  /// Light error fill.
  static const Color errorContainer = Color(0xFFFFDAD6);

  // ── Shimmer ───────────────────────────────────────────────────────────────

  /// Shimmer animation base color.
  static const Color shimmerBase = Color(0xFFF0F0F0);

  /// Shimmer animation highlight color.
  static const Color shimmerHighlight = Color(0xFFE0E0E0);
}
