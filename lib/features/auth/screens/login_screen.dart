import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/auth_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Login Screen — matches the design mockup
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading       = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) context.go(AppRouter.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final imgH    = screenH * 0.42;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ── Scrollable content ────────────────────────────────────────────
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Image header with wave clip ─────────────────────────
                  AuthImageHeader(
                    imagePath: 'assets/images/login.jpeg',
                    height:    imgH,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 14.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Wordmark
                            const AuthWordmark()
                                .animate()
                                .fade(duration: 600.ms)
                                .slideY(begin: -0.1, end: 0),

                            const Spacer(),

                            // Headline
                            Text(
                              'Welcome Back,',
                              style: TextStyle(
                                color:      Colors.white,
                                fontSize:   26.sp,
                                fontWeight: FontWeight.w900,
                                height:     1.1,
                              ),
                            )
                                .animate(delay: 100.ms)
                                .fade(duration: 500.ms)
                                .slideY(begin: 0.15, end: 0),

                            Text(
                              'Explorer!',
                              style: TextStyle(
                                color:         const Color(0xFF67E8F9),
                                fontSize:      26.sp,
                                fontWeight:    FontWeight.w900,
                                fontStyle:     FontStyle.italic,
                                height:        1.15,
                              ),
                            )
                                .animate(delay: 140.ms)
                                .fade(duration: 500.ms)
                                .slideY(begin: 0.15, end: 0),

                            SizedBox(height: 8.h),

                            // Subtitle
                            RichText(
                              text: TextSpan(
                                text:  'Continue your smart journey and\nexplore the beauty of ',
                                style: TextStyle(
                                  color:    Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11.5.sp,
                                  height:   1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text:  'Biliran Island.',
                                    style: TextStyle(
                                      color:      const Color(0xFF67E8F9),
                                      fontWeight: FontWeight.w700,
                                      fontSize:   11.5.sp,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate(delay: 180.ms)
                                .fade(duration: 500.ms),

                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── White form area ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Email
                        AuthTextField(
                          controller:   _emailCtrl,
                          hint:         'Email address',
                          icon:         Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v == null || !v.contains('@')
                                  ? 'Enter a valid email'
                                  : null,
                        )
                            .animate(delay: 200.ms)
                            .fade(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),

                        SizedBox(height: 12.h),

                        // Password
                        AuthTextField(
                          controller:      _passwordCtrl,
                          hint:            'Password',
                          icon:            Icons.lock_outline_rounded,
                          isPassword:      true,
                          textInputAction: TextInputAction.done,
                          onSubmitted:     (_) => _signIn(),
                          validator: (v) =>
                              v == null || v.length < 6
                                  ? 'Minimum 6 characters'
                                  : null,
                        )
                            .animate(delay: 240.ms)
                            .fade(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),

                        SizedBox(height: 4.h),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color:      const Color(0xFF0D9488),
                                fontSize:   11.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ).animate(delay: 260.ms).fade(duration: 400.ms),

                        SizedBox(height: 12.h),

                        // Start Exploring CTA
                        AuthCTAButton(
                          label:     'Start Exploring',
                          isLoading: _loading,
                          onTap:     _signIn,
                        )
                            .animate(delay: 280.ms)
                            .fade(duration: 400.ms)
                            .slideY(begin: 0.08, end: 0),

                        SizedBox(height: 16.h),

                        // OR divider
                        Row(
                          children: [
                            Expanded(child: Divider(
                                color: Colors.grey.shade300, thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                  color:    AppColors.textSecondary,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(
                                color: Colors.grey.shade300, thickness: 1)),
                          ],
                        ).animate(delay: 310.ms).fade(duration: 400.ms),

                        SizedBox(height: 12.h),

                        // Google
                        AuthOutlineButton(
                          label:         'Continue with Google',
                          leadingWidget: const GoogleLogoWidget(),
                          onTap:         () {},
                        ).animate(delay: 330.ms).fade(duration: 400.ms),

                        SizedBox(height: 10.h),

                        // Guest
                        AuthOutlineButton(
                          label: 'Continue as Guest',
                          icon:  Icons.person_outline_rounded,
                          onTap: () => context.go(AppRouter.home),
                        ).animate(delay: 350.ms).fade(duration: 400.ms),

                        SizedBox(height: 12.h),

                        // Footer attribution
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              'Destination information and route data are continuously validated\n'
                              'through BiliRoute field surveys and local tourism stakeholders.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:    AppColors.textSecondary.withValues(alpha: 0.65),
                                fontSize: 9.sp,
                                height:   1.55,
                              ),
                            ),
                          ),
                        ).animate(delay: 380.ms).fade(duration: 400.ms),

                        // Register link
                        Center(
                          child: GestureDetector(
                            onTap: () => context.push(AppRouter.register),
                            child: RichText(
                              text: TextSpan(
                                text:  "Don't have an account?  ",
                                style: TextStyle(
                                  color:    AppColors.textSecondary,
                                  fontSize: 12.5.sp,
                                ),
                                children: [
                                  TextSpan(
                                    text:  'Create one →',
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
                        ).animate(delay: 400.ms).fade(duration: 400.ms),

                        SizedBox(height: 28.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

