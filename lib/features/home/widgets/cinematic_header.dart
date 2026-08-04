import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/fade_slide.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hero image data — add/remove entries here to configure the slideshow
// ─────────────────────────────────────────────────────────────────────────────

class _HeroImage {
  const _HeroImage({required this.asset, required this.label});
  final String asset;
  final String label;
}

const _heroImages = <_HeroImage>[
  _HeroImage(asset: 'assets/images/sambawan.jpg',   label: 'Sambawan Island'),
  _HeroImage(asset: 'assets/images/higatangan.jpg', label: 'Higatangan Island'),
  _HeroImage(asset: 'assets/images/ulan-ulan.jpg',  label: 'Ulan-Ulan Falls'),
  _HeroImage(asset: 'assets/images/agta.JPG',       label: 'Agta Beach'),
  _HeroImage(asset: 'assets/images/dalutan.jpg',    label: 'Dalutan Island'),
  _HeroImage(asset: 'assets/images/kasabangan.jpg', label: 'Mainit Hot Spring'),
];

// ─────────────────────────────────────────────────────────────────────────────
// CinematicHeader — Ken Burns crossfade hero image slideshow
//
// Animation architecture:
//   • _displayTimer   — fires every 5 s to trigger the next transition
//   • _fadeCtrl       — 1200 ms AnimationController for crossfade opacity
//   • _zoomCtrl       — 6200 ms AnimationController for Ken Burns scale
//     (starts with each new image, drives scale 1.00 → 1.08)
//   • _currentIndex / _nextIndex track which images are visible
//
// Pre-loading: precacheImage() is called in initState for all assets so that
// there is no flicker when the first crossfade happens.
// ─────────────────────────────────────────────────────────────────────────────

class CinematicHeader extends StatefulWidget {
  const CinematicHeader({super.key});

  /// Height of the hero area — same as the old AnimatedHeader.
  static double get heroH => 310.0;

  @override
  State<CinematicHeader> createState() => _CinematicHeaderState();
}

class _CinematicHeaderState extends State<CinematicHeader>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeCtrl;
  late AnimationController _zoomCtrl;

  // Derived animations
  late Animation<double> _fadeAnim; // 0 → 1 (incoming fades in)
  late Animation<double> _zoomAnim; // 1.00 → 1.06 — subtle Ken Burns

  // Image indices
  int _currentIndex = 0;
  int _nextIndex    = 1;

  // Display timer
  Timer? _displayTimer;

  static const _displayDuration    = Duration(seconds: 5);
  static const _fadeDuration        = Duration(milliseconds: 1200);
  static const _kenBurnsDuration    = Duration(milliseconds: 6200);

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: _fadeDuration);
    _zoomCtrl = AnimationController(vsync: this, duration: _kenBurnsDuration);

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _zoomAnim = Tween<double>(begin: 1.00, end: 1.06)
        .animate(CurvedAnimation(parent: _zoomCtrl, curve: Curves.easeInOut));

    // Start the zoom for the first image immediately
    _zoomCtrl.forward();

    // Schedule first transition after the display duration
    _scheduleNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache all hero images to prevent flicker
    for (final img in _heroImages) {
      precacheImage(AssetImage(img.asset), context);
    }
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    _fadeCtrl.dispose();
    _zoomCtrl.dispose();
    super.dispose();
  }

  void _scheduleNext() {
    _displayTimer?.cancel();
    _displayTimer = Timer(_displayDuration, _beginTransition);
  }

  Future<void> _beginTransition() async {
    if (!mounted) return;

    // Start Ken Burns on the incoming image simultaneously with the fade
    _zoomCtrl
      ..reset()
      ..forward();

    // Cross-fade: 1.0 means incoming image is fully visible
    await _fadeCtrl.forward();
    if (!mounted) return;

    // Transition complete — swap indices, reset fade, schedule next
    setState(() {
      _currentIndex = _nextIndex;
      _nextIndex    = (_nextIndex + 1) % _heroImages.length;
    });
    _fadeCtrl.reset();
    _scheduleNext();
  }

  @override
  Widget build(BuildContext context) {
    final heroH = CinematicHeader.heroH;

    return SizedBox(
      height: heroH.h,
      // ClipRect prevents the Ken Burns scale transform from painting
      // outside the fixed hero bounds — no overlap with Travel Advisory.
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [

            // ── Current image with Ken Burns zoom ──────────────────────────
            _KenBurnsImage(
              asset:    _heroImages[_currentIndex].asset,
              zoomAnim: _zoomAnim,
            ),

            // ── Incoming image cross-fading in ────────────────────────────
            AnimatedBuilder(
              animation: _fadeAnim,
              builder: (_, child) => Opacity(
                opacity: _fadeAnim.value,
                child:   child,
              ),
              child: _KenBurnsImage(
                asset:    _heroImages[_nextIndex].asset,
                zoomAnim: _zoomAnim,
              ),
            ),

            // ── Dark overlay: readability for text ────────────────────────
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Colors.transparent,
                    Color(0x44000000),
                    Color(0x66000000),
                  ],
                  stops: [0.0, 0.35, 0.72, 1.0],
                ),
              ),
            ),

            // ── Greeting + heading ────────────────────────────────────────
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
                                color:      Colors.white,
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
                              color:      Colors.white,
                              height:     1.22,
                              shadows: const [
                                Shadow(
                                  color:  Color(0x88000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Bell notification button
                  Container(
                    width:  44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color:        Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
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

            // ── Destination label (bottom-left, above search bar) ─────────
            Positioned(
              bottom: 58.h,
              left:   20.w,
              child: AnimatedSwitcher(
                duration:  const Duration(milliseconds: 500),
                child: Text(
                  _heroImages[_currentIndex].label,
                  key:   ValueKey(_currentIndex),
                  style: TextStyle(
                    color:      Colors.white.withValues(alpha: 0.80),
                    fontSize:   11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                        color:     Color(0x66000000),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Search bar (floats at bottom of hero) ─────────────────────
            Positioned(
              bottom: 12.h,
              left:   16.w,
              right:  16.w,
              child: FadeSlide(
                delay: 130.ms,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                  decoration: BoxDecoration(
                    color:        Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.14),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _KenBurnsImage — single image with Ken Burns zoom animation
// ─────────────────────────────────────────────────────────────────────────────

class _KenBurnsImage extends StatelessWidget {
  const _KenBurnsImage({
    required this.asset,
    required this.zoomAnim,
  });

  final String            asset;
  final Animation<double> zoomAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: zoomAnim,
      builder: (_, child) => Transform.scale(
        scale: zoomAnim.value,
        child: child,
      ),
      child: Image.asset(
        asset,
        fit:          BoxFit.cover,
        width:        double.infinity,
        height:       double.infinity,
        errorBuilder: (_, e, s) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin:  Alignment.topLeft,
              end:    Alignment.bottomRight,
              colors: [Color(0xFF0A2E73), Color(0xFF1458D4)],
            ),
          ),
        ),
      ),
    );
  }
}
