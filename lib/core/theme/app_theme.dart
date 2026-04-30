import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Plately [ThemeData] factory.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
/// );
/// ```
abstract final class AppTheme {
  // ─────────────────────────────────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // ── Scaffold & Card ───────────────────────────────────────────────
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardSurface,

        // ── Primary & Secondary ───────────────────────────────────────────
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          secondary: AppColors.secondary,
          surface: AppColors.cardSurface,
          error: AppColors.error,
          errorContainer: AppColors.errorContainer,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          inverseSurface: AppColors.inverseSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimary,
          onError: Colors.white,
        ),

        // ── Text Theme ────────────────────────────────────────────────────
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          displayMedium: AppTypography.displayMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          titleLarge: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          bodyLarge: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          bodyMedium: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          labelMedium: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),

        // ── Input Decoration ──────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),

        // ── Elevated Button ───────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),

        // ── Chip Theme ────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.outlineVariant),
          ),
          backgroundColor: AppColors.cardSurface,
          selectedColor: AppColors.primary,
          labelStyle: AppTypography.labelMedium,
          secondaryLabelStyle: AppTypography.labelMedium.copyWith(
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // ── App Bar ───────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          titleTextStyle: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),

        // ── Divider ───────────────────────────────────────────────────────
        dividerColor: AppColors.outlineVariant,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Dark Theme (placeholder — mirrors light palette with dark overrides)
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1816),
        cardColor: const Color(0xFF2A2624),
        primaryColor: AppColors.primaryContainer,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryContainer,
          primaryContainer: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Color(0xFF2A2624),
          error: AppColors.error,
          errorContainer: AppColors.errorContainer,
          outline: AppColors.outline,
          outlineVariant: Color(0xFF4D3A35),
          inverseSurface: AppColors.background,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFF0EAE7),
          onError: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge.copyWith(
            color: const Color(0xFFF0EAE7),
          ),
          displayMedium: AppTypography.displayMedium.copyWith(
            color: const Color(0xFFF0EAE7),
          ),
          titleLarge: AppTypography.titleLarge.copyWith(
            color: const Color(0xFFF0EAE7),
          ),
          bodyLarge: AppTypography.bodyLarge.copyWith(
            color: const Color(0xFFF0EAE7),
          ),
          bodyMedium: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFFCDB8B0),
          ),
          labelMedium: AppTypography.labelMedium.copyWith(
            color: const Color(0xFFF0EAE7),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF4D3A35)),
          ),
          backgroundColor: const Color(0xFF2A2624),
          selectedColor: AppColors.primaryContainer,
          labelStyle: AppTypography.labelMedium,
          secondaryLabelStyle: AppTypography.labelMedium.copyWith(
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2624),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4D3A35)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4D3A35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryContainer,
              width: 1.5,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1A1816),
          foregroundColor: const Color(0xFFF0EAE7),
          elevation: 0,
          titleTextStyle: AppTypography.titleLarge.copyWith(
            color: const Color(0xFFF0EAE7),
          ),
        ),
        dividerColor: const Color(0xFF4D3A35),
      );
}
