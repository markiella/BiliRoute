import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/theme/app_colors.dart';
import '../features/fare/fare_guide_screen.dart';
import '../features/home/home_page.dart';
import '../features/itinerary/input/plan_trip_screen.dart';
import '../features/map/map_preview_screen.dart';
import '../features/profile/profile_screen.dart';
import '../l10n/app_localizations.dart';

// ── Tab model ──────────────────────────────────────────────────────────────────

class _NavTab {
  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String   label;
}

/// Root navigation shell for BiliRoute.
///
/// Navigation structure:
///   • Floating white capsule pill (rounded pill with side margins)
///   • Large elevated gradient circle centre button (Routes / Find Route)
///   • 4 icon + label tabs flanking the centre
///
/// Tab indices:
///   0 = Home
///   1 = Routes (CENTRE elevated button)
///   2 = Map
///   3 = Fare
///   4 = Profile
///
/// Note: Travel advisories are now surfaced directly on the HomePage
///       via the TravelAdvisorySection widget — no longer a standalone tab.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  // Maps the 4 visual pill slot positions → actual IndexedStack indices
  // Slot:  [0=Home]  [1=Map]  [gap]  [2=Fare]  [3=Profile]
  // Index: [0]       [2]              [3]        [4]
  static const _tabIndices = [0, 2, 3, 4];

  /// Build the 4 localized nav tabs from AppLocalizations.
  List<_NavTab> _buildTabs(AppLocalizations l10n) => [
    _NavTab(icon: Icons.home_outlined,    activeIcon: Icons.home_rounded,    label: l10n.navHome),
    _NavTab(icon: Icons.map_outlined,     activeIcon: Icons.map_rounded,     label: l10n.navMap),
    _NavTab(icon: Icons.payments_outlined, activeIcon: Icons.payments_rounded, label: l10n.navFare),
    _NavTab(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: l10n.navProfile),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n    = AppLocalizations.of(context)!;
    final tabs    = _buildTabs(l10n);
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    // Height of the full floating assembly (pill + circle protrusion above pill)
    const pillH      = 64.0; // logical pixels — scaled with .h
    const circleSize = 60.0; // slightly larger for the prominent Routes action
    const protrusion = 16.0; // how many lp the circle rises above the pill top

    final navBarH      = (pillH + protrusion).h;
    final navClearance = navBarH + 20.h; // extra spacing for scrollable content

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : AppColors.backgroundStart,
      body: Stack(
        children: [
          // ── Tab screens (IndexedStack preserves state between tabs) ────────
          IndexedStack(
            index: _currentIndex,
            children: [
              // 0: Home — includes TravelAdvisorySection
              HomePage(onSwitchTab: _switchTab, navClearance: navClearance),
              // 1: Routes / Find Route — centre button
              PlanTripScreen(navClearance: navClearance),
              // 2: Map
              MapPreviewScreen(navClearance: navClearance),
              // 3: Fare Guide
              FareGuideScreen(navClearance: navClearance),
              // 4: Profile (replaces former Safety tab)
              ProfileScreen(navClearance: navClearance),
            ],
          ),

          // ── Floating capsule nav bar ──────────────────────────────────────
          Positioned(
            bottom: 18.h,
            left:   20.w,
            right:  20.w,
            child: _CapsuleNavBar(
              tabs:         tabs,
              tabIndices:   _tabIndices,
              currentIndex: _currentIndex,
              onTap:        _switchTab,
              pillHeight:   pillH.h,
              circleSize:   circleSize.r,
              protrusion:   protrusion.h,
              centreLabel:  l10n.navRoutes,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Floating capsule nav bar ───────────────────────────────────────────────────

class _CapsuleNavBar extends StatelessWidget {
  const _CapsuleNavBar({
    required this.tabs,
    required this.tabIndices,
    required this.currentIndex,
    required this.onTap,
    required this.pillHeight,
    required this.circleSize,
    required this.protrusion,
    required this.centreLabel,
  });

  final List<_NavTab>     tabs;
  final List<int>         tabIndices;
  final int               currentIndex;
  final ValueChanged<int> onTap;
  final double            pillHeight;
  final double            circleSize;
  final double            protrusion;
  final String            centreLabel;

  // Index 1 = Routes / Find Route (centre elevated button)
  static const int _planIndex = 1;

  @override
  Widget build(BuildContext context) {
    final totalH = pillHeight + protrusion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: totalH,
      child: Stack(
        clipBehavior: Clip.none,
        alignment:    Alignment.bottomCenter,
        children: [

          // ── 1. Floating white capsule pill ──────────────────────────────
          Positioned(
            bottom: 0,
            left:   0,
            right:  0,
            child: Container(
              height: pillHeight,
              decoration: BoxDecoration(
                color:        isDark ? DarkColors.card : Colors.white,
                borderRadius: BorderRadius.circular(pillHeight / 2),
                border:       isDark ? Border.all(color: DarkColors.border, width: 1) : null,
                boxShadow: [
                  BoxShadow(
                    color:        Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
                    blurRadius:   28,
                    offset:       const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ── Left pair: Home + Map ────────────────────────────────
                  Expanded(
                    child: _PillTab(
                      tab:      tabs[0],
                      selected: tabIndices[0] == currentIndex,
                      onTap:    () => onTap(tabIndices[0]),
                    ),
                  ),
                  Expanded(
                    child: _PillTab(
                      tab:      tabs[1],
                      selected: tabIndices[1] == currentIndex,
                      onTap:    () => onTap(tabIndices[1]),
                    ),
                  ),

                  // ── Centre gap for the elevated circle button ────────────
                  SizedBox(width: circleSize + 16.w),

                  // ── Right pair: Fare + Profile ───────────────────────────
                  Expanded(
                    child: _PillTab(
                      tab:      tabs[2],
                      selected: tabIndices[2] == currentIndex,
                      onTap:    () => onTap(tabIndices[2]),
                    ),
                  ),
                  Expanded(
                    child: _PillTab(
                      tab:      tabs[3],
                      selected: tabIndices[3] == currentIndex,
                      onTap:    () => onTap(tabIndices[3]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 2. Elevated centre Routes button ─────────────────────────
          Positioned(
            bottom: pillHeight * 0.10,
            child: _CentreButton(
              selected: currentIndex == _planIndex,
              size:     circleSize,
              label:    centreLabel,
              onTap:    () => onTap(_planIndex),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.5, end: 0, duration: 480.ms, curve: Curves.easeOutCubic)
        .fade(duration: 380.ms);
  }
}

// ── Centre circle button ───────────────────────────────────────────────────────

/// Large elevated circle — the primary action button for Routes / Find Route.
///
/// Design: deep navy → sky blue gradient with an animated glow on active state.
/// Inspired by TikTok-style centre nav buttons.
class _CentreButton extends StatelessWidget {
  const _CentreButton({
    required this.selected,
    required this.size,
    required this.label,
    required this.onTap,
  });

  final bool         selected;
  final double       size;
  final String       label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:    onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve:    Curves.easeOutBack,
        width:  size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
            colors: [Color(0xFF0A2E73), Color(0xFF3B82F6)],
          ),
          boxShadow: [
            BoxShadow(
              color:        AppColors.primary.withValues(
                              alpha: selected ? 0.50 : 0.28),
              blurRadius:   selected ? 26 : 14,
              offset:       const Offset(0, 6),
              spreadRadius: selected ? 3 : 0,
            ),
            if (selected)
              BoxShadow(
                color:      const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 1,
              ),
          ],
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 280),
          scale:    selected ? 1.08 : 1.0,
          curve:    Curves.easeOutBack,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.route_rounded : Icons.route_outlined,
                color: Colors.white,
                size:  22.sp,
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  color:      Colors.white,
                  fontSize:   8.5.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pill tab item ──────────────────────────────────────────────────────────────

/// Single tab slot inside the floating pill — icon above, label below.
class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _NavTab      tab;
  final bool         selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final activeColor  = isDark ? AppColors.oceanCyan : AppColors.primary;
    final inactiveColor = isDark ? DarkColors.subtext : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap:    onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize:      MainAxisSize.min,
        children: [
          // Icon
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              selected ? tab.activeIcon : tab.icon,
              key:   ValueKey(selected),
              size:  22.sp,
              color: selected ? activeColor : inactiveColor,
            ),
          ),

          SizedBox(height: 3.h),

          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize:   9.5.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color:      selected ? AppColors.primary : const Color(0xFF94A3B8),
            ),
            child: Text(tab.label),
          ),
        ],
      ),
    );
  }
}
