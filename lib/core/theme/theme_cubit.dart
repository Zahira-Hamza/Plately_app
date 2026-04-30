import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// The theme mode selected by the user.
enum AppThemeMode { light, dark, system }

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────

/// Controls the app-wide [ThemeMode].
///
/// Persists the user's preference via [SharedPreferences].
class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  // ── Internal helpers ──────────────────────────────────────────────────────

  static AppThemeMode _load(SharedPreferences prefs) {
    final saved = prefs.getString(AppConstants.prefThemeMode);
    return switch (saved) {
      'dark' => AppThemeMode.dark,
      'light' => AppThemeMode.light,
      _ => AppThemeMode.system,
    };
  }

  String _toKey(AppThemeMode mode) => switch (mode) {
        AppThemeMode.dark => 'dark',
        AppThemeMode.light => 'light',
        AppThemeMode.system => 'system',
      };

  // ── Public API ────────────────────────────────────────────────────────────

  void setLight() => _save(AppThemeMode.light);
  void setDark() => _save(AppThemeMode.dark);
  void setSystem() => _save(AppThemeMode.system);

  void _save(AppThemeMode mode) {
    _prefs.setString(AppConstants.prefThemeMode, _toKey(mode));
    emit(mode);
  }

  /// Converts [AppThemeMode] to Flutter's [ThemeMode].
  static ThemeMode toFlutterThemeMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };
}
