import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/transport/biliran_fare_data.dart';
import '../../../data/transport/transport_route.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fare Guide Screen — Official Tourism Office Fares
// ─────────────────────────────────────────────────────────────────────────────

class FareGuideScreen extends StatefulWidget {
  const FareGuideScreen({super.key, this.navClearance = 0});
  final double navClearance;

  @override
  State<FareGuideScreen> createState() => _FareGuideScreenState();
}

class _FareGuideScreenState extends State<FareGuideScreen> {
  String _selectedFilter = 'All';
  String _searchQuery    = '';
  bool   _showSearch     = false;

  static const _filterLabels = ['All', 'Land', 'Water'];

  List<TransportRoute> get _filtered {
    var routes = BiliranFareData.allRoutes;

    // Category filter
    if (_selectedFilter == 'Land') {
      routes = routes.where((r) => !r.type.isWater).toList();
    } else if (_selectedFilter == 'Water') {
      routes = routes.where((r) => r.type.isWater).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      routes = routes
          .where((r) =>
              r.origin.toLowerCase().contains(q) ||
              r.destination.toLowerCase().contains(q) ||
              r.type.label.toLowerCase().contains(q))
          .toList();
    }

    return routes;
  }


  @override
  Widget build(BuildContext context) {
    final canPop   = context.canPop();
    final filtered = _filtered;

    // Find cheapest and fastest in visible list
    final cheapest = filtered.isEmpty
        ? null
        : filtered.reduce((a, b) => a.officialFare < b.officialFare ? a : b);
    final fastest = filtered.isEmpty
        ? null
        : filtered.reduce((a, b) =>
            a.durationMinutes < b.durationMinutes ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ────────────────────────────────────────────────────────
            _Header(
              canPop:      canPop,
              routeCount:  filtered.length,
              showSearch:  _showSearch,
              searchQuery: _searchQuery,
              onSearchToggle: () =>
                  setState(() { _showSearch = !_showSearch; _searchQuery = ''; }),
              onSearchChanged: (v) => setState(() => _searchQuery = v),
            ),

            SizedBox(height: 12.h),

            // ── Source attribution banner ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _SourceBanner(),
            ),

            SizedBox(height: 12.h),

            // ── Filter chips ──────────────────────────────────────────────────
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                padding:         EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount:       _filterLabels.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final label    = _filterLabels[i];
                  final selected = _selectedFilter == label;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.divider,
                        ),
                        boxShadow: selected
                            ? [BoxShadow(
                                color:      AppColors.primary.withValues(alpha: 0.22),
                                blurRadius: 10,
                                offset:     const Offset(0, 4))]
                            : [],
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize:   12.sp,
                          fontWeight: FontWeight.w700,
                          color:      selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12.h),

            // ── Highlight cards (cheapest / fastest) ──────────────────────────
            if (cheapest != null && fastest != null && _searchQuery.isEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _HighlightCard(
                        label:  '💸 Cheapest',
                        route:  cheapest,
                        color:  AppColors.success,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _HighlightCard(
                        label: '⚡ Fastest',
                        route: fastest,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Route list ────────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No routes found',
                        style: TextStyle(
                          color:    AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                          16.w, 0, 16.w, widget.navClearance + 16.h),
                      physics:          const BouncingScrollPhysics(),
                      itemCount:        filtered.length,
                      separatorBuilder: (_, _) => SizedBox(height: 10.h),
                      itemBuilder: (_, i) => _FareTile(
                        route:      filtered[i],
                        index:      i,
                        isCheapest: filtered[i] == cheapest,
                        isFastest:  filtered[i] == fastest,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.canPop,
    required this.routeCount,
    required this.showSearch,
    required this.searchQuery,
    required this.onSearchToggle,
    required this.onSearchChanged,
  });

  final bool   canPop;
  final int    routeCount;
  final bool   showSearch;
  final String searchQuery;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (canPop) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38.r, height: 38.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 10)],
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 15.sp, color: AppColors.textPrimary),
                  ),
                ),
                SizedBox(width: 14.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fare Guide',
                      style: TextStyle(
                        fontSize:   20.sp,
                        fontWeight: FontWeight.w800,
                        color:      AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Biliran Island · $routeCount routes',
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Search toggle
              GestureDetector(
                onTap: onSearchToggle,
                child: Container(
                  width: 38.r, height: 38.r,
                  decoration: BoxDecoration(
                    color: showSearch
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 10)],
                  ),
                  child: Icon(
                    showSearch ? Icons.close_rounded : Icons.search_rounded,
                    size:  18.sp,
                    color: showSearch ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          // Animated search bar
          if (showSearch) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12)],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: AppColors.textSecondary, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      onChanged: onSearchChanged,
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText:        'Search origin or destination…',
                        hintStyle:       TextStyle(
                            color: AppColors.textSecondary, fontSize: 13.sp),
                        border:          InputBorder.none,
                        isDense:         true,
                        contentPadding:  EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 250.ms).slideY(begin: -0.05, end: 0),
          ],
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: -0.04, end: 0);
  }
}

