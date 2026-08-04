import 'package:flutter/material.dart';

/// Adds a soft pulsing color halo around [child].
///
/// The halo is drawn as a [BoxDecoration] with animated [BoxShadow] opacity
/// cycling between [minOpacity] and [maxOpacity].
///
/// Use on: hidden-gem markers, active CTA buttons, smart-system indicators.
class AmbientGlow extends StatefulWidget {
  const AmbientGlow({
    super.key,
    required this.child,
    this.color      = const Color(0xFF14B8A6),
    this.blurRadius = 14.0,
    this.minOpacity = 0.08,
    this.maxOpacity = 0.38,
    this.duration   = const Duration(milliseconds: 2000),
    this.borderRadius,
  });

  final Widget            child;
  final Color             color;
  final double            blurRadius;
  final double            minOpacity;
  final double            maxOpacity;
  final Duration          duration;
  final BorderRadius?     borderRadius;

  @override
  State<AmbientGlow> createState() => _AmbientGlowState();
}

class _AmbientGlowState extends State<AmbientGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _glow = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, child) {
        final opacity = widget.minOpacity +
            (_glow.value * (widget.maxOpacity - widget.minOpacity));
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color:      widget.color.withValues(alpha: opacity),
                blurRadius: widget.blurRadius,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
