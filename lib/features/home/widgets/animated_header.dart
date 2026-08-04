import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/ambient/ambient_particles.dart';
import '../../../widgets/ambient/ocean_shimmer.dart';
import '../../../widgets/fade_slide.dart';

/// Full-width hero header — now with ambient living motion:
///   • Two soft drifting cloud blobs (slow horizontal scroll)
///   • Floating glowing particles in the sky area
///   • Ocean shimmer wave strip at the gradient bottom
class AnimatedHeader extends StatefulWidget {
  const AnimatedHeader({super.key});

  static double get _heroH => 270.0;

  @override
  State<AnimatedHeader> createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<AnimatedHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cloudCtrl;

  @override
  void initState() {
    super.initState();
    // Very slow 24-second cloud drift — barely perceptible, calming
    _cloudCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _cloudCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroH = AnimatedHeader._heroH;

    return SizedBox(
      height: heroH.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          // ── Sky-blue gradient background ──────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [
                    Color(0xFF90CAF9),
                    Color(0xFFBBDEFB),
                    Color(0xFFEEF6FF),
                    Colors.white,
                  ],
                  stops: [0.0, 0.40, 0.72, 1.0],
                ),
              ),
            ),
          ),

          // ── Layer: drifting cloud blobs ───────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: heroH.h * 0.6,
            child: AnimatedBuilder(
              animation: _cloudCtrl,
              builder: (_, child) {
                final t = _cloudCtrl.value;
                return CustomPaint(
                  painter: _CloudPainter(progress: t),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // ── Layer: ambient sky particles ──────────────────────────────────
          Positioned(
            top:    0,
            left:   0,
            right:  0,
            height: heroH.h * 0.65,
            child: const AmbientParticles(
              count:     8,
              color:     Color(0xFFFFFFFF),
              maxRadius: 2.5,
              speed:     0.5,
              opacity:   0.35,
              seed:      42,
            ),
          ),

          // ── Scenic image ─────────────────────────────────────────────────
          Positioned(
            bottom: 44.h,
            left:   0,
            right:  0,
            child: Image.asset(
              'assets/images/onboarding_2.jpg',
              width:        double.infinity,
              fit:          BoxFit.fitWidth,
              errorBuilder: (_, e, s) => const SizedBox.shrink(),
            ),
          ),

          // ── Bottom vertical fade: image melts into white ──────────────────
          Positioned(
            bottom: 44.h,
            left:   0,
            right:  0,
            height: 70.h,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                ),
              ),
            ),
          ),

          // ── Ocean shimmer strip ───────────────────────────────────────────
          Positioned(
            bottom: 44.h,
            left:   0,
            right:  0,
            child: const OceanShimmer(
              height:    36,
              amplitude: 4.5,
              opacity:   0.35,
              waveColor: Color(0xFF7DD3FC),
            ),
          ),

          // ── Greeting + heading ─────────────────────────────────────────────
          Positioned(
            top:   16.h,
            left:  20.w,
            right: 20.w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlide(
                        child: Row(children: [
                          Text(
                            ' ',
                            style: TextStyle(
                              fontSize:   12.5.sp,
                              fontWeight: FontWeight.w600,
                              color:      AppColors.textPrimary,
                            ),
                          ),
                          const Text('👋',
                              style: TextStyle(fontSize: 13)),
                        ]),
                      ),
                      SizedBox(height: 6.h),
                      FadeSlide(
                        delay: 60.ms,
                        child: Text(
                          'Travel smarter\nacross Biliran',
                          style: TextStyle(
                            fontSize:   24.sp,
                            fontWeight: FontWeight.w800,
                            color:      AppColors.white,
                            height:     1.22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Bell notification
                Container(
                  width:  44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color:        Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset:     const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textPrimary,
                          size:  22.sp,
                        ),
                      ),
                      Positioned(
                        top:   8.h,
                        right: 8.w,
                        child: Container(
                          width:  7.r,
                          height: 7.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 200.ms)
                    .fade(duration: 400.ms)
                    .scale(begin: const Offset(0.88, 0.88)),
              ],
            ),
          ),

          // ── Search bar ─────────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left:   16.w,
            right:  16.w,
            child: FadeSlide(
              delay: 130.ms,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color:      Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset:     const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: AppColors.textSecondary, size: 22.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Find routes, providers, destinations...',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color:    AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      width:  36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin:  Alignment.topLeft,
                          end:    Alignment.bottomRight,
                          colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.tune_rounded,
                          color: Colors.white, size: 18.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cloud blob painter ─────────────────────────────────────────────────────────

/// Draws two soft semi-transparent white cloud ellipses drifting slowly right.
class _CloudPainter extends CustomPainter {
  const _CloudPainter({required this.progress});
  final double progress; // 0.0 → 1.0 (repeating)

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.18);

    // Cloud 1 — slow drift across the full width
    final x1 = (progress * size.width * 1.4) % (size.width + 120) - 60;
    _drawCloud(canvas, Offset(x1, size.height * 0.22), 90, 28, paint);

    // Cloud 2 — slightly faster, different Y, phase offset
    final x2 = ((progress + 0.45) * size.width * 1.3) % (size.width + 100) - 50;
    _drawCloud(canvas, Offset(x2, size.height * 0.45), 70, 20, paint);
  }

  void _drawCloud(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    Paint paint,
  ) {
    // A cloud is 3 overlapping ellipses
    canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), paint);
    canvas.drawOval(Rect.fromCenter(
      center: center.translate(-rx * 0.45, ry * 0.1),
      width: rx * 1.1, height: ry * 1.5,
    ), paint);
    canvas.drawOval(Rect.fromCenter(
      center: center.translate(rx * 0.45, ry * 0.1),
      width: rx * 1.0, height: ry * 1.4,
    ), paint);
  }

  @override
  bool shouldRepaint(_CloudPainter old) => old.progress != progress;
}
