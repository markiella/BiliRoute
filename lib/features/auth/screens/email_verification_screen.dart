import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../services/mock_verification_service.dart';
import '../widgets/auth_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EmailVerificationScreen
//
// Shown after registration. Accepts the email as GoRouter `extra` String.
// Mock OTP: 123456
// ─────────────────────────────────────────────────────────────────────────────

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  // Keys for child state methods
  final _otpKey     = GlobalKey<OtpInputWidgetState>();
  final _timerKey   = GlobalKey<CountdownTimerState>();

  bool _isVerifying  = false;
  bool _hasError     = false;
  bool _resendActive = false;
  bool _success      = false;
  String _errorMsg   = '';
  String _currentOtp = '';

  // ── Send initial OTP on mount ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    await authVerificationService.sendEmailVerificationOtp(widget.email);
  }

  // ── Countdown expired → enable Resend ─────────────────────────────────────
  void _onCountdownExpired() {
    setState(() => _resendActive = true);
  }

  // ── Resend ────────────────────────────────────────────────────────────────
  Future<void> _resend() async {
    if (!_resendActive) return;
    setState(() {
      _resendActive = false;
      _hasError     = false;
      _errorMsg     = '';
    });
    _otpKey.currentState?.clear();
    _timerKey.currentState?.reset();
    await authVerificationService.sendEmailVerificationOtp(widget.email);
  }

  // ── Verify ────────────────────────────────────────────────────────────────
  Future<void> _verify() async {
    if (_currentOtp.length != 6 || _isVerifying) return;
    setState(() {
      _isVerifying = true;
      _hasError    = false;
      _errorMsg    = '';
    });

    final ok = await authVerificationService.verifyEmailOtp(
        widget.email, _currentOtp);

    if (!mounted) return;

    if (ok) {
      setState(() => _success = true);
    } else {
      setState(() {
        _isVerifying = false;
        _hasError    = true;
        _errorMsg    = 'Invalid verification code. Please try again.';
      });
      // Auto-clear error after shake
      Future.delayed(600.ms, () {
        if (mounted) setState(() => _hasError = false);
      });
    }
  }

  // ── Mask email for display ────────────────────────────────────────────────
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name   = parts[0];
    final domain = parts[1];
    final masked = name.length > 3
        ? '${name.substring(0, 2)}${'*' * (name.length - 2)}'
        : '***';
    return '$masked@$domain';
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        body: VerificationSuccessOverlay(
          title:    'Email Verified!',
          subtitle: 'Your account is ready. Welcome to BiliRoute!',
          doneLabel: 'Go to Login',
          onDone:   () => context.go(AppRouter.login),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // ── Back button ───────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width:  40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color:        AppColors.divider.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16.sp, color: AppColors.textPrimary),
                  ),
                ),
              ).animate().fade(duration: 400.ms),

              SizedBox(height: 32.h),

              // ── Illustration ───────────────────────────────────────────────
              Container(
                width:  120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                    colors: [Color(0xFF1458D4), Color(0xFF15C6D9)],
                  ),
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color:      const Color(0xFF1458D4).withValues(alpha: 0.30),
                      blurRadius: 24,
                      offset:     const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.mark_email_read_rounded,
                    color: Colors.white, size: 58.sp),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),

              SizedBox(height: 28.h),

              // ── Title ───────────────────────────────────────────────────────
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize:   24.sp,
                  fontWeight: FontWeight.w900,
                  color:      const Color(0xFF0F2554),
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0),

              SizedBox(height: 10.h),

              // ── Subtitle ────────────────────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "We've sent a 6-digit verification code to\n",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color:    AppColors.textSecondary,
                    height:   1.55,
                  ),
                  children: [
                    TextSpan(
                      text: _maskEmail(widget.email),
                      style: TextStyle(
                        color:      const Color(0xFF0D9488),
                        fontWeight: FontWeight.w700,
                        fontSize:   13.sp,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 160.ms).fade(duration: 400.ms),

              SizedBox(height: 36.h),

              // ── OTP boxes ───────────────────────────────────────────────────
              OtpInputWidget(
                key:         _otpKey,
                hasError:    _hasError,
                onChanged:   (otp) => setState(() => _currentOtp = otp),
                onCompleted: (otp) {
                  setState(() => _currentOtp = otp);
                  _verify();
                },
              ).animate(delay: 200.ms).fade(duration: 400.ms),

              // ── Error message ───────────────────────────────────────────────
              AnimatedSize(
                duration: 250.ms,
                child: _errorMsg.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Text(
                          _errorMsg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:   12.sp,
                            color:      const Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate().fade(duration: 200.ms),
                      )
                    : const SizedBox.shrink(),
              ),

              SizedBox(height: 32.h),

              // ── Countdown timer ─────────────────────────────────────────────
              CountdownTimer(
                key:       _timerKey,
                onExpired: _onCountdownExpired,
              ).animate(delay: 250.ms).fade(duration: 400.ms),

              SizedBox(height: 6.h),

              Text(
                'Code expires in',
                style: TextStyle(
                  fontSize: 11.sp,
                  color:    AppColors.textSecondary,
                ),
              ).animate(delay: 280.ms).fade(duration: 400.ms),

              SizedBox(height: 28.h),

              // ── Verify Button ───────────────────────────────────────────────
              AuthCTAButton(
                label:     'Verify Email',
                isLoading: _isVerifying,
                onTap:     _currentOtp.length == 6 && !_isVerifying
                    ? _verify
                    : null,
              )
                  .animate(delay: 300.ms)
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.08, end: 0),

              SizedBox(height: 16.h),

              // ── Resend button ───────────────────────────────────────────────
              AnimatedOpacity(
                opacity:  _resendActive ? 1.0 : 0.4,
                duration: 300.ms,
                child: GestureDetector(
                  onTap: _resendActive ? _resend : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: RichText(
                      text: TextSpan(
                        text: "Didn't receive it?  ",
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color:    AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Resend Code',
                            style: TextStyle(
                              color:      const Color(0xFF0D9488),
                              fontWeight: FontWeight.w800,
                              fontSize:   12.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 340.ms).fade(duration: 400.ms),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
