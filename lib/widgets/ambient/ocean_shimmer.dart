import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Renders 2–3 soft sine-wave lines along the bottom of its paint area,
/// gently animated to simulate a calm ocean surface shimmer.
///
/// Use as a thin strip (height 30–50px) at the bottom of sea-route headers.
class OceanShimmer extends StatefulWidget {
  const OceanShimmer({
    super.key,
    this.waveColor = const Color(0xFF7DD3FC),
    this.height    = 40.0,
    this.amplitude = 5.0,   // max vertical oscillation in px
    this.opacity   = 0.45,
  });

  final Color  waveColor;
  final double height;
  final double amplitude;
  final double opacity;

  @override
  State<OceanShimmer> createState() => _OceanShimmerState();
}

class _OceanShimmerState extends State<OceanShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: IgnorePointer(
        child: Opacity(
          opacity: widget.opacity,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => CustomPaint(
              painter: _WavePainter(
                progress:  _ctrl.value,
                color:     widget.waveColor,
                amplitude: widget.amplitude,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

// ── CustomPainter ──────────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.progress,
    required this.color,
    required this.amplitude,
  });

  final double progress;
  final Color  color;
  final double amplitude;

  @override
  void paint(Canvas canvas, Size size) {
    // Three wave layers — slightly offset phase, slightly different opacity
    _drawWave(canvas, size, phase: 0.0,  opacity: 0.60, yOffset: 0.35);
    _drawWave(canvas, size, phase: 0.33, opacity: 0.40, yOffset: 0.55);
    _drawWave(canvas, size, phase: 0.66, opacity: 0.25, yOffset: 0.75);
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double phase,
    required double opacity,
    required double yOffset,
  }) {
    final paint = Paint()
      ..color       = color.withValues(alpha: opacity)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap   = StrokeCap.round;

    final path  = Path();
    final angle = (progress + phase) * math.pi * 2;
    final baseY = size.height * yOffset;

    path.moveTo(0, baseY);
    for (double x = 0; x <= size.width; x += 2) {
      final y = baseY +
          amplitude * math.sin(angle + (x / size.width) * math.pi * 3.5);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}
