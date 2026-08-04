import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Event data model
// ─────────────────────────────────────────────────────────────────────────────

class _Event {
  const _Event({
    required this.title,
    required this.location,
    required this.date,
    required this.daysLeft,
    required this.gradientColors,
    required this.emoji,
    required this.category,
  });
  final String      title;
  final String      location;
  final String      date;
  final int         daysLeft;
  final List<Color> gradientColors;
  final String      emoji;
  final String      category;
}

const _events = [
  _Event(
    title:          'Biliran Day Fiesta',
    location:       'Naval Town Plaza',
    date:           'Jun 23, 2025',
    daysLeft:       32,
    gradientColors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    emoji:          '🎉',
    category:       'Cultural Festival',
  ),
  _Event(
    title:          'Sambawan Island Fest',
    location:       'Sambawan Island',
    date:           'Jul 4, 2025',
    daysLeft:       43,
    gradientColors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
    emoji:          '🏝️',
    category:       'Island Tourism',
  ),
  _Event(
    title:          'Biliran River Marathon',
    location:       'Almeria–Naval Route',
    date:           'Jul 19, 2025',
    daysLeft:       58,
    gradientColors: [Color(0xFF059669), Color(0xFF10B981)],
    emoji:          '🏃',
    category:       'Sports & Adventure',
  ),
  _Event(
    title:          'Higatangan Eco Dive',
    location:       'Higatangan Island',
    date:           'Aug 2, 2025',
    daysLeft:       72,
    gradientColors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    emoji:          '🤿',
    category:       'Marine Adventure',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Section widget
// ─────────────────────────────────────────────────────────────────────────────

class EventsSection extends StatelessWidget {
  const EventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195.h,
      child: ListView.separated(
        padding:          EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
        scrollDirection:  Axis.horizontal,
        itemCount:        _events.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (_, i) => _EventCard(event: _events[i], delay: (i * 80).ms),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Event card
// ─────────────────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.delay});
  final _Event   event;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final e = event;
    return Container(
      width: 195.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: e.gradientColors,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color:      e.gradientColors.first.withValues(alpha: 0.30),
            blurRadius: 16,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            // Ambient circle top-right
            Positioned(
              top: -24.r, right: -24.r,
              child: Container(
                width:  90.r,
                height: 90.r,
                decoration: BoxDecoration(
                  color:  Colors.white.withValues(alpha: 0.10),
                  shape:  BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(15.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: [
                  // Emoji + category
                  Row(
                    children: [
                      Text(e.emoji,
                          style: TextStyle(fontSize: 26.sp)),
                      const Spacer(),
                      // Countdown chip
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color:        Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${e.daysLeft}d left',
                          style: TextStyle(
                            color:      Colors.white,
                            fontSize:   8.5.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color:        Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(e.category,
                            style: TextStyle(
                              color:      Colors.white.withValues(alpha: 0.90),
                              fontSize:   8.sp,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      SizedBox(height: 5.h),
                      Text(e.title,
                          style: TextStyle(
                            color:      Colors.white,
                            fontSize:   13.sp,
                            fontWeight: FontWeight.w800,
                            height:     1.2,
                          ),
                          maxLines: 2),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 10.sp,
                              color: Colors.white.withValues(alpha: 0.75)),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(e.location,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color:    Colors.white.withValues(alpha: 0.80),
                                ),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Date + Join button row
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 9.sp,
                              color: Colors.white.withValues(alpha: 0.75)),
                          SizedBox(width: 4.w),
                          Text(e.date,
                              style: TextStyle(
                                fontSize:   9.sp,
                                color:      Colors.white.withValues(alpha: 0.80),
                                fontWeight: FontWeight.w600,
                              )),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color:        Colors.white,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text('Join',
                                style: TextStyle(
                                  color:      e.gradientColors.first,
                                  fontSize:   9.sp,
                                  fontWeight: FontWeight.w800,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
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
