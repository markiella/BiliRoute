import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/auth_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Register Screen — matches the design mockup
// ─────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _loading       = false;

  final Set<String> _selectedPrefs = {'Beaches', 'Waterfalls', 'Island Hopping',
      'Adventure', 'Local Cuisine', 'Eco Tourism'};

  static const _prefs = [
    (label: 'Beaches',       emoji: '🌊'),
    (label: 'Waterfalls',    emoji: '💧'),
    (label: 'Island Hopping',emoji: '🏝'),
    (label: 'Adventure',     emoji: '⛰'),
    (label: 'Local Cuisine', emoji: '🍽'),
    (label: 'Eco Tourism',   emoji: '🌿'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go(AppRouter.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final imgH    = screenH * 0.36;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Image header ────────────────────────────────────────
                  AuthImageHeader(
                    imagePath: 'assets/images/register.jpeg',
                    height:    imgH,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 14.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Wordmark with back button
                            AuthWordmark(
                              showBack: true,
                              onBack:   () => context.pop(),
                            )
                                .animate()
                                .fade(duration: 600.ms)
                                .slideY(begin: -0.1, end: 0),

                            const Spacer(),

                            // Headline
                            Text(
                              'Create Your',
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
                              'Travel Identity',
                              style: TextStyle(
                                color:      const Color(0xFF67E8F9),
                                fontSize:   26.sp,
                                fontWeight: FontWeight.w900,
                                fontStyle:  FontStyle.italic,
                                height:     1.15,
                              ),
                            )
                                .animate(delay: 140.ms)
                                .fade(duration: 500.ms)
                                .slideY(begin: 0.15, end: 0),

                            SizedBox(height: 8.h),

                            RichText(
                              text: TextSpan(
                                text:  'Join BiliRoute and discover the best routes\nacross ',
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

                            SizedBox(height: 20.h),
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

                        // Full name
                        AuthTextField(
                          controller: _nameCtrl,
                          hint:       'Full name',
                          icon:       Icons.person_outline_rounded,
                          validator:  (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Enter your name'
                                  : null,
                        ).animate(delay: 200.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

                        SizedBox(height: 11.h),

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
                        ).animate(delay: 230.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

                        SizedBox(height: 11.h),

                        // Password
                        AuthTextField(
                          controller: _passwordCtrl,
                          hint:       'Password',
                          icon:       Icons.lock_outline_rounded,
                          isPassword: true,
                          validator:  (v) =>
                              v == null || v.length < 6
                                  ? 'Minimum 6 characters'
                                  : null,
                        ).animate(delay: 260.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

                        SizedBox(height: 11.h),

                        // Confirm password
                        AuthTextField(
                          controller:      _confirmCtrl,
                          hint:            'Confirm password',
                          icon:            Icons.lock_outline_rounded,
                          isPassword:      true,
                          textInputAction: TextInputAction.done,
                          onSubmitted:     (_) => _createAccount(),
                          validator: (v) =>
                              v != _passwordCtrl.text
                                  ? 'Passwords do not match'
                                  : null,
                        ).animate(delay: 290.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

                        SizedBox(height: 20.h),

                        // Interests label
                        Text(
                          'What are you interested in?',
                          style: TextStyle(
                            color:      AppColors.textPrimary,
                            fontSize:   13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate(delay: 310.ms).fade(duration: 380.ms),

                        SizedBox(height: 10.h),

                        // Chips
                        Wrap(
                          spacing:    8.w,
                          runSpacing: 8.h,
                          children: _prefs.asMap().entries.map((e) {
                            final p = e.value;
                            return TravelChip(
                              label:    p.label,
                              emoji:    p.emoji,
                              selected: _selectedPrefs.contains(p.label),
                              onTap: () => setState(() {
                                if (_selectedPrefs.contains(p.label)) {
                                  _selectedPrefs.remove(p.label);
                                } else {
                                  _selectedPrefs.add(p.label);
                                }
                              }),
                              delay: (e.key * 40).ms,
                            );
                          }).toList(),
                        ).animate(delay: 330.ms).fade(duration: 400.ms),

                        SizedBox(height: 22.h),

                        // Begin Exploring CTA
                        AuthCTAButton(
                          label:     'Begin Exploring',
                          isLoading: _loading,
                          onTap:     _createAccount,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F2554), Color(0xFF1D4ED8),
                                Color(0xFF0891B2)],
                            begin: Alignment.centerLeft,
                            end:   Alignment.centerRight,
                          ),
                        )
                            .animate(delay: 380.ms)
                            .fade(duration: 400.ms)
                            .slideY(begin: 0.08, end: 0),

                        SizedBox(height: 18.h),

                        // Sign in link
                        Center(
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: RichText(
                              text: TextSpan(
                                text:  'Already have an account?  ',
                                style: TextStyle(
                                  color:    AppColors.textSecondary,
                                  fontSize: 12.5.sp,
                                ),
                                children: [
                                  TextSpan(
                                    text:  'Sign in',
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
                        ).animate(delay: 410.ms).fade(duration: 400.ms),

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
                        ).animate(delay: 430.ms).fade(duration: 400.ms),

                        SizedBox(height: 32.h),
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
