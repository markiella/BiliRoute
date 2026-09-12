import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../helpers/email_suggestion_helper.dart';
import '../repositories/auth_repository.dart';
import '../services/mock_verification_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/email_suggestion_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ForgotPasswordScreen — Step 1: Enter Email
// ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  String _email    = '';
  bool   _loading  = false;

  bool get _emailValid =>
      RegExp(r'^[\w.+\-]+@[a-zA-Z\d\-]+\.[a-zA-Z]+$').hasMatch(_email.trim());

  String? get _emailError {
    if (_email.isEmpty) return null;
    return _emailValid ? null : 'Enter a valid email address';
  }

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() => setState(() => _email = _emailCtrl.text));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_emailValid || _loading) return;
    setState(() => _loading = true);
    final repo = context.read<AuthRepository>();
    if (repo.useMockAuth) {
      await authVerificationService.sendPasswordResetOtp(_email.trim());
    } else {
      await repo.forgotPassword(email: _email.trim());
    }
    if (!mounted) return;
    context.push(AppRouter.forgotPasswordOtp, extra: _email.trim());
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // ── Back button ───────────────────────────────────────────────
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

              // ── Icon ───────────────────────────────────────────────────────
              Container(
                width:  96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                    colors: [Color(0xFF0F2554), Color(0xFF1458D4)],
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
                child: Icon(Icons.lock_reset_rounded,
                    color: Colors.white, size: 48.sp),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),

              SizedBox(height: 28.h),

              // ── Title ───────────────────────────────────────────────────────
              Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize:   26.sp,
                  fontWeight: FontWeight.w900,
                  color:      const Color(0xFF0F2554),
                ),
              ).animate(delay: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0),

              SizedBox(height: 8.h),

              Text(
                "No worries! Enter your registered email and\nwe'll send you a reset code.",
                style: TextStyle(
                  fontSize: 13.sp,
                  color:    AppColors.textSecondary,
                  height:   1.55,
                ),
              ).animate(delay: 160.ms).fade(duration: 400.ms),

              SizedBox(height: 36.h),

              // ── Email field ─────────────────────────────────────────────────
              AuthTextField(
                controller:   _emailCtrl,
                hint:         'Email address',
                icon:         Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                errorText:    _emailError,
                textInputAction: TextInputAction.done,
                onSubmitted:  (_) => _continue(),
                validator:    (_) => _emailError,
              ).animate(delay: 220.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

              if (EmailSuggestionHelper.getSuggestion(_email) != null) ...[
                EmailSuggestionCard(
                  suggestedEmail: EmailSuggestionHelper.getSuggestion(_email)!,
                  onTap: () {
                    _emailCtrl.text = EmailSuggestionHelper.getSuggestion(_email)!;
                    setState(() => _email = _emailCtrl.text);
                  },
                ),
              ],

              SizedBox(height: 28.h),

              // ── Continue button ─────────────────────────────────────────────
              AnimatedOpacity(
                opacity:  _emailValid ? 1.0 : 0.5,
                duration: 200.ms,
                child: AuthCTAButton(
                  label:     'Send Reset Code',
                  isLoading: _loading,
                  onTap:     _emailValid ? _continue : null,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2554), Color(0xFF1D4ED8), Color(0xFF0891B2)],
                    begin:  Alignment.centerLeft,
                    end:    Alignment.centerRight,
                  ),
                ),
              ).animate(delay: 280.ms).fade(duration: 400.ms).slideY(begin: 0.08, end: 0),

              SizedBox(height: 20.h),

              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Remember your password?  ',
                      style: TextStyle(
                        color:    AppColors.textSecondary,
                        fontSize: 12.5.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign in',
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
              ).animate(delay: 310.ms).fade(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
