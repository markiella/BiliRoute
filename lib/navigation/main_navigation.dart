import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/theme/app_colors.dart';
import '../features/fare/fare_guide_screen.dart';
import '../features/home/home_page.dart';
import '../features/itinerary/input/plan_trip_screen.dart';
import '../features/map/map_preview_screen.dart';
import '../features/profile/profile_screen.dart';
import '../l10n/app_localizations.dart';

/// Root navigation shell for BiliRoute using standard Material 3 NavigationBar.
///
/// Tab indices:
///   0 = Home
///   1 = Routes (Plan Trip)
///   2 = Map
///   3 = Fare Guide
///   4 = Profile
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

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Standard bottom nav height clearance for scrollable tab content
    final double navClearance = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom + 12.h;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : AppColors.backgroundStart,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: Home
          HomePage(onSwitchTab: _switchTab, navClearance: navClearance),
          // 1: Routes / Plan Trip
          PlanTripScreen(navClearance: navClearance),
          // 2: Map
          MapPreviewScreen(navClearance: navClearance),
          // 3: Fare Guide
          FareGuideScreen(navClearance: navClearance),
          // 4: Profile
          ProfileScreen(navClearance: navClearance),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? DarkColors.card : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? DarkColors.border : AppColors.divider,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 64.h,
            backgroundColor: Colors.transparent,
            indicatorColor: isDark
                ? AppColors.oceanCyan.withValues(alpha: 0.18)
                : AppColors.primary.withValues(alpha: 0.12),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.oceanCyan : AppColors.primary)
                    : (isDark ? DarkColors.subtext : AppColors.textSecondary),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                size: 22.sp,
                color: isSelected
                    ? (isDark ? AppColors.oceanCyan : AppColors.primary)
                    : (isDark ? DarkColors.subtext : AppColors.textSecondary),
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _switchTab,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.route_outlined),
                selectedIcon: const Icon(Icons.route_rounded),
                label: l10n.navRoutes,
              ),
              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map_rounded),
                label: l10n.navMap,
              ),
              NavigationDestination(
                icon: const Icon(Icons.payments_outlined),
                selectedIcon: const Icon(Icons.payments_rounded),
                label: l10n.navFare,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: l10n.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

