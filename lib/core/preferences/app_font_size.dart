// ─────────────────────────────────────────────────────────────────────────────
// AppFontSize — enumeration of user-selectable text scale levels
// ─────────────────────────────────────────────────────────────────────────────

/// Three font size levels available to users in BiliRoute Accessibility Settings.
///
/// Maps to [TextScaler.linear] values applied globally via MediaQuery so that
/// all Flutter text widgets scale consistently without modifying individual
/// widget font sizes.
enum AppFontSize {
  small,
  medium,
  large;

  /// Human-readable label used in the Accessibility settings UI.
  String get label {
    switch (this) {
      case AppFontSize.small:
        return 'Small';
      case AppFontSize.medium:
        return 'Medium';
      case AppFontSize.large:
        return 'Large';
    }
  }

  /// TextScaler multiplier applied to the system text scale.
  ///
  /// medium = 1.0 → preserves the original BiliRoute typography
  /// small  = 0.87 → slightly reduced for compact displays
  /// large  = 1.20 → increased for visual accessibility
  double get scaleFactor {
    switch (this) {
      case AppFontSize.small:
        return 0.87;
      case AppFontSize.medium:
        return 1.0;
      case AppFontSize.large:
        return 1.20;
    }
  }

  /// Parses a SharedPreferences-stored string back to an [AppFontSize].
  static AppFontSize fromString(String? value) {
    switch (value) {
      case 'small':
        return AppFontSize.small;
      case 'large':
        return AppFontSize.large;
      default:
        return AppFontSize.medium;
    }
  }
}
