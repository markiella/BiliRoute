import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../repositories/auth_repository.dart';
import '../services/mock_verification_service.dart';
import '../widgets/auth_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ForgotPasswordOtpScreen — Step 2: Enter OTP
// ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key, required this.email});

  final String email;

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final _otpKey   = GlobalKey<OtpInputWidgetState>();
  final _timerKey = GlobalKey<CountdownTimerState>();

  bool   _isVerifying  = false;
  bool   _hasError     = false;
  bool   _resendActive = false;
  String _errorMsg     = '';
  String _currentOtp   = '';

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name   = parts[0];
    final masked = name.length > 3
        ? '${name.substring(0, 2)}${'*' * (name.length - 2)}'
        : '***';
    return '$masked@${parts[1]}';
  }

  void _onCountdownExpired() => setState(() => _resendActive = true);

  Future<void> _resend() async {
    if (!_resendActive) return;
    setState(() { _resendActive = false; _hasError = false; _errorMsg = ''; });
    _otpKey.currentState?.clear();
    _timerKey.currentState?.reset();
    final repo = context.read<AuthRepository>();
    if (repo.useMockAuth) {
      await authVerificationService.sendPasswordResetOtp(widget.email);
    } else {
      await repo.forgotPassword(email: widget.email);
    }
  }

  Future<void> _verify() async {
    if (_currentOtp.length != 6 || _isVerifying) return;
    setState(() { _isVerifying = true; _hasError = false; _errorMsg = ''; });

    final repo = context.read<AuthRepository>();
    final ok = await authVerificationService
        .verifyPasswordResetOtp(widget.email, _currentOtp);

    if (!mounted) return;
    if (ok) {
      context.pushReplacement(AppRouter.resetPassword, extra: widget.email);
    } else {
      setState(() {
        _isVerifying = false;
        _hasError    = true;
        _errorMsg    = repo.errorMessage ?? 'Invalid code. Please try again.';
      });
      Future.delayed(600.ms, () {
        if (mounted) setState(() => _hasError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // ── Back button ──────────────────────────────────────────────
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

              SizedBox(height: 36.h),

              // ── Icon ─────────────────────────────────────────────────────
              Container(
                width:  96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                    colors: [Color(0xFF1458D4), Color(0xFF15C6D9)],
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color:      const Color(0xFF1458D4).withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset:     const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(Icons.password_rounded, color: Colors.white, size: 46.sp),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),

              SizedBox(height: 28.h),

              Text(
                'Enter Reset Code',
                style: TextStyle(
                  fontSize:   24.sp,
                  fontWeight: FontWeight.w900,
                  color:      const Color(0xFF0F2554),
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0),

              SizedBox(height: 10.h),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Enter the 6-digit code we sent to\n',
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

              // ── Demo / Offline OTP Hint ────────────────────────────────────
              if (context.watch<AuthRepository>().useMockAuth) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: const Color(0xFF0D9488), size: 16.sp),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'Test Mode: Enter 654321 to reset password',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0D9488),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 180.ms).fade(duration: 300.ms),
              ],

              SizedBox(height: 36.h),

              // ── OTP boxes ─────────────────────────────────────────────────
              OtpInputWidget(
                key:         _otpKey,
                hasError:    _hasError,
                onChanged:   (otp) => setState(() => _currentOtp = otp),
                onCompleted: (otp) {
                  setState(() => _currentOtp = otp);
                  _verify();
                },
              ).animate(delay: 200.ms).fade(duration: 400.ms),

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

              CountdownTimer(
                key:       _timerKey,
                onExpired: _onCountdownExpired,
              ).animate(delay: 250.ms).fade(duration: 400.ms),

              SizedBox(height: 6.h),

              Text(
                'Code expires in',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
              ).animate(delay: 280.ms).fade(duration: 400.ms),

              SizedBox(height: 28.h),

              AuthCTAButton(
                label:     'Verify Code',
                isLoading: _isVerifying,
                onTap:     _currentOtp.length == 6 && !_isVerifying ? _verify : null,
              )
                  .animate(delay: 300.ms)
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.08, end: 0),

              SizedBox(height: 16.h),

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
