import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AI recommendation data model
// ─────────────────────────────────────────────────────────────────────────────

class _AiRec {
  const _AiRec({
    required this.destination,
    required this.reason,
    required this.imageAsset,
    required this.fare,
    required this.travelType,
    required this.matchPercent,
  });
  final String destination;
  final String reason;
  final String imageAsset;
  final String fare;
  final String travelType;
  final int    matchPercent;
}

const _recs = [
  _AiRec(
    destination:  'Sambawan Island',
    reason:       'You loved beach destinations like Agta',
    imageAsset:   'assets/images/sambawan.jpg',
    fare:         '₱ 500–1,500',
    travelType:   'Boat · 1 hr',
    matchPercent: 96,
  ),
  _AiRec(
    destination:  'Maripipi Island',
    reason:       'Similar remote island experience · Hidden gem',
    imageAsset:   'assets/images/maripipi.jpg',
    fare:         '₱ 200–350',
    travelType:   'Ferry · 45 min',
    matchPercent: 88,
  ),
  _AiRec(
    destination:  'Mainit Hot Spring',
    reason:       'Relaxation after waterfall trekking',
    imageAsset:   'assets/images/higatangan.jpg',
    fare:         '₱ 30–50',
    travelType:   'Habal-habal · 25 min',
    matchPercent: 82,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Section widget
// ─────────────────────────────────────────────────────────────────────────────

class AiRecommendationsSection extends StatelessWidget {
  const AiRecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: ListView.separated(
        padding:          EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
        scrollDirection:  Axis.horizontal,
        itemCount:        _recs.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (_, i) => _RecCard(rec: _recs[i], delay: (i * 80).ms),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual recommendation card
// ─────────────────────────────────────────────────────────────────────────────

class _RecCard extends StatelessWidget {
  const _RecCard({required this.rec, required this.delay});
  final _AiRec   rec;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 195.w,
      decoration: BoxDecoration(
        color:        isDark ? DarkColors.card : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
            blurRadius: 18,
            offset:     const Offset(0, 5),
          ),
        ],
        border: isDark ? Border.all(color: DarkColors.border) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            SizedBox(
              height: 110.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    rec.imageAsset,
                    fit:          BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin:  Alignment.topCenter,
                        end:    Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                  // AI badge — top right
                  Positioned(
                    top: 8.h, right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                            color:      const Color(0xFF6366F1)
                                .withValues(alpha: 0.40),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 9.sp),
                          SizedBox(width: 3.w),
                          Text('AI · ${rec.matchPercent}%',
                              style: TextStyle(
                                color:      Colors.white,
                                fontSize:   8.5.sp,
                                fontWeight: FontWeight.w800,
                              )),
                        ],
                      ),
                    ).animate().shimmer(duration: 2000.ms, delay: 600.ms),
                  ),
                  // Match score bottom
                  Positioned(
                    bottom: 8.h, left: 10.w,
                    child: Text(rec.destination,
                        style: TextStyle(
                          color:      Colors.white,
                          fontSize:   12.sp,
                          fontWeight: FontWeight.w800,
                        )),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(rec.reason,
                        style: TextStyle(
                          fontSize:   9.5.sp,
                          color:      AppColors.textSecondary,
                          height:     1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rec.fare,
                                  style: TextStyle(
                                    fontSize:   10.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color:      AppColors.primary,
                                  )),
                              Text(rec.travelType,
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    color:    AppColors.textSecondary,
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color:        AppColors.primary,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text('Go',
                              style: TextStyle(
                                color:      Colors.white,
                                fontSize:   9.sp,
                                fontWeight: FontWeight.w800,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fade(duration: 350.ms)
        .slideX(begin: 0.12, end: 0);
  }
}
