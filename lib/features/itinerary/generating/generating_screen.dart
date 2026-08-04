import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/transitions/transition_data.dart';
import '../../../widgets/ambient/ambient_particles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase model
// ─────────────────────────────────────────────────────────────────────────────

enum _LoadPhase {
  destinationAnalysis,
  routeGeneration,
  providerMatching,
  safetyCheck,
  finalizing,
}

extension _LoadPhaseX on _LoadPhase {
  String get headline {
    switch (this) {
      case _LoadPhase.destinationAnalysis:
        return 'Analyzing Destination\nAccessibility';
      case _LoadPhase.routeGeneration:
        return 'Evaluating Available\nRoutes';
      case _LoadPhase.providerMatching:
        return 'Matching Verified\nProviders';
      case _LoadPhase.safetyCheck:
        return 'Checking Travel\nConditions';
      case _LoadPhase.finalizing:
        return 'Recommended Route\nReady ✅';
    }
  }

  String get subtext {
    switch (this) {
      case _LoadPhase.destinationAnalysis:
        return 'Scanning transport hubs, ports & accessibility...';
      case _LoadPhase.routeGeneration:
        return 'Computing sea + land route combinations...';
      case _LoadPhase.providerMatching:
        return 'Connecting with BTO-verified drivers & boat operators...';
      case _LoadPhase.safetyCheck:
        return 'Cross-referencing weather data & route risk levels...';
      case _LoadPhase.finalizing:
        return 'Official fares locked in. Route confirmed. Ready!';
    }
  }

  IconData get icon {
    switch (this) {
      case _LoadPhase.destinationAnalysis:
        return Icons.travel_explore_rounded;
      case _LoadPhase.routeGeneration:
        return Icons.route_rounded;
      case _LoadPhase.providerMatching:
        return Icons.verified_rounded;
      case _LoadPhase.safetyCheck:
        return Icons.shield_rounded;
      case _LoadPhase.finalizing:
        return Icons.explore_rounded;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case _LoadPhase.destinationAnalysis:
        return [const Color(0xFF1E3A8A), const Color(0xFF0369A1)];
      case _LoadPhase.routeGeneration:
        return [const Color(0xFF0369A1), const Color(0xFF0891B2)];
      case _LoadPhase.providerMatching:
        return [const Color(0xFF0891B2), const Color(0xFF0D9488)];
      case _LoadPhase.safetyCheck:
        return [const Color(0xFF0D9488), const Color(0xFF059669)];
      case _LoadPhase.finalizing:
        return [const Color(0xFF1E3A8A), const Color(0xFFFB923C)];
    }
  }

  // Duration each phase is shown
  Duration get duration {
    switch (this) {
      case _LoadPhase.destinationAnalysis:
        return const Duration(milliseconds: 1400);
      case _LoadPhase.routeGeneration:
        return const Duration(milliseconds: 1400);
      case _LoadPhase.providerMatching:
        return const Duration(milliseconds: 1400);
      case _LoadPhase.safetyCheck:
        return const Duration(milliseconds: 1200);
      case _LoadPhase.finalizing:
        return const Duration(milliseconds: 900);
    }
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Generating Screen — cinematic smart-loading experience
// ─────────────────────────────────────────────────────────────────────────────

/// Cinematic 5-phase smart-loading interstitial for BiliRoute.
///
/// Simulates an AI travel computation flow with:
///   Phase 1 — Destination Analysis    (scanning island landmarks)
///   Phase 2 — Route Generation        (land + sea route computation)
///   Phase 3 — Provider Matching       (BTO-verified provider lookup)
///   Phase 4 — Safety & Weather Check  (advisory cross-reference)
///   Phase 5 — Finalization            (success celebration)
///
/// All animations are Flutter-native (no external Lottie files required).
/// Uses CustomPainter for the ambient background orbs, per-phase icon
/// canvases, and animated route-line effects.
///
/// Navigation: pushReplacement('/itinerary-result') on completion.
class GeneratingScreen extends StatefulWidget {
  const GeneratingScreen({super.key, this.payload});

  /// Shared transition data received from RouteSelectionScreen.
  final TransitionPayload? payload;

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen>
    with TickerProviderStateMixin {
  // Current phase
  _LoadPhase _phase = _LoadPhase.destinationAnalysis;

  // Background ambient orb rotation
  late final AnimationController _orbController;

  // Scan-ring pulse (phase 1, 4)
  late final AnimationController _pulseController;

  // Route-line draw (phase 2)
  late final AnimationController _routeController;

  // Icon entrance + icon idle float
  late final AnimationController _iconFloatController;

  // Progress bar animation
  late final AnimationController _progressController;

  // Particle burst on finalize
  late final AnimationController _particleController;

  // Derived progress value (0.0 – 1.0) per phase
  double get _progress =>
      (_phase.index + 1) / _LoadPhase.values.length;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _routeController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );

    _iconFloatController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    );

    _particleController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    for (final phase in _LoadPhase.values) {
      if (!mounted) return;

      setState(() => _phase = phase);

      // Animate progress bar to new value
      _progressController.animateTo(
        _progress,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );

      // Phase-specific animations
      if (phase == _LoadPhase.routeGeneration) {
        _routeController.forward(from: 0);
      }
      if (phase == _LoadPhase.finalizing) {
        _particleController.forward(from: 0);
      }

      await Future.delayed(phase.duration);
    }

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.pushReplacement(
      AppRouter.itineraryResult,
      extra: widget.payload,
    );
  }

