import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/ambient/breathing_card.dart';
import '../../advisories/repositories/advisory_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Advisory Level
// ─────────────────────────────────────────────────────────────────────────────

enum AdvisoryLevel {
  high,
  moderate,
  info;

  Color color(bool isDark) {
    switch (this) {
      case AdvisoryLevel.high:
        return isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
      case AdvisoryLevel.moderate:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
      case AdvisoryLevel.info:
        return isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);
    }
  }

  Color bgColor(bool isDark) {
    switch (this) {
      case AdvisoryLevel.high:
        return isDark
            ? const Color(0xFF261013).withValues(alpha: 0.90)
            : const Color(0xFFFEF2F2);
      case AdvisoryLevel.moderate:
        return isDark
            ? const Color(0xFF241C0E).withValues(alpha: 0.90)
            : const Color(0xFFFFFBEB);
      case AdvisoryLevel.info:
        return isDark
            ? const Color(0xFF0C2424).withValues(alpha: 0.90)
            : const Color(0xFFF0FDFA);
    }
  }

  Color borderColor(bool isDark) {
    switch (this) {
      case AdvisoryLevel.high:
        return isDark
            ? const Color(0xFF991B1B).withValues(alpha: 0.55)
            : const Color(0xFFFECACA);
      case AdvisoryLevel.moderate:
        return isDark
            ? const Color(0xFF92400E).withValues(alpha: 0.55)
            : const Color(0xFFFDE68A);
      case AdvisoryLevel.info:
        return isDark
            ? const Color(0xFF115E59).withValues(alpha: 0.55)
            : const Color(0xFF99F6E4);
    }
  }

  String get badge {
    switch (this) {
      case AdvisoryLevel.high:
        return 'HIGH RISK';
      case AdvisoryLevel.moderate:
        return 'ADVISORY';
      case AdvisoryLevel.info:
        return 'INFO NOTICE';
    }
  }

  IconData get icon {
    switch (this) {
      case AdvisoryLevel.high:
        return Icons.warning_amber_rounded;
      case AdvisoryLevel.moderate:
        return Icons.thunderstorm_rounded;
      case AdvisoryLevel.info:
        return Icons.campaign_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Advisory Data Model
// ─────────────────────────────────────────────────────────────────────────────

class TravelAdvisory {
  const TravelAdvisory({
    required this.id,
    required this.icon,
    required this.emoji,
    required this.title,
    required this.message,
    required this.level,
    required this.category,
    this.affectedRoutes,
    this.issuedBy = 'Biliran Tourism Office & PAGASA',
    this.recommendations = const [],
    this.effectiveFrom,
    this.expiresAt,
    this.isActive = true,
  });

  final String          id;
  final IconData        icon;
  final String          emoji;
  final String          title;
  final String          message;
  final AdvisoryLevel   level;
  final String          category;
  final String?         affectedRoutes;
  final String          issuedBy;
  final List<String>    recommendations;
  final DateTime?       effectiveFrom;
  final DateTime?       expiresAt;
  final bool            isActive;

  factory TravelAdvisory.fromJson(Map<String, dynamic> json) {
    final severityStr = json['severity'] as String? ?? 'Info';
    final categoryStr = json['category'] as String? ?? 'GENERAL NOTICE';
    final level = _mapSeverityToLevel(severityStr);
    final (icon, emoji) = _mapCategoryToVisuals(categoryStr, level);

    String? affected;
    final affectedAreas = (json['affectedAreas'] as List?)?.map((e) => e.toString()).toList() ?? [];
    if (affectedAreas.isNotEmpty) {
      affected = affectedAreas.join(' · ');
    } else {
      final dests = json['affectedDestinationIds'] as List?;
      if (dests != null && dests.isNotEmpty) {
        final names = dests
            .map((d) => d is Map ? (d['title'] as String? ?? '') : '')
            .where((n) => n.isNotEmpty)
            .toList();
        if (names.isNotEmpty) affected = names.join(' · ');
      }
    }

    return TravelAdvisory(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      icon: icon,
      emoji: emoji,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      level: level,
      category: categoryStr.toUpperCase(),
      affectedRoutes: affected,
      issuedBy: json['issuedBy'] as String? ?? 'Biliran Tourism Office',
      recommendations: const [],
      effectiveFrom: json['effectiveFrom'] != null ? DateTime.tryParse(json['effectiveFrom'].toString()) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static AdvisoryLevel _mapSeverityToLevel(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'warning':
      case 'high':
        return AdvisoryLevel.high;
      case 'caution':
      case 'moderate':
        return AdvisoryLevel.moderate;
      case 'info':
      default:
        return AdvisoryLevel.info;
    }
  }

  static (IconData, String) _mapCategoryToVisuals(String category, AdvisoryLevel level) {
    final cat = category.toLowerCase();
    if (cat.contains('sea') || cat.contains('maritime')) {
      return (Icons.waves_rounded, '🌊');
    } else if (cat.contains('weather') || cat.contains('rain')) {
      return (Icons.thunderstorm_rounded, '🌧');
    } else if (cat.contains('road') || cat.contains('upland') || cat.contains('traffic')) {
      return (Icons.terrain_rounded, '⛰');
    } else if (cat.contains('safety')) {
      return (Icons.warning_amber_rounded, '⚠️');
    }
    return (level.icon, 'ℹ️');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dataset — Fallback
// ─────────────────────────────────────────────────────────────────────────────

const List<TravelAdvisory> fallbackAdvisories = [
  TravelAdvisory(
    id:       'adv-1',
    icon:     Icons.waves_rounded,
    emoji:    '🌊',
    title:    'Sea Travel Advisory — Sambawan Island',
    message:  'Expect moderate waves (1.2–1.8m) in Biliran Strait during afternoon hours. '
              'Morning sea crossing (6–9 AM) is strongly recommended.',
    level:    AdvisoryLevel.high,
    category: 'MARITIME SAFETY',
    affectedRoutes: 'Sambawan Island · Higatangan Island · Maripipi Island',
    issuedBy: 'Philippine Coast Guard & Biliran Tourism Office',
    recommendations: [
      'Book morning boat charters between 6:00 AM – 9:00 AM.',
      'Mandatory wearing of life jackets during water crossing.',
      'Check live sea condition updates at Kawayan Port before boarding.',
    ],
  ),
  TravelAdvisory(
    id:       'adv-2',
    icon:     Icons.thunderstorm_rounded,
    emoji:    '🌧',
    title:    'Rainy Weather Warning — Waterfall Trails',
    message:  'Heavy localized rainfall may affect waterfall water levels and mountain roads today. '
              'Exercise extra caution on wet rocky paths.',
    level:    AdvisoryLevel.moderate,
    category: 'WEATHER ALERT',
    affectedRoutes: 'Tinago Falls · Caibiran Mountain Loop · Recoletos Falls',
    issuedBy: 'PAGASA Weather Services & Disaster Risk Office',
    recommendations: [
      'Avoid swimming directly near waterfall drop zones during heavy downpours.',
      'Wear sturdy non-slip footwear on mountain trekking trails.',
      'Keep waterproof bags for electronics and travel documents.',
    ],
  ),
  TravelAdvisory(
    id:       'adv-3',
    icon:     Icons.terrain_rounded,
    emoji:    '⛰',
    title:    'Upland Road Maintenance Notice',
    message:  'Ongoing road maintenance along the Naval–Caibiran cross-country highway. '
              'Expect brief 15–20 minute traffic pauses during peak hours.',
    level:    AdvisoryLevel.moderate,
    category: 'ROAD CONDITIONS',
    affectedRoutes: 'Naval–Caibiran Highway · Main Upland Loop',
    issuedBy: 'DPWH & Municipal Transport Advisory',
    recommendations: [
      'Allow 20 extra minutes when traveling between Naval and East Coast.',
      'Drive cautiously around habal-habal mountain bends.',
    ],
  ),
  TravelAdvisory(
    id:       'adv-4',
    icon:     Icons.campaign_rounded,
    emoji:    'ℹ️',
    title:    'Official Fixed Tariff Rates Notice',
    message:  'All boat charters, habal-habal, and tricycle fares follow official provincial rate matrices. '
              'Overcharging can be reported directly to Tourism Desk.',
    level:    AdvisoryLevel.info,
    category: 'TOURISM GUIDELINE',
    affectedRoutes: 'All Municipal Routes & Boat Charters',
    issuedBy: 'Biliran Provincial Tourism Office',
    recommendations: [
      'Consult the BiliRoute Fare Matrix tab before negotiating trips.',
      'Keep exact change when riding local tricycle and jeepney routes.',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Travel Advisory Section
// ─────────────────────────────────────────────────────────────────────────────

class TravelAdvisorySection extends StatefulWidget {
  const TravelAdvisorySection({super.key});

  @override
  State<TravelAdvisorySection> createState() => _TravelAdvisorySectionState();
}

class _TravelAdvisorySectionState extends State<TravelAdvisorySection>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pulseCtrl;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _startAutoPlay();
  }

  void _startAutoPlay([int itemCount = 4]) {
    _timer?.cancel();
    if (itemCount <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % itemCount;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _openAdvisoryModal(BuildContext context, TravelAdvisory advisory) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level  = advisory.level;
    final color  = level.color(isDark);

    showModalBottomSheet(
      context:         context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color:        Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset:     const Offset(0, -6),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width:  40.w,
                  height: 4.5.h,
                  decoration: BoxDecoration(
                    color:        AppColors.divider,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // Level & Category Badge
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color:        color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border:       Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(level.icon, size: 14.sp, color: color),
                        SizedBox(width: 5.w),
                        Text(
                          level.badge,
                          style: TextStyle(
                            fontSize:   10.5.sp,
                            fontWeight: FontWeight.w800,
                            color:      color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    advisory.category,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // Title
              Text(
                '${advisory.emoji} ${advisory.title}',
                style: TextStyle(
                  fontSize:   18.sp,
                  fontWeight: FontWeight.w900,
                  height:     1.25,
                ),
              ),

              SizedBox(height: 12.h),

              // Full Message
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: level.bgColor(isDark),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: level.borderColor(isDark)),
                ),
                child: Text(
                  advisory.message,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height:   1.55,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.88),
                  ),
                ),
              ),

              if (advisory.affectedRoutes != null) ...[
                SizedBox(height: 16.h),
                Text(
                  'Impacted Routes & Locations',
                  style: TextStyle(
                    fontSize:   12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.divider.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.route_rounded, size: 16.sp, color: color),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          advisory.affectedRoutes!,
                          style: TextStyle(
                            fontSize:   11.5.sp,
                            fontWeight: FontWeight.w600,
                            color:      color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (advisory.recommendations.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  'Safety Recommendations',
                  style: TextStyle(
                    fontSize:   12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                ...advisory.recommendations.map(
                  (rec) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 14.sp, color: color),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            rec,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              height:   1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 14.h),

              // Issuing Authority Footnote
              Row(
                children: [
                  Icon(Icons.verified_rounded, size: 13.sp, color: const Color(0xFF0D9488)),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Official Advisory issued by ${advisory.issuedBy}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color:    AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Dismiss button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Acknowledge & Continue',
                    style: TextStyle(
                      fontSize:   13.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final advisoryRepo = context.watch<TouristAdvisoryRepository>();
    final advisories = advisoryRepo.advisories;

    if (_currentPage >= advisories.length && advisories.isNotEmpty) {
      _currentPage = advisories.length - 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Carousel View ──────────────────────────────────────────────────
        SizedBox(
          height: 162.h,
          child: PageView.builder(
            controller:    _pageController,
            itemCount:     advisories.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final advisory = advisories[i];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GestureDetector(
                  onTap: () => _openAdvisoryModal(context, advisory),
                  child: _AdvisoryCard(
                    advisory:  advisory,
                    pulseCtrl: _pulseCtrl,
                    isDark:    isDark,
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 10.h),

        // ── Animated Page Indicator Dots ─────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(advisories.length, (i) {
            final active = i == _currentPage;
            final safeIndex = (_currentPage < advisories.length) ? _currentPage : 0;
            final color  = advisories[safeIndex].level.color(isDark);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin:   EdgeInsets.symmetric(horizontal: 3.w),
              width:    active ? 20.w : 6.w,
              height:   6.h,
              decoration: BoxDecoration(
                color: active ? color : AppColors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),

        SizedBox(height: 8.h),

        // ── Footnote / Real-Time Integration Note ─────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, size: 12.sp, color: const Color(0xFF0D9488)),
              SizedBox(width: 4.w),
              Text(
                'Live safety monitoring by Biliran Tourism Office & PAGASA',
                style: TextStyle(
                  fontSize:  9.5.sp,
                  color:     AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Advisory Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({
    required this.advisory,
    required this.pulseCtrl,
    required this.isDark,
  });

  final TravelAdvisory        advisory;
  final AnimationController pulseCtrl;
  final bool                  isDark;

  @override
  Widget build(BuildContext context) {
    final level       = advisory.level;
    final accentColor = level.color(isDark);
    final bgColor     = level.bgColor(isDark);
    final borderColor = level.borderColor(isDark);

    return BreathingCard(
      glowColor: accentColor,
      duration:  level == AdvisoryLevel.high
          ? const Duration(milliseconds: 1800)
          : const Duration(milliseconds: 3200),
      maxGlow:   level == AdvisoryLevel.high ? 0.25 : 0.12,
      child: Container(
        decoration: BoxDecoration(
          color:        bgColor,
          borderRadius: BorderRadius.circular(20.r),
          border:       Border.all(color: borderColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color:      accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
              blurRadius: 16,
              offset:     const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // Vertical Left Gradient Strip Accent Bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end:   Alignment.bottomCenter,
                      colors: [
                        accentColor,
                        accentColor.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
              ),

              // Decorative Watermark Emoji
              Positioned(
                right: -6.w,
                bottom: -10.h,
                child: Text(
                  advisory.emoji,
                  style: TextStyle(
                    fontSize: 72.sp,
                    color:    accentColor.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header Row ─────────────────────────────────────────
                    Row(
                      children: [
                        // Animated Pulse Icon
                        AnimatedBuilder(
                          animation: pulseCtrl,
                          builder: (context, _) {
                            return Container(
                              width:  32.r,
                              height: 32.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withValues(
                                  alpha: 0.12 + pulseCtrl.value * 0.12,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(
                                      alpha: 0.08 + pulseCtrl.value * 0.16,
                                    ),
                                    blurRadius: 6 + pulseCtrl.value * 6,
                                  ),
                                ],
                              ),
                              child: Icon(
                                advisory.icon,
                                color: accentColor,
                                size:  17.sp,
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10.w),

                        // Badge & Category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 7.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color:        accentColor,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      level.badge,
                                      style: TextStyle(
                                        fontSize:   7.5.sp,
                                        fontWeight: FontWeight.w900,
                                        color:      Colors.white,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      advisory.category,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize:   9.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color:      accentColor,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                advisory.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize:   13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons.chevron_right_rounded,
                          color: accentColor.withValues(alpha: 0.7),
                          size:  20.sp,
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Message Snippet
                    Text(
                      advisory.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color:    Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.75),
                        height: 1.45,
                      ),
                    ),

                    // Affected Routes Chip
                    if (advisory.affectedRoutes != null) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size:  12.sp,
                            color: accentColor,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              advisory.affectedRoutes!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:   10.sp,
                                fontWeight: FontWeight.w700,
                                color:      accentColor,
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
      ),
    );
  }
}
