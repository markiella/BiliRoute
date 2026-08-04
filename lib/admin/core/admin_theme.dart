import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminTheme — Material ThemeData for the admin portal
// ─────────────────────────────────────────────────────────────────────────────

class AdminTheme {
  AdminTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3:     true,
    colorScheme:      _colorScheme,
    scaffoldBackgroundColor: AdminColors.contentBg,
    textTheme:        _textTheme,
    appBarTheme:      _appBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme:  _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme:        _cardTheme,
    dividerTheme:     const DividerThemeData(
      color:     AdminColors.tableBorder,
      thickness: 1,
      space:     1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AdminColors.tableHeader,
      selectedColor:   AdminColors.royalBlue.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AdminColors.cardBorder),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AdminColors.textPrimary,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
    ),
  );

  // ── Color Scheme ───────────────────────────────────────────────────────────

  static const ColorScheme _colorScheme = ColorScheme(
    brightness:   Brightness.light,
    primary:      AdminColors.royalBlue,
    onPrimary:    Colors.white,
    secondary:    AdminColors.teal,
    onSecondary:  Colors.white,
    surface:      AdminColors.cardBg,
    onSurface:    AdminColors.textPrimary,
    error:        AdminColors.danger,
    onError:      Colors.white,
  );

  // ── Text Theme ─────────────────────────────────────────────────────────────

  static TextTheme get _textTheme => TextTheme(
    displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
    displayMedium:GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
    headlineLarge:GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
    headlineMedium:GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
    headlineSmall:GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
    titleLarge:   GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
    titleMedium:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
    titleSmall:   GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
    bodyLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AdminColors.textPrimary),
    bodyMedium:   GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: AdminColors.textSecondary),
    bodySmall:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AdminColors.textMuted),
    labelLarge:   GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
    labelMedium:  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AdminColors.textSecondary),
    labelSmall:   GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AdminColors.textMuted),
  );

  // ── App Bar ────────────────────────────────────────────────────────────────

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AdminColors.cardBg,
    foregroundColor: AdminColors.textPrimary,
    elevation:       0,
    scrolledUnderElevation: 1,
    shadowColor:     AdminColors.cardShadow,
    surfaceTintColor:Colors.transparent,
    centerTitle:     false,
  );

  // ── Buttons ────────────────────────────────────────────────────────────────

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.royalBlue,
          foregroundColor: Colors.white,
          elevation:       0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.royalBlue,
          side: const BorderSide(color: AdminColors.royalBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AdminColors.royalBlue,
      textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // ── Input Decoration ───────────────────────────────────────────────────────

  static InputDecorationTheme get _inputDecorationTheme =>
      InputDecorationTheme(
        filled:      true,
        fillColor:   AdminColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.inputBorderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.danger),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: AdminColors.textSecondary),
        hintStyle:  GoogleFonts.inter(fontSize: 13, color: AdminColors.textMuted),
      );

  // ── Card Theme ─────────────────────────────────────────────────────────────

  static CardThemeData get _cardTheme => CardThemeData(
    color:         AdminColors.cardBg,
    elevation:     0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AdminColors.cardBorder),
    ),
    margin: EdgeInsets.zero,
  );
}
