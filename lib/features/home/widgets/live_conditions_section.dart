import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

enum _ConditionStatus { good, moderate, warning }

class _Condition {
  const _Condition({
    required this.label,
    required this.value,
    required this.icon,
    required this.status,
    required this.gradientColors,
  });
  final String           label;
  final String           value;
  final IconData         icon;
  final _ConditionStatus status;
  final List<Color>      gradientColors;
}

const _conditions = [
  _Condition(
    label:          'Weather',
    value:          'Sunny · 31°C',
    icon:           Icons.wb_sunny_rounded,
    status:         _ConditionStatus.good,
    gradientColors: [Color(0xFFF59E0B), Color(0xFFFB923C)],
  ),
  _Condition(
    label:          'Sea Condition',
    value:          'Moderate Waves',
    icon:           Icons.waves_rounded,
    status:         _ConditionStatus.moderate,
    gradientColors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
  ),
  _Condition(
    label:          'Ferry Status',
    value:          'Travel Allowed',
    icon:           Icons.directions_boat_rounded,
    status:         _ConditionStatus.good,
    gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
  ),
  _Condition(
    label:          'Road Condition',
    value:          'Clear · Safe',
    icon:           Icons.route_rounded,
    status:         _ConditionStatus.good,
    gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
  ),
  _Condition(
    label:          'Tourism Advisory',
    value:          'Low Risk',
    icon:           Icons.shield_rounded,
    status:         _ConditionStatus.good,
    gradientColors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Section widget
// ─────────────────────────────────────────────────────────────────────────────

class LiveConditionsSection extends StatelessWidget {
  const LiveConditionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 145.h,
      child: ListView.separated(
        padding:          EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
        scrollDirection:  Axis.horizontal,
        itemCount:        _conditions.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (_, i) => _ConditionCard(
          condition: _conditions[i],
          delay:     (i * 70).ms,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual card
// ─────────────────────────────────────────────────────────────────────────────

class _ConditionCard extends StatefulWidget {
  const _ConditionCard({required this.condition, required this.delay});
  final _Condition condition;
  final Duration   delay;

  @override
  State<_ConditionCard> createState() => _ConditionCardState();
}

class _ConditionCardState extends State<_ConditionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _statusDot {
    switch (widget.condition.status) {
      case _ConditionStatus.good:     return const Color(0xFF10B981);
      case _ConditionStatus.moderate: return const Color(0xFFF59E0B);
      case _ConditionStatus.warning:  return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.condition;
    return Container(
      width: 128.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: c.gradientColors,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color:      c.gradientColors.first.withValues(alpha: 0.28),
            blurRadius: 14,
            offset:     const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Stack(
          children: [
            // Glassmorphism shimmer layer
            Positioned(
              top: -20.r, right: -20.r,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, _) => Container(
                  width:  80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(alpha: 0.06 + _pulse.value * 0.07),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Container(
                    width:  38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color:        Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) => Transform.rotate(
                        angle: _pulse.value * 0.06 * math.pi,
                        child: Icon(c.icon,
                            color: Colors.white, size: 19.sp),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status dot + label
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, _) => Container(
                              width:  6.r,
                              height: 6.r,
                              decoration: BoxDecoration(
                                color:  _statusDot.withValues(
                                    alpha: 0.6 + _pulse.value * 0.4),
                                shape:  BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:      _statusDot,
                                    blurRadius: 4 + _pulse.value * 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(c.label,
                              style: TextStyle(
                                color:      Colors.white.withValues(alpha: 0.78),
                                fontSize:   9.sp,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(c.value,
                          style: TextStyle(
                            color:      Colors.white,
                            fontSize:   11.sp,
                            fontWeight: FontWeight.w800,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: widget.delay)
        .fade(duration: 350.ms)
        .slideX(begin: 0.15, end: 0);
  }
}
