import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/ambient/breathing_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Advisory data model
// ─────────────────────────────────────────────────────────────────────────────

enum AdvisoryLevel {
  high,
  moderate,
  info;

  Color get color {
    switch (this) {
      case AdvisoryLevel.high:     return const Color(0xFFEF4444); // red
      case AdvisoryLevel.moderate: return const Color(0xFFF59E0B); // amber
      case AdvisoryLevel.info:     return const Color(0xFF0EA5E9); // sky blue
    }
  }

  Color get bgColor {
    switch (this) {
      case AdvisoryLevel.high:     return const Color(0xFFFFF1F2);
      case AdvisoryLevel.moderate: return const Color(0xFFFFFBEB);
      case AdvisoryLevel.info:     return const Color(0xFFF0F9FF);
    }
  }

  Color get borderColor {
    switch (this) {
      case AdvisoryLevel.high:     return const Color(0xFFFECACA);
      case AdvisoryLevel.moderate: return const Color(0xFFFDE68A);
      case AdvisoryLevel.info:     return const Color(0xFFBAE6FD);
    }
  }

  String get badge {
    switch (this) {
      case AdvisoryLevel.high:     return 'HIGH RISK';
      case AdvisoryLevel.moderate: return 'ADVISORY';
      case AdvisoryLevel.info:     return 'INFO';
    }
  }

  IconData get pulseIcon {
    switch (this) {
      case AdvisoryLevel.high:     return Icons.warning_rounded;
      case AdvisoryLevel.moderate: return Icons.info_rounded;
      case AdvisoryLevel.info:     return Icons.notifications_rounded;
    }
  }
}

/// Represents a single travel/safety advisory item.
///
/// PROTOTYPE NOTE:
///   All advisories below are static mock data for thesis prototype purposes.
///   In future production implementation, advisories will be dynamically
///   generated from real-time weather API data (e.g., PAGASA, OpenWeatherMap)
///   and cross-referenced with destination risk categories defined by the
///   Biliran Tourism Office.
class TravelAdvisory {
  const TravelAdvisory({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.message,
    required this.level,
    required this.category,
    this.affectedRoutes,
  });

  final IconData        icon;
  final String          emoji;
  final String          title;
  final String          message;
  final AdvisoryLevel   level;
  final String          category;
  final String?         affectedRoutes;
}

