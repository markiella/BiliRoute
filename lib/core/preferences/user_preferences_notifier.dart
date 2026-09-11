import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_font_size.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserPreferencesNotifier
//
// Central ChangeNotifier for all device-local user accessibility and
// language preferences in BiliRoute.
//
// Managed preferences:
//   • fontSize  — AppFontSize (small | medium | large)
//   • locale    — Locale (en | es | ...)
//
// Persistence:
//   Uses SharedPreferences with biliroute_* key convention.
//   These are device-local preferences that do NOT require a backend round-trip.
//
// Usage:
//   context.watch<UserPreferencesNotifier>().fontSize
//   context.read<UserPreferencesNotifier>().setFontSize(AppFontSize.large)
// ─────────────────────────────────────────────────────────────────────────────

const _kFontSizeKey = 'biliroute_font_size';
const _kLocaleKey   = 'biliroute_locale';

class UserPreferencesNotifier extends ChangeNotifier {
  AppFontSize _fontSize = AppFontSize.medium;
  Locale      _locale   = const Locale('en');

  // ── Getters ────────────────────────────────────────────────────────────────

  AppFontSize get fontSize    => _fontSize;
  Locale      get locale      => _locale;

  /// TextScaler multiplier consumed by MaterialApp builder to globally scale
  /// all text in the application.
  double get textScaleFactor => _fontSize.scaleFactor;

  /// Returns the language code string used for UI display (e.g. 'en', 'es').
  String get languageCode => _locale.languageCode;

  // ── Load ───────────────────────────────────────────────────────────────────

  /// Load persisted preferences. Call once before runApp().
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Font size
    final savedSize = prefs.getString(_kFontSizeKey);
    _fontSize = AppFontSize.fromString(savedSize);

    // Locale
    final savedLocale = prefs.getString(_kLocaleKey);
    if (savedLocale != null && savedLocale.isNotEmpty) {
      _locale = Locale(savedLocale);
    }
    // No notify needed — called before runApp
  }

  // ── Font Size ──────────────────────────────────────────────────────────────

  /// Update and persist the font size preference.
  Future<void> setFontSize(AppFontSize size) async {
    if (_fontSize == size) return;
    _fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontSizeKey, size.name);
  }

  // ── Locale ─────────────────────────────────────────────────────────────────

  /// Update and persist the app locale.
  /// Rebuilds MaterialApp locale immediately without app restart.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  // ── Supported Locales ──────────────────────────────────────────────────────

  /// All locales supported by BiliRoute.
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Español
    Locale('fr'), // Français
    Locale('de'), // Deutsch
    Locale('ja'), // 日本語
    Locale('ko'), // 한국어
  ];

  /// Display name for a locale — shown in the Language picker UI.
  static String localeDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      case 'ja': return '日本語';
      case 'ko': return '한국어';
      case 'en':
      default:   return 'English';
    }
  }

  /// Flag emoji for a locale — shown in the Language picker UI.
  static String localeFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'es': return '🇪🇸';
      case 'fr': return '🇫🇷';
      case 'de': return '🇩🇪';
      case 'ja': return '🇯🇵';
      case 'ko': return '🇰🇷';
      case 'en':
      default:   return '🇺🇸';
    }
  }
}
