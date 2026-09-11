import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../services/mock_verification_service.dart';
import '../widgets/auth_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ResetPasswordScreen — Step 3: Enter New Password
// ─────────────────────────────────────────────────────────────────────────────

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  String _password = '';
  String _confirm  = '';
  bool   _loading  = false;
  bool   _success  = false;

  // ── Password rules ─────────────────────────────────────────────────────────
  bool get _has8Chars  => _password.length >= 8;
  bool get _hasUpper   => RegExp(r'[A-Z]').hasMatch(_password);
  bool get _hasLower   => RegExp(r'[a-z]').hasMatch(_password);
  bool get _hasNumber  => RegExp(r'[0-9]').hasMatch(_password);
  bool get _hasSpecial => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_password);

  bool get _passwordValid =>
      _has8Chars && _hasUpper && _hasLower && _hasNumber && _hasSpecial;

  bool get _passwordsMatch =>
      _confirm.isNotEmpty && _confirm == _password;

  bool get _formValid => _passwordValid && _passwordsMatch;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() => setState(() => _password = _passwordCtrl.text));
    _confirmCtrl.addListener(()  => setState(() => _confirm  = _confirmCtrl.text));
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formValid || _loading) return;
    setState(() => _loading = true);
    await authVerificationService.resetPassword(widget.email, _password);
    if (!mounted) return;
    setState(() { _loading = false; _success = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        body: VerificationSuccessOverlay(
          title:    'Password Updated!',
          subtitle: 'Your password has been successfully reset.\nYou can now sign in.',
          doneLabel: 'Back to Login',
          onDone:    () => context.go(AppRouter.login),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // ── Back button ──────────────────────────────────────────────
              GestureDetector(
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
              ).animate().fade(duration: 400.ms),

              SizedBox(height: 40.h),

              // ── Icon ─────────────────────────────────────────────────────
              Container(
                width:  96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                    colors: [Color(0xFF0D9488), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color:      const Color(0xFF0D9488).withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset:     const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(Icons.lock_open_rounded, color: Colors.white, size: 46.sp),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),

              SizedBox(height: 28.h),

              Text(
                'Create New Password',
                style: TextStyle(
                  fontSize:   26.sp,
                  fontWeight: FontWeight.w900,
                  color:      const Color(0xFF0F2554),
                ),
              ).animate(delay: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0),

              SizedBox(height: 8.h),

              Text(
                'Your new password must be different\nfrom previously used passwords.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color:    AppColors.textSecondary,
                  height:   1.55,
                ),
              ).animate(delay: 160.ms).fade(duration: 400.ms),

              SizedBox(height: 32.h),

              // ── New password ─────────────────────────────────────────────
              AuthTextField(
                controller: _passwordCtrl,
                hint:       'New password',
                icon:       Icons.lock_outline_rounded,
                isPassword: true,
                validator:  (_) => _passwordValid ? null : 'Password too weak',
              ).animate(delay: 220.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

              if (_password.isNotEmpty) ...[
                PasswordStrengthIndicator(password: _password)
                    .animate()
                    .fade(duration: 250.ms),
                SizedBox(height: 10.h),
                ValidationText(label: '8 Characters minimum', isPassed: _has8Chars),
                ValidationText(label: 'One uppercase letter',  isPassed: _hasUpper),
                ValidationText(label: 'One lowercase letter',  isPassed: _hasLower),
                ValidationText(label: 'One number',            isPassed: _hasNumber),
                ValidationText(label: 'One special character', isPassed: _hasSpecial),
              ],

              SizedBox(height: 16.h),

              // ── Confirm password ──────────────────────────────────────────
              AuthTextField(
                controller:      _confirmCtrl,
                hint:            'Confirm new password',
                icon:            Icons.lock_outline_rounded,
                isPassword:      true,
                textInputAction: TextInputAction.done,
                onSubmitted:     (_) => _resetPassword(),
                validator: (_) =>
                    _confirm.isNotEmpty && !_passwordsMatch
                        ? 'Passwords do not match'
                        : null,
              ).animate(delay: 260.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

              if (_confirm.isNotEmpty) ...[
                SizedBox(height: 6.h),
                ValidationText(
                  label:    _passwordsMatch
                      ? 'Passwords match'
                      : 'Passwords do not match',
                  isPassed: _passwordsMatch,
                ).animate().fade(duration: 200.ms),
              ],

              SizedBox(height: 32.h),

              // ── Reset button ──────────────────────────────────────────────
              AnimatedOpacity(
                opacity:  _formValid ? 1.0 : 0.5,
                duration: 200.ms,
                child: AuthCTAButton(
                  label:     'Update Password',
                  isLoading: _loading,
                  onTap:     _formValid ? _resetPassword : null,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF059669)],
                    begin:  Alignment.centerLeft,
                    end:    Alignment.centerRight,
                  ),
                ),
              )
                  .animate(delay: 300.ms)
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.08, end: 0),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
