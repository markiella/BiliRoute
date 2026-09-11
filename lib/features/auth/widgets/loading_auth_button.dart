import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthButtonState — 4 states for premium authentication feedback
// ─────────────────────────────────────────────────────────────────────────────

enum AuthButtonState { idle, loading, success, error }

// ─────────────────────────────────────────────────────────────────────────────
// LoadingAuthButton — Multi-state button with smooth animations
// ─────────────────────────────────────────────────────────────────────────────

class LoadingAuthButton extends StatefulWidget {
  const LoadingAuthButton({
    super.key,
    required this.label,
    required this.onTap,
    this.state = AuthButtonState.idle,
    this.gradient,
  });

  final String          label;
  final VoidCallback?   onTap;
  final AuthButtonState state;
  final LinearGradient? gradient;

  @override
  State<LoadingAuthButton> createState() => _LoadingAuthButtonState();
}

class _LoadingAuthButtonState extends State<LoadingAuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isIdle    = widget.state == AuthButtonState.idle;
    final isLoading = widget.state == AuthButtonState.loading;
    final isSuccess = widget.state == AuthButtonState.success;
    final isError   = widget.state == AuthButtonState.error;

    final defaultGradient = const LinearGradient(
      colors: [Color(0xFF0F2554), Color(0xFF1D4ED8), Color(0xFF0891B2)],
      begin:  Alignment.centerLeft,
      end:    Alignment.centerRight,
    );

    final successGradient = const LinearGradient(
      colors: [Color(0xFF059669), Color(0xFF10B981)],
      begin:  Alignment.centerLeft,
      end:    Alignment.centerRight,
    );

    final errorGradient = const LinearGradient(
      colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
      begin:  Alignment.centerLeft,
      end:    Alignment.centerRight,
    );

    final activeGradient = isSuccess
        ? successGradient
        : isError
            ? errorGradient
            : (widget.gradient ?? defaultGradient);

    Widget childWidget;

    if (isLoading) {
      childWidget = Row(
        key: const ValueKey('loading'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width:  20.r,
            height: 20.r,
            child: const CircularProgressIndicator(
              color:       Colors.white,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Signing you in...',
            style: TextStyle(
              color:      Colors.white,
              fontSize:   14.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      );
    } else if (isSuccess) {
      childWidget = Row(
        key: const ValueKey('success'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 22.sp),
          SizedBox(width: 8.w),
          Text(
            'Welcome back!',
            style: TextStyle(
              color:      Colors.white,
              fontSize:   14.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      );
    } else if (isError) {
      childWidget = Row(
        key: const ValueKey('error'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.white, size: 22.sp),
          SizedBox(width: 8.w),
          Text(
            'Authentication Failed',
            style: TextStyle(
              color:      Colors.white,
              fontSize:   14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    } else {
      childWidget = Row(
        key: const ValueKey('idle'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color:      Colors.white,
              fontSize:   14.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18.sp),
        ],
      );
    }

    final buttonContainer = GestureDetector(
      onTapDown:   (_) { if (isIdle && widget.onTap != null) setState(() => _pressed = true); },
      onTapUp:     (_) { setState(() => _pressed = false); if (isIdle) widget.onTap?.call(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        width:  double.infinity,
        height: 52.h,
        transform: Matrix4.diagonal3Values(
          _pressed ? 0.98 : 1.0,
          _pressed ? 0.98 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          gradient: activeGradient,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: (isSuccess
                      ? const Color(0xFF10B981)
                      : isError
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF1D4ED8))
                  .withValues(alpha: _pressed ? 0.20 : 0.38),
              blurRadius: _pressed ? 8 : 16,
              offset:     Offset(0, _pressed ? 2 : 6),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: childWidget,
        ),
      ),
    );

    if (isError) {
      return buttonContainer
          .animate()
          .shake(hz: 4, offset: const Offset(6, 0), duration: 450.ms);
    }

    return buttonContainer;
  }
}
