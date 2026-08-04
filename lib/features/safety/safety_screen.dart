import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

// ── Risk level enum ────────────────────────────────────────────────────────────
enum _RiskLevel { high, moderate, low, info }

extension _RiskLevelX on _RiskLevel {
  Color get color {
    switch (this) {
      case _RiskLevel.high:     return AppColors.danger;
      case _RiskLevel.moderate: return AppColors.warning;
      case _RiskLevel.low:      return AppColors.success;
      case _RiskLevel.info:     return AppColors.info;
    }
  }

  String get label {
    switch (this) {
      case _RiskLevel.high:     return 'HIGH';
      case _RiskLevel.moderate: return 'MODERATE';
      case _RiskLevel.low:      return 'LOW';
      case _RiskLevel.info:     return 'INFO';
    }
  }

  IconData get icon {
    switch (this) {
      case _RiskLevel.high:     return Icons.warning_rounded;
      case _RiskLevel.moderate: return Icons.warning_amber_rounded;
      case _RiskLevel.low:      return Icons.info_rounded;
      case _RiskLevel.info:     return Icons.notifications_rounded;
    }
  }
}

// ── Advisory model ────────────────────────────────────────────────────────────
class _Advisory {
  const _Advisory({
    required this.category,
    required this.categoryIcon,
    required this.title,
    required this.description,
    required this.level,
    required this.source,
  });
  final String     category;
  final IconData   categoryIcon;
  final String     title;
  final String     description;
  final _RiskLevel level;
  final String     source;
}

/// Safety advisory screen with color-coded risk cards grouped by category.
///
/// [navClearance] — extra bottom padding so content clears the floating nav.
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key, this.navClearance = 0});
  final double navClearance;

  static const _advisories = [
    // ── Weather ──────────────────────────────────────────────────────────────
    _Advisory(
      category:     'Weather',
      categoryIcon: Icons.wb_cloudy_rounded,
      title:        'Tropical Depression Advisory',
      description:  'PAGASA has raised Signal No. 1 for Northern Mindanao. '
                    'Expect moderate to heavy rains. Sea travel not advised for small vessels.',
      level:        _RiskLevel.high,
      source:       'PAGASA — May 16, 2026',
    ),
    _Advisory(
      category:     'Weather',
      categoryIcon: Icons.wb_cloudy_rounded,
      title:        'High Swells — Bohol Sea',
      description:  'Wave heights of 1.5–2.5 m expected in ferry routes between '
                    'Balingoan and Camiguin. RoRo ferries may be suspended.',
      level:        _RiskLevel.moderate,
      source:       'MARINA — May 16, 2026',
    ),

    // ── Landslide ─────────────────────────────────────────────────────────────
    _Advisory(
      category:     'Landslide',
      categoryIcon: Icons.terrain_rounded,
      title:        'Camiguin Volcanic Slopes',
      description:  'Areas near Mount Hibok-Hibok slopes are prone to landslides '
                    'during heavy rainfall. Avoid upland hiking trails.',
      level:        _RiskLevel.moderate,
      source:       'MGB Region X — May 15, 2026',
    ),
    _Advisory(
      category:     'Landslide',
      categoryIcon: Icons.terrain_rounded,
      title:        'Bukidnon Mountain Routes',
      description:  'Baungon–Manolo Fortich corridor has minor road cuts. '
                    'Travel with caution; check DPWH road status before departure.',
      level:        _RiskLevel.low,
      source:       'DPWH X — May 14, 2026',
    ),

    // ── Flood ─────────────────────────────────────────────────────────────────
    _Advisory(
      category:     'Flood',
      categoryIcon: Icons.water_rounded,
      title:        'CDO River Basin Alert',
      description:  'Cagayan de Oro River is at 60% capacity. Low-lying barangays '
                    'in Macasandig and Lapasan are on yellow alert.',
      level:        _RiskLevel.moderate,
      source:       'NDRRMC — May 16, 2026',
    ),

    // ── General ───────────────────────────────────────────────────────────────
    _Advisory(
      category:     'General Advisory',
      categoryIcon: Icons.campaign_rounded,
      title:        'Mount Hibok-Hibok — Alert Level 1',
      description:  'PHIVOLCS maintains Alert Level 1 on Mount Hibok-Hibok. '
                    'The 4-km permanent danger zone remains restricted.',
      level:        _RiskLevel.info,
      source:       'PHIVOLCS — May 16, 2026',
    ),
    _Advisory(
      category:     'General Advisory',
      categoryIcon: Icons.campaign_rounded,
      title:        'COVID Health Protocol Update',
      description:  'Face masks are optional in outdoor tourist areas. '
                    'Bring vaccination card for entry to enclosed attractions.',
      level:        _RiskLevel.low,
      source:       'DOH XI — May 10, 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Group advisories by category
    final grouped = <String, List<_Advisory>>{};
    for (final a in _advisories) {
      grouped.putIfAbsent(a.category, () => []).add(a);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context)),

            // ── Overview summary ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                child: _OverviewRow(advisories: _advisories),
              ),
            ),

            // ── Advisory cards grouped by category ────────────────────────────
            for (final entry in grouped.entries) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 8.h),
                  child: Row(
                    children: [
                      Icon(
                        entry.value.first.categoryIcon,
                        size: 18.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding:
                        EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                    child: _AdvisoryCard(
                        advisory: entry.value[i], index: i),
                  ),
                  childCount: entry.value.length,
                ),
              ),
            ],

            SliverToBoxAdapter(child: SizedBox(height: navClearance + 16.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final canPop = context.canPop();
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.danger.withValues(alpha: 0.85), AppColors.warning],
        ),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          if (canPop)
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 15.sp, color: Colors.white),
              ),
            ),
          if (canPop) SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.safetyTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                'Northern Mindanao  ·  Updated today',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

/// Row of 4 severity counters (high, moderate, low, info).
class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.advisories});
  final List<_Advisory> advisories;

  int _count(_RiskLevel level) =>
      advisories.where((a) => a.level == level).length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _RiskLevel.values.map((level) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: level != _RiskLevel.info ? 8.w : 0,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: level.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: level.color.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  Text(
                    '${_count(level)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: level.color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    level.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: level.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 9.sp,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ).animate(delay: 200.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

/// Single advisory card with risk badge, title, description, and source.
class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({required this.advisory, required this.index});
  final _Advisory advisory;
  final int       index;

  @override
  Widget build(BuildContext context) {
    final level = advisory.level;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: level.color.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risk level icon
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: level.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(level.icon, color: level.color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advisory.title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
              // Risk badge
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: level.color,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  level.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 9.sp,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            advisory.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
          ),
          SizedBox(height: 8.h),
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 13.sp, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(
                advisory.source,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: (120 + index * 60).ms)
        .fade(duration: 400.ms)
        .slideY(begin: 0.08, end: 0);
  }
}
