import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BiliRoute Admin Color Palette
// ─────────────────────────────────────────────────────────────────────────────

class AdminColors {
  AdminColors._();

  // ── BiliRoute Brand ────────────────────────────────────────────────────────
  static const Color navyBlue    = Color(0xFF0A2E73);  // sidebar background
  static const Color royalBlue   = Color(0xFF1458D4);  // primary actions
  static const Color teal        = Color(0xFF15C6D9);  // accent / highlights
  static const Color oceanCyan   = Color(0xFF4DD9E8);  // secondary accent

  // ── Sidebar ─────────────────────────────────────────────────────────────────
  static const Color sidebarBg        = navyBlue;
  static const Color sidebarActive    = Color(0xFF1A4896); // lighter navy
  static const Color sidebarHover     = Color(0xFF0F3A8A);
  static const Color sidebarText      = Color(0xFFCBD5E1);
  static const Color sidebarActiveText= Colors.white;
  static const Color sidebarIcon      = Color(0xFF94A3B8);
  static const Color sidebarActiveIcon= teal;
  static const Color sidebarDivider   = Color(0xFF1E3A6E);

  // ── Content Area ─────────────────────────────────────────────────────────
  static const Color contentBg    = Color(0xFFF0F4F8);  // slate-100
  static const Color cardBg       = Colors.white;
  static const Color cardBorder   = Color(0xFFE2E8F0);
  static const Color cardShadow   = Color(0x0A000000);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted     = Color(0xFF94A3B8);
  static const Color textOnDark    = Colors.white;

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color success   = Color(0xFF10B981);  // published / verified
  static const Color warning   = Color(0xFFF59E0B);  // pending / field surveyed
  static const Color danger    = Color(0xFFEF4444);  // archived / suspended
  static const Color info      = Color(0xFF3B82F6);  // verified (intermediate)
  static const Color neutral   = Color(0xFF94A3B8);  // draft / inactive

  // ── Module accent colors (for dashboard cards) ────────────────────────────
  static const Color destinationAccent = teal;
  static const Color routeAccent       = royalBlue;
  static const Color providerAccent    = Color(0xFF10B981);
  static const Color advisoryAccent    = Color(0xFFF59E0B);
  static const Color surveyAccent      = Color(0xFF8B5CF6);
  static const Color userAccent        = Color(0xFF06B6D4);

  // ── Table ─────────────────────────────────────────────────────────────────
  static const Color tableHeader   = Color(0xFFF8FAFC);
  static const Color tableRowHover = Color(0xFFF1F5F9);
  static const Color tableBorder   = Color(0xFFE2E8F0);

  // ── Input ─────────────────────────────────────────────────────────────────
  static const Color inputBorder       = Color(0xFFCBD5E1);
  static const Color inputBorderFocus  = royalBlue;
  static const Color inputFill         = Color(0xFFF8FAFC);
}