  @override
  void dispose() {
    _orbController.dispose();
    _pulseController.dispose();
    _routeController.dispose();
    _iconFloatController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: _phase.gradientColors,
          ),
        ),
        child: Stack(
          children: [
            // ── Layer 0: Ambient floating particles ─────────────────────────
            const Positioned.fill(
              child: AmbientParticles(
                count:     10,
                color:     Color(0xFF7DD3FC),
                maxRadius: 2.8,
                speed:     0.6,
                opacity:   0.30,
                seed:      77,
              ),
            ),

            // ── Layer 1: Ambient rotating orbs ──────────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _orbController,
                builder: (_, child) => CustomPaint(
                  painter: _AmbientOrbPainter(
                    progress: _orbController.value,
                    phase:    _phase.index,
                  ),
                ),
              ),
            ),

            // ── Layer 2: Phase canvas (scan ring, route lines, etc.) ────────
            Positioned.fill(
              child: _PhaseCanvas(
                phase:           _phase,
                pulseController: _pulseController,
                routeController: _routeController,
              ),
            ),

            // ── Layer 3: Particle burst (finalize only) ─────────────────────
            if (_phase == _LoadPhase.finalizing)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (_, _) => CustomPaint(
                    painter: _ParticlePainter(
                      progress: _particleController.value,
                    ),
                  ),
                ),
              ),

            // ── Layer 4: Main UI content ────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Phase icon ─────────────────────────────────────────────
                  _PhaseIconWidget(
                    phase:          _phase,
                    pulseCtrl:      _pulseController,
                    floatCtrl:      _iconFloatController,
                    particleCtrl:   _particleController,
                  ),

                  SizedBox(height: 20.h),

                  // ── Progress % centred below icon ──────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48.w),
                    child: _AnimatedProgressBar(
                      controller: _progressController,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ── Headline ───────────────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.12),
                          end:   Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: anim,
                          curve:  Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    ),
                    child: Text(
                      _phase.headline,
                      key:       ValueKey(_phase.index),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:      Colors.white,
                        fontSize:   24.sp,
                        fontWeight: FontWeight.w800,
                        height:     1.28,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // ── Sub-text ───────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      child: Text(
                        _phase.subtext,
                        key:       ValueKey('sub_${_phase.index}'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:    Colors.white.withValues(alpha: 0.72),
                          fontSize: 12.sp,
                          height:   1.5,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Phase detail chips ─────────────────────────────────────
                  _PhaseDetailChips(phase: _phase),

                  SizedBox(height: 16.h),

                  // ── BiliRoute branding footer ─────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route_rounded,
                          color: Colors.white.withValues(alpha: 0.45),
                          size:  14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'BiliRoute  ·  Smart Tourism Mobility Platform',
                          style: TextStyle(
                            color:        Colors.white.withValues(alpha: 0.45),
                            fontSize:     9.5.sp,
                            letterSpacing: 0.4,
                            fontWeight:   FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 300.ms).fade(duration: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase icon with glow + float
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseIconWidget extends StatelessWidget {
  const _PhaseIconWidget({
    required this.phase,
    required this.pulseCtrl,
    required this.floatCtrl,
    required this.particleCtrl,
  });

  final _LoadPhase             phase;
  final AnimationController    pulseCtrl;
  final AnimationController    floatCtrl;
  final AnimationController    particleCtrl;

  @override
  Widget build(BuildContext context) {
    final isFinal = phase == _LoadPhase.finalizing;

    return AnimatedBuilder(
      animation: Listenable.merge([pulseCtrl, floatCtrl]),
      builder: (_, _) {
        final floatOffset = math.sin(floatCtrl.value * math.pi) * 8.0;
        final glowRadius  = 28.0 + pulseCtrl.value * 18.0;
        final glowAlpha   = 0.22 + pulseCtrl.value * 0.18;

        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: Tween<double>(begin: 0.70, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
              ),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Container(
              key:    ValueKey(phase.index),
              width:  110.r,
              height: 110.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color:        Colors.white.withValues(alpha: glowAlpha),
                    blurRadius:   glowRadius,
                    spreadRadius: isFinal ? 6 : 2,
                  ),
                  BoxShadow(
                    color:      Colors.white.withValues(alpha: 0.08),
                    blurRadius: 12,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                phase.icon,
                color: Colors.white,
                size:  46.sp,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────────
// Animated progress bar (no step labels, centred %)
// ───────────────────────────────────────────────────────────────────────────────

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Glowing white progress track
        Container(
          height:      5.h,
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(99),
          ),
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, _) => FractionallySizedBox(
              alignment:   Alignment.centerLeft,
              widthFactor: controller.value,
              child: Container(
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color:      Colors.white.withValues(alpha: 0.55),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        // Centred percentage label only
        AnimatedBuilder(
          animation: controller,
          builder: (_, _) => Text(
            '${(controller.value * 100).round()}%',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:        Colors.white.withValues(alpha: 0.70),
              fontSize:     13.sp,
              fontWeight:   FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase detail chips (small info rows)
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseDetailChips extends StatelessWidget {
  const _PhaseDetailChips({required this.phase});
  final _LoadPhase phase;

  static const _phaseChips = {
    _LoadPhase.destinationAnalysis: [
      (Icons.holiday_village_rounded, 'Sambawan Island'),
      (Icons.water_rounded,           'Tinago Falls'),
      (Icons.beach_access_rounded,    'Agta Beach'),
    ],
    _LoadPhase.routeGeneration: [
      (Icons.airport_shuttle_rounded, 'Multicab routes'),
      (Icons.sailing_rounded,         'Sea crossings'),
      (Icons.two_wheeler_rounded,     'Habal-habal trails'),
    ],
    _LoadPhase.providerMatching: [
      (Icons.verified_rounded,        'BTO-DRV-0001 matched'),
      (Icons.verified_rounded,        'BTO-BOT-0001 matched'),
      (Icons.verified_rounded,        'BTO-GDE-0001 matched'),
    ],
    _LoadPhase.safetyCheck: [
      (Icons.waves_rounded,           'Sea travel advisory'),
      (Icons.terrain_rounded,         'Landslide risk: LOW'),
      (Icons.wb_cloudy_rounded,       'Weather: Moderate'),
    ],
    _LoadPhase.finalizing: [
      (Icons.payments_rounded,        'Official fares locked'),
      (Icons.check_circle_rounded,    'Route confirmed'),
      (Icons.local_phone_rounded,     'Provider contacts ready'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final chips = _phaseChips[phase] ?? [];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      child: SingleChildScrollView(
        key:             ValueKey(phase.index),
        scrollDirection: Axis.horizontal,
        padding:         EdgeInsets.symmetric(horizontal: 28.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: chips.asMap().entries.map((entry) {
            final i    = entry.key;
            final chip = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                right: i < chips.length - 1 ? 8.w : 0,
              ),
              child: _InfoChip(icon: chip.$1, label: chip.$2, index: i),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.index,
  });
  final IconData icon;
  final String   label;
  final int      index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color:      Colors.white,
              fontSize:   9.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate(delay: (index * 80).ms)
        .fade(duration: 350.ms)
        .slideY(begin: 0.18, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase canvas (scan ring, route lines, provider cards)
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseCanvas extends StatelessWidget {
  const _PhaseCanvas({
    required this.phase,
    required this.pulseController,
    required this.routeController,
  });
  final _LoadPhase          phase;
  final AnimationController pulseController;
  final AnimationController routeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pulseController, routeController]),
      builder: (_, _) {
        switch (phase) {
          case _LoadPhase.destinationAnalysis:
            return CustomPaint(
              painter: _ScanRingPainter(progress: pulseController.value),
            );
          case _LoadPhase.routeGeneration:
            return CustomPaint(
              painter: _RouteLinePainter(progress: routeController.value),
            );
          case _LoadPhase.providerMatching:
            return CustomPaint(
              painter: _ProviderGridPainter(progress: pulseController.value),
            );
          case _LoadPhase.safetyCheck:
            return CustomPaint(
              painter: _WeatherPainter(progress: pulseController.value),
            );
          case _LoadPhase.finalizing:
            return CustomPaint(
              painter: _ScanRingPainter(
                progress:   pulseController.value,
                isSuccess:  true,
              ),
            );
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painters
// ─────────────────────────────────────────────────────────────────────────────

/// Slow-rotating ambient orbs in the background.
class _AmbientOrbPainter extends CustomPainter {
  _AmbientOrbPainter({required this.progress, required this.phase});
  final double progress;
  final int    phase;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final orbs = [
      // Top-left large orb
      (
        cx: cx * 0.3 + math.cos(progress * math.pi * 2) * 30,
        cy: cy * 0.5 + math.sin(progress * math.pi * 2) * 20,
        r:  size.width * 0.48,
        a:  0.065,
      ),
      // Bottom-right orb
      (
        cx: cx * 1.7 + math.sin(progress * math.pi * 2) * 25,
        cy: cy * 1.5 + math.cos(progress * math.pi * 2) * 30,
        r:  size.width * 0.42,
        a:  0.055,
      ),
      // Centre-top small orb
      (
        cx: cx + math.cos(progress * math.pi * 2 + 1.0) * 50,
        cy: cy * 0.25 + math.sin(progress * math.pi * 2) * 15,
        r:  size.width * 0.22,
        a:  0.045,
      ),
    ];

    for (final orb in orbs) {
      canvas.drawCircle(
        Offset(orb.cx, orb.cy),
        orb.r,
        Paint()
          ..color = Colors.white.withValues(alpha: orb.a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientOrbPainter old) =>
      old.progress != progress || old.phase != phase;
}

/// Expanding scan-ring pulse for destination analysis & finalize phases.
class _ScanRingPainter extends CustomPainter {
  _ScanRingPainter({required this.progress, this.isSuccess = false});
  final double progress;
  final bool   isSuccess;

  @override
  void paint(Canvas canvas, Size size) {
    final cx    = size.width / 2;
    final cy    = size.height / 2;
    final paint = Paint()..style = PaintingStyle.stroke;

    // 3 expanding rings at different phase offsets
    for (int i = 0; i < 3; i++) {
      final t     = (progress + i / 3.0) % 1.0;
      final r     = t * size.width * 0.55;
      final alpha = (1.0 - t) * (isSuccess ? 0.20 : 0.13);

      paint
        ..color       = Colors.white.withValues(alpha: alpha)
        ..strokeWidth = isSuccess ? 2.0 : 1.2;

      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // Inner static ring
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.08,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  @override
  bool shouldRepaint(_ScanRingPainter old) =>
      old.progress != progress || old.isSuccess != isSuccess;
}

/// Animated route lines connecting island points.
class _RouteLinePainter extends CustomPainter {
  _RouteLinePainter({required this.progress});
  final double progress;

  // Approximate island route waypoints (normalized 0-1)
  static const _points = [
    Offset(0.18, 0.30),  // Naval
    Offset(0.35, 0.42),  // Almeria
    Offset(0.55, 0.35),  // Kawayan
    Offset(0.72, 0.22),  // Sambawan Port
    Offset(0.82, 0.15),  // Sambawan Island
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final pts = _points
        .map((p) => Offset(p.dx * size.width, p.dy * size.height + size.height * 0.10))
        .toList();

    final linePaint = Paint()
      ..color       = Colors.white.withValues(alpha: 0.30)
      ..strokeWidth = 1.8
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    final glowPaint = Paint()
      ..color       = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 6
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    path.moveTo(pts.first.dx, pts.first.dy);

    // Draw segments progressively
    final totalSegments = pts.length - 1;
    final drawnLength   = progress * totalSegments;

    for (int i = 0; i < totalSegments; i++) {
      if (i >= drawnLength) break;
      final t      = (drawnLength - i).clamp(0.0, 1.0);
      final target = Offset.lerp(pts[i], pts[i + 1], t)!;
      path.lineTo(target.dx, target.dy);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    // Draw map-pin dots at reached waypoints
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < pts.length && i <= drawnLength; i++) {
      final alpha = (i < drawnLength ? 1.0 : drawnLength - i).clamp(0.0, 1.0);
      dotPaint.color = Colors.white.withValues(alpha: alpha * 0.85);
      canvas.drawCircle(pts[i], 5.0, dotPaint);

      // Outer ring
      canvas.drawCircle(
        pts[i],
        9.0,
        Paint()
          ..color       = Colors.white.withValues(alpha: alpha * 0.22)
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Sea wave arc between Kawayan and Sambawan Port
    if (progress > 0.6) {
      final t2   = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
      final arcPaint = Paint()
        ..color       = Colors.white.withValues(alpha: 0.18 * t2)
        ..strokeWidth = 1.2
        ..style       = PaintingStyle.stroke;

      final wavePath = Path();
      final start    = pts[2]; // Kawayan
      final end      = pts[3]; // Sambawan Port
      final mid      = Offset.lerp(start, end, 0.5)! + const Offset(0, 30);

      wavePath.moveTo(start.dx, start.dy);
      wavePath.quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
      canvas.drawPath(wavePath, arcPaint);
    }
  }

  @override
  bool shouldRepaint(_RouteLinePainter old) => old.progress != progress;
}

/// Provider matching — subtle grid dots glow pattern.
class _ProviderGridPainter extends CustomPainter {
  _ProviderGridPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rng  = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    // Sparse dot grid
    const cols = 8;
    const rows = 16;
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        final x     = (c + 0.5) / cols * size.width;
        final y     = (r + 0.5) / rows * size.height;
        final phase = rng.nextDouble();
        final alpha = (math.sin((progress + phase) * math.pi * 2) + 1) / 2;

        paint.color = Colors.white.withValues(alpha: alpha * 0.09);
        canvas.drawCircle(Offset(x, y), 1.8, paint);
      }
    }

    // Verified badge glow rings (3 positions)
    final badges = [
      Offset(size.width * 0.25, size.height * 0.20),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.50, size.height * 0.18),
    ];
    for (final pos in badges) {
      final r     = 22.0 + progress * 12.0;
      final alpha = 0.10 + progress * 0.08;
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color       = Colors.white.withValues(alpha: alpha)
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 2
          ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(_ProviderGridPainter old) => old.progress != progress;
}

/// Weather check — soft rain particle lines.
class _WeatherPainter extends CustomPainter {
  _WeatherPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rng   = math.Random(7);
    final paint = Paint()
      ..color       = Colors.white.withValues(alpha: 0.09)
      ..strokeWidth = 1.0
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    // Rain streaks
    for (int i = 0; i < 28; i++) {
      final startX = rng.nextDouble() * size.width;
      final offset = (progress + rng.nextDouble()) % 1.0;
      final startY = offset * size.height;
      const len    = 22.0;
      const angle  = 0.18; // slight diagonal

      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + len * angle, startY + len),
        paint,
      );
    }

    // Cloud-like blurred circle at top
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.12),
      size.width * 0.25,
      Paint()
        ..color      = Colors.white.withValues(alpha: 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );
  }

  @override
  bool shouldRepaint(_WeatherPainter old) => old.progress != progress;
}

/// Success particle burst for the finalizing phase.
class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final cx  = size.width / 2;
    final cy  = size.height * 0.38;
    final rng = math.Random(13);

    for (int i = 0; i < 32; i++) {
      final angle    = rng.nextDouble() * math.pi * 2;
      final speed    = 40.0 + rng.nextDouble() * 120.0;
      final r        = rng.nextDouble() * 3.5 + 1.5;
      final t        = (progress * (0.5 + rng.nextDouble() * 0.5)).clamp(0.0, 1.0);
      final dist     = t * speed;
      final alpha    = (1.0 - t) * 0.70;

      final colors   = [Colors.white, const Color(0xFFFB923C), const Color(0xFF0EA5E9)];
      final color    = colors[i % colors.length];

      canvas.drawCircle(
        Offset(
          cx + math.cos(angle) * dist,
          cy + math.sin(angle) * dist,
        ),
        r * (1.0 - t * 0.5),
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
