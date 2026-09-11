import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import 'animated_password_visibility.dart';

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
    this.errorText,
    this.onSubmitted,
    this.validator,
  });

  final TextEditingController      controller;
  final String                     hint;
  final IconData                   icon;
  final bool                       isPassword;
  final TextInputType              keyboardType;
  final TextInputAction            textInputAction;
  final String?                    errorText;
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
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color:        hasError ? const Color(0xFFFEF2F2) : _kFieldBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFEF4444)
                  : (_focused ? _kTeal : _kFieldBorder),
              width: (hasError || _focused) ? 1.6 : 1.0,
            ),
            boxShadow: _focused && !hasError
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
                color: hasError
                    ? const Color(0xFFEF4444)
                    : (_focused ? _kTeal : const Color(0xFF94A3B8)),
                size:  18.sp,
              ),
              suffixIcon: widget.isPassword
                  ? AnimatedPasswordVisibility(
                      isVisible: !_obscure,
                      onTap:     () => setState(() => _obscure = !_obscure),
                    )
                  : null,
              border:         InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w, vertical: 14.h),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color:      const Color(0xFFEF4444),
                fontSize:   11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
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
    this.onTap,
    this.isLoading = false,
    this.gradient,
  });

  final String          label;
  final VoidCallback?   onTap;
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
      onTapDown:   (_) { if (widget.onTap != null) setState(() => _pressed = true); },
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap?.call(); },
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

// ─────────────────────────────────────────────────────────────────────────────
// ValidationText — inline ✓ / ✕ rule indicator
// ─────────────────────────────────────────────────────────────────────────────

class ValidationText extends StatelessWidget {
  const ValidationText({
    super.key,
    required this.label,
    required this.isPassed,
    this.color,
  });