// ── Source attribution banner ──────────────────────────────────────────────────

class _SourceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.info.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: AppColors.primary, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'All fares are official and sourced from the Biliran Tourism Office. '
              'Fares are fixed — not estimated.',
              style: TextStyle(
                fontSize: 11.sp,
                color:    AppColors.primary,
                height:   1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Highlight card (cheapest / fastest) ───────────────────────────────────────

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.label,
    required this.route,
    required this.color,
  });
  final String         label;
  final TransportRoute route;
  final Color          color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
        border:       Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: color)),
          SizedBox(height: 4.h),
          Text(
            route.routeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:   12.sp,
              fontWeight: FontWeight.w700,
              color:      AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '${route.fareLabel} · ${route.durationLabel}',
            style: TextStyle(fontSize: 11.sp, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Fare tile ─────────────────────────────────────────────────────────────────

class _FareTile extends StatelessWidget {
  const _FareTile({
    required this.route,
    required this.index,
    this.isCheapest = false,
    this.isFastest  = false,
  });
  final TransportRoute route;
  final int            index;
  final bool           isCheapest;
  final bool           isFastest;

  @override
  Widget build(BuildContext context) {
    final color = route.type.color;

    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: (isCheapest || isFastest)
            ? Border.all(
                color: isCheapest
                    ? AppColors.success.withValues(alpha: 0.45)
                    : AppColors.info.withValues(alpha: 0.45),
                width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [

            // Transport icon
            Container(
              width: 48.r, height: 48.r,
              decoration: BoxDecoration(
                color:        color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(route.type.icon, color: color, size: 22.sp),
            ),

            SizedBox(width: 12.w),

            // Route info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Origin → Destination
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          route.origin,
                          overflow:   TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:   13.sp,
                            fontWeight: FontWeight.w700,
                            color:      AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 13.sp, color: AppColors.textSecondary),
                      ),
                      Flexible(
                        child: Text(
                          route.destination,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:   13.sp,
                            fontWeight: FontWeight.w700,
                            color:      AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5.h),

                  // Transport type + duration
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color:        color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          route.type.label,
                          style: TextStyle(
                            fontSize:   10.sp,
                            color:      color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(Icons.schedule_rounded,
                          size: 11.sp, color: AppColors.textSecondary),
                      SizedBox(width: 3.w),
                      Text(
                        route.durationLabel,
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  // Notes (if any)
                  if (route.notes != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      route.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10.sp,
                          color:    AppColors.textSecondary,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 10.w),

            // Fare column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Badges
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCheapest)
                      _Badge('💸', AppColors.success),
                    if (isFastest)
                      _Badge('⚡', AppColors.info),
                  ],
                ),
                if (isCheapest || isFastest) SizedBox(height: 3.h),

                // Fare amount
                Text(
                  route.fareLabel,
                  style: TextStyle(
                    fontSize:   16.sp,
                    fontWeight: FontWeight.w900,
                    color:      AppColors.accent,
                  ),
                ),

                // Official label
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Official Fare',
                    style: TextStyle(
                      fontSize:   9.sp,
                      color:      AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
                Text(
                  route.perPerson ? 'per person' : 'per trip',
                  style: TextStyle(
                      fontSize: 9.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: (60 + index * 35).ms)
        .fade(duration: 350.ms)
        .slideX(begin: 0.04, end: 0);
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.emoji, this.color);
  final String emoji;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    EdgeInsets.all(3.r),
      margin:     EdgeInsets.only(left: 3.w),
      decoration: BoxDecoration(
        color:  color.withValues(alpha: 0.12),
        shape:  BoxShape.circle,
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 10)),
    );
  }
}
