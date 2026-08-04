import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/saved/saved_destinations_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HeartButton — animated save/unsave toggle for destination cards
// ─────────────────────────────────────────────────────────────────────────────

class HeartButton extends StatefulWidget {
  const HeartButton({
    super.key,
    required this.destinationId,
    this.size = 22.0,
  });

  final String destinationId;
  final double size;

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 300),
    );
    // Bounce: 1.0 → 1.35 → 1.0
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 55),
    ]).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    HapticFeedback.lightImpact();
    await context.read<SavedDestinationsNotifier>().toggle(widget.destinationId);
    _scaleCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final saved = context
        .watch<SavedDestinationsNotifier>()
        .isSaved(widget.destinationId);

    return GestureDetector(
      onTap:     _onTap,
      behavior:  HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedSwitcher(
          duration:       const Duration(milliseconds: 200),
          switchInCurve:  Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: child,
          ),
          child: Icon(
            saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key:   ValueKey(saved),
            color: saved ? const Color(0xFFEF4444) : Colors.white,
            size:  widget.size,
          ),
        ),
      ),
    );
  }
}
