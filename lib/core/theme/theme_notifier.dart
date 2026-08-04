import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ThemeNotifier — manages app-wide ThemeMode with SharedPreferences persistence
// ─────────────────────────────────────────────────────────────────────────────

const _kThemePrefKey = 'biliroute_theme_mode';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  /// Load persisted preference. Call once before runApp().
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved  = prefs.getString(_kThemePrefKey);
    _mode = _modeFromString(saved);
    notifyListeners();
  }

  /// Update and persist the theme mode.
  Future<void> setTheme(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemePrefKey, _modeToString(mode));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static ThemeMode _modeFromString(String? value) {
    switch (value) {
      case 'light':  return ThemeMode.light;
      case 'dark':   return ThemeMode.dark;
      default:       return ThemeMode.system;
    }
  }

  static String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:  return 'light';
      case ThemeMode.dark:   return 'dark';
      case ThemeMode.system: return 'system';
    }
  }
}
