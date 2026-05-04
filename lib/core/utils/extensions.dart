import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BuildContext extensions
// ─────────────────────────────────────────────────────────────────────────────

/// Toast message type — controls the SnackBar colour.
enum ToastType { success, error, info }

extension BuildContextX on BuildContext {
  /// The device screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The device screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Shows a themed [SnackBar] toast.
  ///
  /// ```dart
  /// context.showToast('Recipe saved!', ToastType.success);
  /// ```
  void showToast(String message, {ToastType type = ToastType.info}) {
    final Color bgColor = switch (type) {
      ToastType.success => const Color(0xFF2C694E),
      ToastType.error => const Color(0xFFBA1A1A),
      ToastType.info => const Color(0xFF313030),
    };

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// String extensions
// ─────────────────────────────────────────────────────────────────────────────

extension StringX on String {
  /// Capitalises the first character of the string.
  ///
  /// ```dart
  /// 'hello'.capitalize(); // 'Hello'
  /// ```
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts the string to title case (each word capitalised).
  ///
  /// ```dart
  /// 'pasta bake'.toTitleCase(); // 'Pasta Bake'
  /// ```
  String toTitleCase() {
    return split(' ').map((w) => w.capitalize()).join(' ');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DateTime extensions
// ─────────────────────────────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  /// Returns ISO week key e.g. "2024-W18"
  String toWeekKey() {
    final thursday = add(Duration(days: 4 - weekday));
    final week =
        ((thursday.difference(DateTime(thursday.year)).inDays) ~/ 7) + 1;
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }

  /// Returns time-based greeting string.
  String greeting() {
    final h = hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// double extensions
// ─────────────────────────────────────────────────────────────────────────────

extension DoubleX on double {
  /// Formats the value as a human-readable calories string.
  ///
  /// ```dart
  /// 420.0.toCaloriesString(); // '420 kcal'
  /// ```
  String toCaloriesString() => '${toStringAsFixed(0)} kcal';
}

// ─────────────────────────────────────────────────────────────────────────────
// int extensions
// ─────────────────────────────────────────────────────────────────────────────

extension IntX on int {
  /// Formats the value as a human-readable minutes string.
  ///
  /// ```dart
  /// 30.toMinutesString(); // '30 min'
  /// ```
  String toMinutesString() => '$this min';
}