// ─────────────────────────────────────────────────────────────────────────────
// Static advisory dataset
//
// PROTOTYPE PHASE: Mock data only.
//
// FUTURE IMPLEMENTATION PLAN:
//   1. Integrate PAGASA weather API for real-time weather data.
//   2. Map weather conditions to destination risk categories:
//      - Rain intensity  → waterfall/mountain route warnings
//      - Wave height     → sea travel / island-hopping advisories
//      - Wind speed      → habal-habal / open transport cautions
//      - Landslide index → upland trail closures
//   3. Generate advisory cards dynamically from matched rules.
//   4. Cache advisory state in Firestore for offline display.
//   5. Push notifications for HIGH risk advisories via FCM.
// ─────────────────────────────────────────────────────────────────────────────
const List<TravelAdvisory> _mockAdvisories = [
  // 🌧 Rainy Weather Warning
  TravelAdvisory(
    icon:     Icons.thunderstorm_rounded,
    emoji:    '🌧',
    title:    'Rainy Weather Warning',
    message:  'Heavy rainfall may affect waterfalls and mountain routes today. '
              'Bring rain gear and check roads before departing.',
    level:    AdvisoryLevel.moderate,
    category: 'Weather',
    affectedRoutes: 'Tinago Falls · Caibiran Road · Mountain Trails',
  ),

  // 🌊 Sea Travel Advisory
  TravelAdvisory(
    icon:     Icons.waves_rounded,
    emoji:    '🌊',
    title:    'Sea Travel Advisory',
    message:  'Sea travel to Higatangan and Sambawan may become risky during '
              'strong waves. Confirm with boat operators before booking.',
    level:    AdvisoryLevel.high,
    category: 'Sea Travel',
    affectedRoutes: 'Sambawan Island · Higatangan Island · Maripipi Island',
  ),

  // ⛰ Landslide Risk
  TravelAdvisory(
    icon:     Icons.terrain_rounded,
    emoji:    '⛰',
    title:    'Landslide Risk — Upland Areas',
    message:  'Mountain and upland areas may become slippery during prolonged '
              'rainfall. Exercise caution on trail sections.',
    level:    AdvisoryLevel.moderate,
    category: 'Landslide',
    affectedRoutes: 'Caibiran–Biliran Road · Tomalistis Falls Trail',
  ),

  // ℹ️ General Travel Info
  TravelAdvisory(
    icon:     Icons.campaign_rounded,
    emoji:    'ℹ️',
    title:    'Biliran Tourism Office Notice',
    message:  'All official fares are fixed. Do not pay above the posted rates. '
              'Report overcharging to the Tourism Office.',
    level:    AdvisoryLevel.info,
    category: 'General Advisory',
    affectedRoutes: null,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Travel Advisory Section Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Animated carousel-style advisory section for the BiliRoute homepage.
///
/// Displays rotating safety and travel advisories sourced from mock data
/// in the prototype phase. Designed to be replaced with a real-time
/// weather API integration in future implementation.
///
/// Design: glassmorphism-inspired cards with animated pulse indicator,
/// auto-advancing carousel with manual swipe support.
class TravelAdvisorySection extends StatefulWidget {
  const TravelAdvisorySection({super.key});

  @override
  State<TravelAdvisorySection> createState() => _TravelAdvisorySectionState();
}

class _TravelAdvisorySectionState extends State<TravelAdvisorySection>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pulseController;
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);

    // Animated pulse for the warning icon
    _pulseController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Auto-advance every 4 seconds
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _mockAdvisories.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Carousel ──────────────────────────────────────────────────────
        SizedBox(
          height: 160.h,
          child: PageView.builder(
            controller:  _pageController,
            itemCount:   _mockAdvisories.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final advisory = _mockAdvisories[i];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _AdvisoryCard(
                  advisory:       advisory,
                  pulseController: _pulseController,
                  index:          i,
                ),
              );
            },
          ),
        ),

        // ── Page indicator dots ───────────────────────────────────────────
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_mockAdvisories.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin:   EdgeInsets.symmetric(horizontal: 3.w),
              width:    isActive ? 18.w : 6.w,
              height:   6.h,
              decoration: BoxDecoration(
                color:        isActive
                    ? _mockAdvisories[_currentPage].level.color
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),

        // ── Prototype disclaimer ──────────────────────────────────────────
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(Icons.update_rounded,
                  size: 11.sp, color: AppColors.textSecondary),
              SizedBox(width: 5.w),
              Text(
                'Prototype: Static advisory data. Future: Live weather API integration.',
                style: TextStyle(
                  fontSize:  9.5.sp,
                  color:     AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate(delay: 80.ms).fade(duration: 450.ms).slideY(begin: 0.06, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual advisory card
// ─────────────────────────────────────────────────────────────────────────────

class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({
    required this.advisory,
    required this.pulseController,
    required this.index,
  });

  final TravelAdvisory    advisory;
  final AnimationController pulseController;
  final int               index;

  @override
  Widget build(BuildContext context) {
    final level = advisory.level;

    final breathDuration = level == AdvisoryLevel.high
        ? const Duration(milliseconds: 1800)
        : const Duration(milliseconds: 3000);
    final maxGlow = level == AdvisoryLevel.high ? 0.22 : 0.12;

    return BreathingCard(
      glowColor: level.color,
      duration:  breathDuration,
      maxGlow:   maxGlow,
      child: Container(
      decoration: BoxDecoration(
        color:        level.bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(color: level.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color:      level.color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset:     const Offset(0, 6),
          ),
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative emoji (large, faded)
          Positioned(
            right: 14.w,
            top:   10.h,
            child: Text(
              advisory.emoji,
              style: TextStyle(
                fontSize: 54.sp,
                color: Colors.white.withValues(alpha: 0.0),
              ),
            ),
          ),

          // Decorative icon (right, large, faded)
          Positioned(
            right: -8.w,
            bottom: -8.h,
            child: Icon(
              advisory.icon,
              size:  88.sp,
              color: level.color.withValues(alpha: 0.08),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row ───────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animated pulse icon
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (context, child) {
                        return Container(
                          width:  36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: level.color.withValues(
                              alpha: 0.12 + pulseController.value * 0.10,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:      level.color.withValues(
                                  alpha: 0.08 + pulseController.value * 0.15,
                                ),
                                blurRadius: 8 + pulseController.value * 8,
                                spreadRadius: pulseController.value * 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            level.pulseIcon,
                            color: level.color,
                            size:  18.sp,
                          ),
                        );
                      },
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category + badge row
                          Row(
                            children: [
                              Text(
                                advisory.category,
                                style: TextStyle(
                                  fontSize:   10.sp,
                                  fontWeight: FontWeight.w700,
                                  color:      level.color,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color:        level.color,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  level.badge,
                                  style: TextStyle(
                                    fontSize:   8.sp,
                                    fontWeight: FontWeight.w800,
                                    color:      Colors.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          // Title
                          Text(
                            advisory.title,
                            style: TextStyle(
                              fontSize:   13.sp,
                              fontWeight: FontWeight.w800,
                              color:      const Color(0xFF0F172A),
                              height:     1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // ── Message ───────────────────────────────────────────────
                Text(
                  advisory.message,
                  maxLines:  2,
                  overflow:  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:    const Color(0xFF64748B),
                    height:   1.5,
                  ),
                ),

                // ── Affected routes ───────────────────────────────────────
                if (advisory.affectedRoutes != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.route_rounded,
                          size: 11.sp, color: level.color),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          advisory.affectedRoutes!,
                          overflow:  TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:   10.sp,
                            fontWeight: FontWeight.w600,
                            color:      level.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
