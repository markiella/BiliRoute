import 'package:flutter/material.dart';

/// Central color palette for BiliRoute.
/// All colors are constant for optimal performance.
class AppColors {
  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primary     = Color(0xFF1E3A8A); // Deep navy blue
  static const Color primarySoft = Color(0xFF3B82F6); // Medium blue
  static const Color secondary   = Color(0xFF2563EB); // Bright blue
  static const Color accent      = Color(0xFFFB923C); // Orange highlight
  static const Color accentSoft  = Color(0xFF14B8A6); // Teal

  // ── BiliRoute brand palette ───────────────────────────────────────────────
  static const Color navyBlue  = Color(0xFF0A2E73); // Navy
  static const Color royalBlue = Color(0xFF1458D4); // Royal Blue
  static const Color teal      = Color(0xFF15C6D9); // Teal Accent
  static const Color oceanCyan = Color(0xFF4DD9E8); // Ocean Cyan

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Green — safe routes
  static const Color warning = Color(0xFFF59E0B); // Amber — moderate risk
  static const Color danger  = Color(0xFFEF4444); // Red — high risk
  static const Color info    = Color(0xFF6366F1); // Indigo — general info

  // ── Neutral Colors ────────────────────────────────────────────────────────
  static const Color backgroundStart  = Color(0xFFF8FAFC);
  static const Color backgroundEnd    = Color(0xFFF1F5F9);
  static const Color textPrimary      = Color(0xFF0F172A);
  static const Color textSecondary    = Color(0xFF64748B);
  static const Color cardBackground   = Color(0xFFFFFFFF);
  static const Color divider          = Color(0xFFE2E8F0);
  static const Color white            = Colors.white;

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundStart, backgroundEnd],
  );

  static const LinearGradient homeBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5FF), Color(0xFFFFFBEB)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primarySoft],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFF97316)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, accentSoft],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dark Mode Palette
// ─────────────────────────────────────────────────────────────────────────────

class DarkColors {
  static const Color background = Color(0xFF0E1726);
  static const Color card       = Color(0xFF16213A);
  static const Color elevated   = Color(0xFF1C2B4A); // slightly lighter card
  static const Color inputFill  = Color(0xFF1A2540);
  static const Color text       = Color(0xFFFFFFFF);
  static const Color subtext    = Color(0xFFAAB6C5);
  static const Color divider    = Color(0xFF1E2E4A);
  static const Color success    = Color(0xFF36C275);
  static const Color border     = Color(0xFF233055);
}
