import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens for auth screens
// ─────────────────────────────────────────────────────────────────────────────

const _kTeal        = Color(0xFF0D9488); // primary teal accent
const _kNavy        = Color(0xFF0F2554); // deep navy for headlines/buttons
const _kFieldBorder = Color(0xFFCBD5E1); // slate-300
const _kFieldBg     = Color(0xFFF8FAFC); // slate-50

// ─────────────────────────────────────────────────────────────────────────────
// Wave clipper — separates image header from white form area
// ─────────────────────────────────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5,  size.height - 24,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 48,
      size.width,        size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth image header — wave-clipped photo with overlaid content
// ─────────────────────────────────────────────────────────────────────────────

class AuthImageHeader extends StatelessWidget {
  const AuthImageHeader({
    super.key,
    required this.imagePath,
    required this.height,
    required this.child,
  });

  final String imagePath;
  final double height;
  final Widget child;   // headline + subtitle overlay

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipPath(
        clipper: _WaveClipper(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            Image.asset(imagePath, fit: BoxFit.cover),

            // Gradient scrim — lighter at top, darker at bottom
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [
                    Color(0x44FFFFFF),
                    Color(0xCC0F2554),
                  ],
                  stops: [0.35, 1.0],
                ),
              ),
            ),

            // Content (wordmark + headline)
            child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BiliRoute wordmark row (logo placeholder + text)
// ─────────────────────────────────────────────────────────────────────────────

class AuthWordmark extends StatelessWidget {
  const AuthWordmark({super.key, this.showBack = false, this.onBack});
  final bool         showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          GestureDetector(
            onTap: onBack,
            child: Container(
              width:  34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color:        Colors.white.withValues(alpha: 0.20),
                shape:        BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 16.sp),
            ),
          ),
          SizedBox(width: 10.w),
        ],
        // Logo icon
        Container(
          width:  36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Icon(Icons.explore_rounded,
                color: _kTeal, size: 20.sp),
          ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:        MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:  'Bili',
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text:  'Route',
                    style: TextStyle(
                      color:      const Color(0xFF67E8F9), // cyan-300
                      fontSize:   16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Smart Tourism Mobility Platform',
              style: TextStyle(
                color:    Colors.white.withValues(alpha: 0.75),
                fontSize: 8.5.sp,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Clean auth text field — matches design: outlined, light bg, icon prefix
// ─────────────────────────────────────────────────────────────────────────────

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword      = false,
    this.keyboardType    = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.validator,
  });

  final TextEditingController      controller;
  final String                     hint;
  final IconData                   icon;
  final bool                       isPassword;
  final TextInputType              keyboardType;
  final TextInputAction            textInputAction;
  final ValueChanged<String>?      onSubmitted;
  final String? Function(String?)? validator;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focus;
  bool _obscure = true;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()
      ..addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color:        _kFieldBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _focused ? _kTeal : _kFieldBorder,
          width: _focused ? 1.6 : 1.0,
        ),
        boxShadow: _focused
            ? [BoxShadow(
                color:      _kTeal.withValues(alpha: 0.12),
                blurRadius: 8,
                offset:     const Offset(0, 2),
              )]
            : [],
      ),
      child: TextFormField(
        controller:       widget.controller,
        focusNode:        _focus,
        obscureText:      widget.isPassword && _obscure,
        keyboardType:     widget.keyboardType,
        textInputAction:  widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        validator:        widget.validator,
        style: TextStyle(
          color:      AppColors.textPrimary,
          fontSize:   13.5.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText:  widget.hint,
          hintStyle: TextStyle(
            color:    const Color(0xFF94A3B8),
            fontSize: 13.sp,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: _focused ? _kTeal : const Color(0xFF94A3B8),
            size:  18.sp,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF94A3B8),
                    size:  17.sp,
                  ),
                )
              : null,
          border:         InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w, vertical: 14.h),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary CTA button — navy→teal gradient with arrow icon
// ─────────────────────────────────────────────────────────────────────────────

