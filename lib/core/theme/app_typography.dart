import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Plately typography system.
///
/// Fonts used:
///   - Newsreader      → display / title (editorial serif)
///   - Be Vietnam Pro  → body text (clean humanist sans)
///   - Work Sans       → labels / UI chrome
///   - Space Grotesk   → stats / data
abstract final class AppTypography {
  // ── Display ───────────────────────────────────────────────────────────────

  /// Hero headlines — 40 px, Newsreader SemiBold
  static TextStyle get displayLarge => GoogleFonts.newsreader(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8, // -0.02 em
      );

  /// Section headers — 32 px, Newsreader Medium
  static TextStyle get displayMedium => GoogleFonts.newsreader(
        fontSize: 32,
        fontWeight: FontWeight.w500,
      );

  // ── Title ─────────────────────────────────────────────────────────────────

  /// Screen / dialog titles — 24 px, Newsreader Medium
  static TextStyle get titleLarge => GoogleFonts.newsreader(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      );

  /// Card titles — 18 px, Newsreader Medium
  ///
  /// Used by [RecipeCard] and detail screen sub-headings.
  static TextStyle get titleSmall => GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  // ── Body ──────────────────────────────────────────────────────────────────

  /// Primary reading body — 18 px, Be Vietnam Pro Regular
  static TextStyle get bodyLarge => GoogleFonts.beVietnamPro(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  /// Secondary body / descriptions — 16 px, Be Vietnam Pro Regular
  static TextStyle get bodyMedium => GoogleFonts.beVietnamPro(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  // ── Label ─────────────────────────────────────────────────────────────────

  /// UI chrome, buttons, chips — 14 px, Work Sans Medium
  static TextStyle get labelMedium => GoogleFonts.workSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.14, // 0.01 em
      );

  /// Small helper labels, badges — 12 px, Work Sans Medium
  ///
  /// Used by difficulty badges, filter chips, and caption text.
  static TextStyle get labelSmall => GoogleFonts.workSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.12,
      );

  // ── Stats ─────────────────────────────────────────────────────────────────

  /// Numeric stats / data — 14 px, Space Grotesk Medium
  static TextStyle get statsStyle => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );
}
