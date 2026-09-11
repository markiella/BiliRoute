import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../helpers/email_suggestion_helper.dart';
import '../repositories/auth_repository.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/email_suggestion_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Register Screen — with real-time validation & password strength meter
// ─────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _loading = false;

  // ── Live validation state ──────────────────────────────────────────────────
  String _name          = '';
  String _email         = '';
  String _password      = '';
  String _confirm       = '';

  // ── Password rule checks ───────────────────────────────────────────────────
  bool get _has8Chars   => _password.length >= 8;
  bool get _hasUpper    => RegExp(r'[A-Z]').hasMatch(_password);
  bool get _hasLower    => RegExp(r'[a-z]').hasMatch(_password);
  bool get _hasNumber   => RegExp(r'[0-9]').hasMatch(_password);
  bool get _hasSpecial  => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_password);

  // ── Name sanitization & validation ──────────────────────────────────────────
  String _sanitizeName(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool get _nameValid => _name.isNotEmpty && _nameError == null;

  String? get _nameError {
    if (_name.isEmpty) return null; // Don't show error before typing

    // 1. Allowed characters check (letters, spaces, hyphens, apostrophes only)
    if (RegExp(r'[0-9]').hasMatch(_name)) {
      return 'Numbers are not allowed in full name';
    }
    if (RegExp(r'[_]').hasMatch(_name)) {
      return 'Underscores are not allowed in full name';
    }
    if (RegExp(r"[^a-zA-Z\s'-]").hasMatch(_name)) {
      return 'Only letters, spaces, hyphens, and apostrophes allowed';
    }

    // 2. Space placement rules
    if (_name.startsWith(' ')) {
      return 'No leading spaces allowed';
    }
    if (_name.endsWith(' ')) {
      return 'No trailing spaces allowed';
    }
    if (_name.contains('  ')) {
      return 'Multiple consecutive spaces are not allowed';
    }

    // 3. Length bounds (min 3, max 50)
    if (_name.length < 3) {
      return 'Minimum 3 characters required';
    }
    if (_name.length > 50) {
      return 'Maximum 50 characters allowed';
    }

    return null;
  }

  // ── Email validation ────────────────────────────────────────────────────────
  bool get _emailValid =>
      RegExp(r'^[\w.+\-]+@[a-zA-Z\d\-]+\.[a-zA-Z]+$').hasMatch(_email.trim());

  String? get _emailError {
    if (_email.isEmpty) return null;
    return _emailValid ? null : 'Enter a valid email address';
  }

  // ── Password validation ─────────────────────────────────────────────────────
  bool get _passwordValid =>
      _has8Chars && _hasUpper && _hasLower && _hasNumber && _hasSpecial;

  // ── Confirm password ────────────────────────────────────────────────────────
  bool get _passwordsMatch => _confirm.isNotEmpty && _confirm == _password;

  // ── Overall form validity ───────────────────────────────────────────────────
  bool get _formValid =>
      _nameValid && _emailValid && _passwordValid && _passwordsMatch;

  final Set<String> _selectedPrefs = {
    'Beaches', 'Waterfalls', 'Island Hopping',
    'Adventure', 'Local Cuisine', 'Eco Tourism',
  };

  static const _prefs = [
    (label: 'Beaches',        emoji: '🌊'),
    (label: 'Waterfalls',     emoji: '💧'),
    (label: 'Island Hopping', emoji: '🏝'),
    (label: 'Adventure',      emoji: '⛰'),
    (label: 'Local Cuisine',  emoji: '🍽'),
    (label: 'Eco Tourism',    emoji: '🌿'),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(()     => setState(() => _name     = _nameCtrl.text));
    _emailCtrl.addListener(()    => setState(() => _email    = _emailCtrl.text));
    _passwordCtrl.addListener(() => setState(() => _password = _passwordCtrl.text));
    _confirmCtrl.addListener(()  => setState(() => _confirm  = _confirmCtrl.text));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _createAccount() async {
    if (!_formValid) return;
    final sanitizedName = _sanitizeName(_nameCtrl.text);
    _nameCtrl.text = sanitizedName;
    _name = sanitizedName;

    setState(() => _loading = true);

    try {
      final repo = context.read<AuthRepository>();
      final res = await repo.register(
        fullName: sanitizedName,
        email: _email.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      if (res != null) {
        context.push(AppRouter.emailVerification, extra: _email.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(repo.errorMessage ?? 'Registration failed. Please try again.'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final imgH    = screenH * 0.36;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Image header ────────────────────────────────────────────────
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
                      AuthWordmark(showBack: true, onBack: () => context.pop())
                          .animate()
                          .fade(duration: 600.ms)
                          .slideY(begin: -0.1, end: 0),
                      const Spacer(),
                      Text(
                        'Create Your',
                        style: TextStyle(
                          color: Colors.white, fontSize: 26.sp,
                          fontWeight: FontWeight.w900, height: 1.1,
                        ),
                      )
                          .animate(delay: 100.ms)
                          .fade(duration: 500.ms)
                          .slideY(begin: 0.15, end: 0),
                      Text(
                        'Travel Identity',
                        style: TextStyle(
                          color: const Color(0xFF67E8F9), fontSize: 26.sp,
                          fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                          height: 1.15,
                        ),
                      )
                          .animate(delay: 140.ms)
                          .fade(duration: 500.ms)
                          .slideY(begin: 0.15, end: 0),
                      SizedBox(height: 8.h),
                      RichText(
                        text: TextSpan(
                          text: 'Join BiliRoute and discover the best routes\nacross ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5.sp, height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Biliran Island.',
                              style: TextStyle(
                                color: const Color(0xFF67E8F9),
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 180.ms).fade(duration: 500.ms),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form area ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Full Name ─────────────────────────────────────────────
                  AuthTextField(
                    controller:  _nameCtrl,
                    hint:        'Full name',
                    icon:        Icons.person_outline_rounded,
                    validator:   (_) => _nameValid ? null : (_nameError ?? 'Enter a valid full name'),
                  ).animate(delay: 200.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

                  if (_name.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    ValidationText(
                      label:    _nameValid ? 'Valid full name' : _nameError!,
                      isPassed: _nameValid,
                      color:    _nameValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ).animate().fade(duration: 200.ms),
                  ],

                  SizedBox(height: 11.h),

                  // ── Email ─────────────────────────────────────────────────
                  AuthTextField(
                    controller:   _emailCtrl,
                    hint:         'Email address',
                    icon:         Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    errorText:    _emailError,
                    validator:    (_) => _emailError,
                  ).animate(delay: 230.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

                  if (EmailSuggestionHelper.getSuggestion(_email) != null) ...[
                    EmailSuggestionCard(
                      suggestedEmail: EmailSuggestionHelper.getSuggestion(_email)!,
                      onTap: () {
                        _emailCtrl.text = EmailSuggestionHelper.getSuggestion(_email)!;
                        setState(() => _email = _emailCtrl.text);
                      },
                    ),
                  ],

                  SizedBox(height: 11.h),

                  // ── Password ──────────────────────────────────────────────
                  AuthTextField(
                    controller: _passwordCtrl,
                    hint:       'Password',
                    icon:       Icons.lock_outline_rounded,
                    isPassword: true,
                    validator:  (_) => _passwordValid ? null : 'Password too weak',
                  ).animate(delay: 260.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

                  // Strength meter
                  if (_password.isNotEmpty) ...[
                    PasswordStrengthIndicator(password: _password)
                        .animate()
                        .fade(duration: 250.ms),
                    SizedBox(height: 10.h),

                    // Rule checklist
                    ValidationText(label: '8 Characters minimum', isPassed: _has8Chars),
                    ValidationText(label: 'One uppercase letter',  isPassed: _hasUpper),
                    ValidationText(label: 'One lowercase letter',  isPassed: _hasLower),
                    ValidationText(label: 'One number',            isPassed: _hasNumber),
                    ValidationText(label: 'One special character', isPassed: _hasSpecial),
                    SizedBox(height: 4.h),
                  ],

                  SizedBox(height: 11.h),

                  // ── Confirm Password ──────────────────────────────────────
                  AuthTextField(
                    controller:      _confirmCtrl,
                    hint:            'Confirm password',
                    icon:            Icons.lock_outline_rounded,
                    isPassword:      true,
                    textInputAction: TextInputAction.done,
                    onSubmitted:     (_) => _createAccount(),
                    validator: (_) =>
                        _confirm.isNotEmpty && !_passwordsMatch
                            ? 'Passwords do not match'
                            : null,
                  ).animate(delay: 290.ms).fade(duration: 380.ms).slideY(begin: 0.1, end: 0),

                  // Confirm match indicator
                  if (_confirm.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    ValidationText(
                      label:    _passwordsMatch
                          ? 'Passwords match'
                          : 'Passwords do not match',
                      isPassed: _passwordsMatch,
                    ).animate().fade(duration: 200.ms),
                  ],

                  SizedBox(height: 20.h),

                  // ── Interests label ────────────────────────────────────────
                  Text(
                    'What are you interested in?',
                    style: TextStyle(
                      color:      AppColors.textPrimary,
                      fontSize:   13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate(delay: 310.ms).fade(duration: 380.ms),

                  SizedBox(height: 10.h),

                  // ── Interest chips ─────────────────────────────────────────
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

                  SizedBox(height: 24.h),

                  // ── Create Account CTA ─────────────────────────────────────
                  AnimatedOpacity(
                    opacity:  _formValid ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: AuthCTAButton(
                      label:     'Create Account',
                      isLoading: _loading,
                      onTap:     _formValid ? _createAccount : null,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F2554), Color(0xFF1D4ED8), Color(0xFF0891B2)],
                        begin:  Alignment.centerLeft,
                        end:    Alignment.centerRight,
                      ),
                    ),
                  )
                      .animate(delay: 380.ms)
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.08, end: 0),

                  SizedBox(height: 18.h),

                  // ── Sign in link ───────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account?  ',
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
                  ).animate(delay: 410.ms).fade(duration: 400.ms),

                  SizedBox(height: 12.h),

                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Destination information and route data are continuously validated\n'
                        'through BiliRoute field surveys and local tourism stakeholders.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:    AppColors.textSecondary.withValues(alpha: 0.65),
                          fontSize: 9.sp, height: 1.55,
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
    );
  }
}
