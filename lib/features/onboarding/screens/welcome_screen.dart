import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/animated_cta_button.dart';

/// Onboarding welcome screen — the app's first impression.
/// Navigates to [HomePage] via go_router on CTA press.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ── Hero Lottie animation ──────────────────────────────────
                (Lottie.asset(
                  AppAssets.travelLottie,
                  height: 300,
                  fit: BoxFit.contain,
                ) as Widget)
                    .animate()
                    .fade(duration: 800.ms)
                    .scale(delay: 200.ms),

                const SizedBox(height: 40),

                // ── App name ───────────────────────────────────────────────
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.3, end: 0, duration: 600.ms).fade(),

                const SizedBox(height: 12),

                // ── Tagline ────────────────────────────────────────────────
                Text(
                  AppStrings.appTagline,
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ).animate().slideY(
                      begin: 0.5,
                      end: 0,
                      delay: 200.ms,
                      duration: 600.ms,
                    ).fade(),

                const Spacer(),

                // ── CTA — navigates to Home ────────────────────────────────
                AnimatedCtaButton(
                  label: AppStrings.ctaGetStarted,
                  onPressed: () => context.go(AppRouter.home),
                ).animate().slideY(
                      begin: 1,
                      end: 0,
                      delay: 400.ms,
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    ).fade(),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
