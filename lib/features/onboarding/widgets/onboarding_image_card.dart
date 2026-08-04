import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// Reusable destination image card used across all onboarding screens.
///
/// Layout:
///   • Rounded container with drop-shadow
///   • Full-bleed image with a bottom gradient overlay
///   • Optional [badge] label (e.g. destination name)
///   • [errorBuilder] fallback — shows a gradient placeholder so the
///     screen never looks broken if the image file is missing
///
/// Usage:
/// ```dart
/// OnboardingImageCard(
///   imagePath: AppAssets.onboarding1,
///   badge: 'Sambawan Island',
///   slideDelay: 300.ms,
/// )
/// ```
///
/// To swap the image later, just change [imagePath] in [AppAssets].
class OnboardingImageCard extends StatelessWidget {
  const OnboardingImageCard({
    super.key,
    required this.imagePath,
    this.badge,
    this.height,
    this.slideDelay = Duration.zero,
    this.overlayGradient,
  });

  /// Asset path to the destination photo.
  /// Tip: update [AppAssets] constants to swap images globally.
  final String imagePath;

  /// Optional text label shown as a pill at the bottom-left of the card.
  final String? badge;

  /// Card height. Defaults to 200.h.
  final double? height;

  /// Delay before the slide-up animation starts.
  final Duration slideDelay;

  /// Gradient overlay on top of the image.
  /// Defaults to a dark bottom scrim.
  final Gradient? overlayGradient;

  @override
  Widget build(BuildContext context) {
    final h = height ?? 200.h;

    return Container(
      height:      h,
      width:       double.infinity,
      decoration:  BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.20),
            blurRadius: 24,
            offset:     const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color:      AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 40,
            offset:     const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Destination photo ──────────────────────────────────────────
            Image.asset(
              imagePath,
              fit:          BoxFit.cover,
              errorBuilder: (context, _, e2) => _PlaceholderFill(height: h),
            ),

            // ── Bottom gradient scrim ──────────────────────────────────────
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: overlayGradient ??
                    LinearGradient(
                      begin:  Alignment.topCenter,
                      end:    Alignment.bottomCenter,
                      stops:  const [0.45, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
              ),
            ),

            // ── Destination badge ──────────────────────────────────────────
            if (badge != null)
              Positioned(
                bottom: 14.h,
                left:   14.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color:        Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.place_rounded,
                        color: Colors.white,
                        size:  13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        badge!,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color:      Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: slideDelay)
        .fade(duration: 600.ms)
        .slideY(
          begin:    0.15,
          end:      0,
          duration: 600.ms,
          curve:    Curves.easeOutCubic,
        );
  }
}

// ── Fallback when image file is missing ──────────────────────────────────────

/// Shown instead of a broken image when the asset file doesn't exist yet.
class _PlaceholderFill extends StatelessWidget {
  const _PlaceholderFill({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_search_rounded,
              color: Colors.white.withValues(alpha: 0.50),
              size:  48,
            ),
            SizedBox(height: 8.h),
            Text(
              'Image coming soon',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
