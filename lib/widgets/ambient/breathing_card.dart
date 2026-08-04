import 'package:flutter/material.dart';

/// Wraps [child] in a slow-breathing shadow + micro-scale pulse.
///
/// The effect is extremely subtle (scale 1.000 → 1.003, shadow blur ±4px)
/// so it reads as "alive" without being distracting.
///
/// Period: [duration] (default 3.2s). Animation repeats indefinitely.
class BreathingCard extends StatefulWidget {
  const BreathingCard({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF3B82F6),
    this.duration  = const Duration(milliseconds: 3200),
    this.maxGlow   = 0.18,   // shadow opacity at peak breath
    this.enabled   = true,
  });

  final Widget   child;

  /// Color of the breathing shadow glow.
  final Color    glowColor;

  /// Full breath cycle duration.
  final Duration duration;

  /// Peak shadow opacity (0.0–1.0).
  final double   maxGlow;

  /// Set to false to disable breathing (e.g. unselected cards).
  final bool     enabled;

  @override
  State<BreathingCard> createState() => _BreathingCardState();
}

class _BreathingCardState extends State<BreathingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _breath;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _breath = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.enabled) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BreathingCard old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !old.enabled) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.enabled && old.enabled) {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _breath,
      builder: (_, child) {
        final t     = _breath.value;
        final glow  = widget.maxGlow * t;
        final scale = 1.0 + 0.003 * t;

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:      widget.glowColor.withValues(alpha: glow),
                  blurRadius: 12 + 8 * t,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