class AuthCTAButton extends StatefulWidget {
  const AuthCTAButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.gradient,
  });

  final String          label;
  final VoidCallback    onTap;
  final bool            isLoading;
  final LinearGradient? gradient;

  @override
  State<AuthCTAButton> createState() => _AuthCTAButtonState();
}

class _AuthCTAButtonState extends State<AuthCTAButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ??
        const LinearGradient(
          colors: [Color(0xFF0F2554), Color(0xFF1D4ED8), Color(0xFF0891B2)],
          begin:  Alignment.centerLeft,
          end:    Alignment.centerRight,
        );

    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        width:  double.infinity,
        height: 52.h,
        transform: Matrix4.diagonal3Values(
          _pressed ? 0.97 : 1.0,
          _pressed ? 0.97 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient:     gradient,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color:      _kNavy.withValues(alpha: 0.30),
              blurRadius: 14,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color:         Colors.white,
                        fontSize:      15.sp,
                        fontWeight:    FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18.sp),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Outline button — Google / Guest
// ─────────────────────────────────────────────────────────────────────────────

class AuthOutlineButton extends StatefulWidget {
  const AuthOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.leadingWidget,
  });
  final String       label;
  final VoidCallback onTap;
  final IconData?    icon;
  final Widget?      leadingWidget;

  @override
  State<AuthOutlineButton> createState() => _AuthOutlineButtonState();
}

class _AuthOutlineButtonState extends State<AuthOutlineButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width:  double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color:        _pressed
              ? AppColors.primary.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _kFieldBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.04),
              blurRadius: 6, offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.leadingWidget != null) ...[
              widget.leadingWidget!,
              SizedBox(width: 10.w),
            ] else if (widget.icon != null) ...[
              Icon(widget.icon,
                  size: 19.sp, color: AppColors.textSecondary),
              SizedBox(width: 10.w),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color:      AppColors.textPrimary,
                fontSize:   14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google logo "G" widget
// ─────────────────────────────────────────────────────────────────────────────

class GoogleLogoWidget extends StatelessWidget {
  const GoogleLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  22.r,
      height: 22.r,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];
    final sweeps = [90.0, 90.0, 90.0, 90.0];
    var start   = -90.0;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = size.width * 0.18;

    for (int i = 0; i < 4; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - paint.strokeWidth / 2),
        _deg(start), _deg(sweeps[i]), false, paint,
      );
      start += sweeps[i];
    }
  }

  double _deg(double deg) => deg * 3.14159265 / 180;

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Travel preference chip — teal selected variant
// ─────────────────────────────────────────────────────────────────────────────

class TravelChip extends StatelessWidget {
  const TravelChip({
    super.key,
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
    this.delay = Duration.zero,
  });
  final String       label;
  final String       emoji;
  final bool         selected;
  final VoidCallback onTap;
  final Duration     delay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected
              ? _kTeal.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? _kTeal : _kFieldBorder,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 13.sp)),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize:   11.5.sp,
                fontWeight: FontWeight.w700,
                color:      selected
                    ? _kTeal
                    : AppColors.textSecondary,
              ),
            ),
            if (selected) ...[
              SizedBox(width: 5.w),
              Icon(Icons.check_circle_rounded,
                  color: _kTeal, size: 13.sp),
            ],
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fade(duration: 280.ms)
        .scale(begin: const Offset(0.90, 0.90), curve: Curves.easeOutBack);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trust badge row (login bottom)
// ─────────────────────────────────────────────────────────────────────────────

class AuthTrustBadge extends StatelessWidget {
  const AuthTrustBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width:  28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color:        _kTeal.withValues(alpha: 0.12),
            shape:        BoxShape.circle,
            border: Border.all(color: _kTeal.withValues(alpha: 0.35)),
          ),
          child: Icon(Icons.verified_user_rounded,
              color: _kTeal, size: 14.sp),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your adventure is safe with us.',
              style: TextStyle(
                color:      AppColors.textPrimary,
                fontSize:   10.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  'Verified by Biliran Tourism Office',
                  style: TextStyle(
                    color:    _kTeal,
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(Icons.verified_rounded,
                    color: _kTeal, size: 11.sp),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
