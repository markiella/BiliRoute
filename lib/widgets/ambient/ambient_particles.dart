import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A lightweight ambient particle overlay that renders N soft glowing dots
/// drifting slowly upward on a looping animation.
///
/// Designed to be used as a [Positioned.fill] overlay — does NOT consume
/// touch events ([HitTestBehavior.transparent]).
///
/// Performance: single [AnimationController], repaints only particle bounds.
class AmbientParticles extends StatefulWidget {
  const AmbientParticles({
    super.key,
    this.count     = 14,
    this.color     = const Color(0xFFBAE6FD),
    this.maxRadius = 3.5,
    this.speed     = 0.6,   // 1.0 = normal, lower = slower drift
    this.opacity   = 0.55,
    this.seed      = 0,
  });

  /// Number of particles to render.
  final int    count;

  /// Base color of each particle (glowing dot).
  final Color  color;

  /// Maximum radius of the largest particle (px).
  final double maxRadius;

  /// Drift speed multiplier (0.0–1.0). Lower = more calming.
  final double speed;

  /// Overall opacity of the particle layer.
  final double opacity;

  /// Random seed — change to re-randomize positions (e.g. on page change).
  final int    seed;

  @override
  State<AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<AmbientParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late List<_Particle>           _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: Duration(seconds: (18 / widget.speed).round()),
    )..repeat();
    _initParticles();
  }

  @override
  void didUpdateWidget(AmbientParticles old) {
    super.didUpdateWidget(old);
    if (old.seed != widget.seed || old.count != widget.count) {
      _initParticles();
    }
  }

  void _initParticles() {
    final rng = math.Random(widget.seed + widget.count);
    _particles = List.generate(
      widget.count,
      (_) => _Particle(rng, widget.maxRadius),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: widget.opacity,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              progress:  _ctrl.value,
              color:     widget.color,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

// ── Internal model ─────────────────────────────────────────────────────────────

class _Particle {
  _Particle(math.Random rng, double maxR) :
    x      = rng.nextDouble(),          // fractional [0,1]
    yStart = rng.nextDouble(),          // fractional [0,1] — offset start
    radius = 1.2 + rng.nextDouble() * (maxR - 1.2),
    phase  = rng.nextDouble(),          // phase offset so they're staggered
    wobble = (rng.nextDouble() - 0.5) * 0.04; // gentle horizontal sway

  final double x, yStart, radius, phase, wobble;
}

// ── CustomPainter ─────────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  final List<_Particle> particles;
  final double          progress;
  final Color           color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Each particle drifts from bottom to top over its own cycle
      final t    = (progress + p.phase) % 1.0;
      final yRaw = 1.0 - t;                         // 1.0 → 0.0 (bottom to top)
      final yPos = ((yRaw + p.yStart) % 1.0) * size.height;
      final xPos = (p.x + math.sin(t * math.pi * 2) * p.wobble) * size.width;

      // Fade in at bottom, fade out at top
      final fade = t < 0.15
          ? t / 0.15
          : t > 0.80
              ? (1.0 - t) / 0.20
              : 1.0;

      final paint = Paint()
        ..color      = color.withValues(alpha: fade.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      canvas.drawCircle(Offset(xPos, yPos), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress || old.color != color;
}