  final String label;
  final bool   isPassed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (isPassed ? const Color(0xFF10B981) : AppColors.textSecondary);
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Icon(
              isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded,
              key:   ValueKey('$isPassed-${effectiveColor.toARGB32()}'),
              color: effectiveColor,
              size:  14.sp,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                color:    effectiveColor,
                fontWeight: isPassed ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PasswordStrengthIndicator — animated strength bar + label
// ─────────────────────────────────────────────────────────────────────────────

enum PasswordStrength { empty, weak, fair, strong }

/// Compute strength from a password string.
PasswordStrength passwordStrength(String pw) {
  if (pw.isEmpty) return PasswordStrength.empty;
  int score = 0;
  if (pw.length >= 8)                               score++;
  if (RegExp(r'[A-Z]').hasMatch(pw))                score++;
  if (RegExp(r'[a-z]').hasMatch(pw))                score++;
  if (RegExp(r'[0-9]').hasMatch(pw))                score++;
  if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pw)) score++;
  if (score <= 1) return PasswordStrength.weak;
  if (score <= 3) return PasswordStrength.fair;
  return PasswordStrength.strong;
}

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = passwordStrength(password);
    if (strength == PasswordStrength.empty) return const SizedBox.shrink();

    final (label, color, filled) = switch (strength) {
      PasswordStrength.weak   => ('Weak',   const Color(0xFFEF4444), 1),
      PasswordStrength.fair   => ('Fair',   const Color(0xFFF59E0B), 2),
      PasswordStrength.strong => ('Strong', const Color(0xFF10B981), 3),
      PasswordStrength.empty  => ('',       Colors.transparent,       0),
    };

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Three segment bar
          Row(
            children: List.generate(3, (i) {
              final active = i < filled;
              return Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.only(right: i < 2 ? 4.w : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: active ? color : const Color(0xFFE2E8F0),
                  ),
                )
                    .animate(target: active ? 1 : 0)
                    .custom(
                      duration: const Duration(milliseconds: 350),
                      builder: (_, val, child) => Opacity(
                        opacity: active ? 1.0 : 0.4,
                        child: child,
                      ),
                    ),
              );
            }),
          ),
          SizedBox(height: 4.h),
          Text(
            'Password strength: $label',
            style: TextStyle(
              fontSize:   10.5.sp,
              color:      color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OtpInputWidget — 6 individual styled boxes
// ─────────────────────────────────────────────────────────────────────────────

class OtpInputWidget extends StatefulWidget {
  const OtpInputWidget({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.hasError = false,
  });

  /// Called when all 6 digits have been entered.
  final ValueChanged<String> onCompleted;

  /// Called on every change with the current partial OTP.
  final ValueChanged<String>? onChanged;

  /// When true, boxes flash red.
  final bool hasError;

  @override
  State<OtpInputWidget> createState() => OtpInputWidgetState();
}

class OtpInputWidgetState extends State<OtpInputWidget> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes  = List.generate(6, (_) => FocusNode());

  String get currentOtp =>
      _controllers.map((c) => c.text).join();

  /// Clear all boxes and refocus first box.
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes)  { f.dispose(); }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste — distribute digits
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');
      for (var i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final next = (digits.length - 1).clamp(0, 5);
      _focusNodes[next].requestFocus();
    } else if (value.isNotEmpty) {
      if (index < 5) _focusNodes[index + 1].requestFocus();
    }

    final otp = currentOtp;
    widget.onChanged?.call(otp);
    if (otp.length == 6) widget.onCompleted(otp);
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey.keyLabel == 'Backspace' &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final active  = _focusNodes[i].hasFocus;
        final filled  = _controllers[i].text.isNotEmpty;
        final errored = widget.hasError;

        final borderColor = errored
            ? const Color(0xFFEF4444)
            : active
                ? _kTeal
                : filled
                    ? _kNavy.withValues(alpha: 0.4)
                    : _kFieldBorder;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (e) => _onKeyEvent(i, e),
            child: SizedBox(
              width:  44.w,
              height: 52.h,
              child: TextFormField(
                controller:  _controllers[i],
                focusNode:   _focusNodes[i],
                keyboardType: TextInputType.number,
                textAlign:   TextAlign.center,
                maxLength:   1,
                onChanged:   (v) => _onChanged(i, v),
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                style: TextStyle(
                  fontSize:   20.sp,
                  fontWeight: FontWeight.w800,
                  color:      errored ? const Color(0xFFEF4444) : _kNavy,
                ),
                decoration: InputDecoration(
                  filled:      true,
                  fillColor:   errored
                      ? const Color(0xFFFEF2F2)
                      : active
                          ? _kTeal.withValues(alpha: 0.06)
                          : _kFieldBg,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                ),
              ),
            ),
          ),
        )
            .animate(target: errored ? 1 : 0)
            .shake(hz: 4, offset: const Offset(3, 0), duration: 500.ms);
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CountdownTimer — MM:SS live countdown with onExpired callback
// ─────────────────────────────────────────────────────────────────────────────

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    this.durationSeconds = 300, // 5 minutes
    required this.onExpired,
    this.onReset,
  });

  final int         durationSeconds;
  final VoidCallback onExpired;
  final VoidCallback? onReset;

  @override
  State<CountdownTimer> createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer> {
  late int _remaining;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _tick();
  }

  void reset() {
    setState(() {
      _remaining = widget.durationSeconds;
      _expired   = false;
    });
    _tick();
  }

  void _tick() async {
    while (mounted && _remaining > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _remaining--);
    }
    if (mounted && _remaining == 0 && !_expired) {
      setState(() => _expired = true);
      widget.onExpired();
    }
  }

  String get _display {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining  %  60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _display,
        key: ValueKey(_remaining),
        style: TextStyle(
          fontSize:   22.sp,
          fontWeight: FontWeight.w800,
          color:      _remaining <= 30
              ? const Color(0xFFEF4444)
              : _kNavy,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VerificationSuccessOverlay — full-screen animated success state
// ─────────────────────────────────────────────────────────────────────────────

class VerificationSuccessOverlay extends StatefulWidget {
  const VerificationSuccessOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onDone,
    this.doneLabel = 'Continue',
  });

  final String       title;
  final String       subtitle;
  final VoidCallback onDone;
  final String       doneLabel;

  @override
  State<VerificationSuccessOverlay> createState() =>
      _VerificationSuccessOverlayState();
}

class _VerificationSuccessOverlayState
    extends State<VerificationSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: 700.ms);
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated check circle
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width:  96.r,
                    height: 96.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size:  52.sp,
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:   22.sp,
                    fontWeight: FontWeight.w900,
                    color:      _kNavy,
                    height:     1.2,
                  ),
                ).animate(delay: 400.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0),

                SizedBox(height: 10.h),

                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color:    AppColors.textSecondary,
                    height:   1.55,
                  ),
                ).animate(delay: 500.ms).fade(duration: 400.ms),

                SizedBox(height: 40.h),

                AuthCTAButton(
                  label: widget.doneLabel,
                  onTap: widget.onDone,
                ).animate(delay: 650.ms).fade(duration: 400.ms).slideY(begin: 0.08, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
