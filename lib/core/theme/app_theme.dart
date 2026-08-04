import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base         = ThemeData.light(useMaterial3: true);
    final colorScheme  = ColorScheme.fromSeed(
      seedColor:  AppColors.primary,
      brightness: Brightness.light,
      primary:    AppColors.primary,
      secondary:  AppColors.accentSoft,
      surface:    Colors.white,
      onSurface:  AppColors.textPrimary,
    );

    return _base(base, colorScheme);
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base        = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor:   AppColors.royalBlue,
      brightness:  Brightness.dark,
      primary:     AppColors.royalBlue,
      secondary:   AppColors.teal,
      surface:     DarkColors.card,
      onSurface:   DarkColors.text,
      surfaceContainerHighest: DarkColors.card,
    ).copyWith(
      surface:    DarkColors.background,
      onSurface:  DarkColors.text,
      primary:    AppColors.royalBlue,
      secondary:  AppColors.teal,
      error:      const Color(0xFFEF4444),
    );

    return _base(base, colorScheme).copyWith(
      scaffoldBackgroundColor: DarkColors.background,
      dividerColor:            DarkColors.divider,
      cardColor:               DarkColors.card,
    );
  }

  // ── Shared base builder ────────────────────────────────────────────────────
  static ThemeData _base(ThemeData base, ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3:           true,
      colorScheme:            colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.inter(
          fontSize:   14,
          fontWeight: FontWeight.w400,
          height:     1.35,
          color:      colorScheme.onSurface,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor:        Colors.transparent,
        elevation:              0,
        scrolledUnderElevation: 0,
        surfaceTintColor:       Colors.transparent,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.20),
        ),
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color:      colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color:     colorScheme.brightness == Brightness.dark
                      ? DarkColors.card
                      : Colors.white,
        elevation: 0,
        shape:     RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   colorScheme.brightness == Brightness.dark
                        ? DarkColors.inputFill
                        : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
