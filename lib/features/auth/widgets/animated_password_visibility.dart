import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedPasswordVisibility — Eye reveal / hide toggle widget
//
// Smooth 300ms animated rotation & scale morph between eye-open and eye-slash
// visibility states with zero layout shifts. Supports Light & Dark modes.
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedPasswordVisibility extends StatelessWidget {
  const AnimatedPasswordVisibility({
    super.key,
    required this.isVisible,
    required this.onTap,
    this.color,
  });

  final bool         isVisible;
  final VoidCallback onTap;
  final Color?       color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF94A3B8);

    return SizedBox(
      width:  40.r,
      height: 40.r,
      child: IconButton(
        onPressed:    onTap,
        splashRadius: 20.r,
        padding:      EdgeInsets.zero,
        icon: AnimatedSwitcher(
          duration:       const Duration(milliseconds: 300),
          switchInCurve:  Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween<double>(begin: 0.15, end: 0).animate(anim),
            child: ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
          ),
          child: Icon(
            isVisible
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            key:   ValueKey(isVisible),
            color: isVisible ? const Color(0xFF0D9488) : effectiveColor,
            size:  19.sp,
          ),
        ),
      ),
    );
  }
}
