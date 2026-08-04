import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// A gradient action card displayed in the Quick Actions 2×2 grid on HomePage.
///
/// Parameters:
/// - [icon]      : Leading icon representing the action.
/// - [title]     : Short action label (1–2 words).
/// - [subtitle]  : Supporting description shown below the title.
/// - [gradient]  : Background gradient that distinguishes each card.
/// - [onTap]     : Navigation callback fired on tap.
/// - [animIndex] : Stagger index used to offset the entry animation.
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.animIndex = 0,
  });

  final IconData   icon;
  final String     title;
  final String     subtitle;
  final Gradient   gradient;
  final VoidCallback onTap;
  final int        animIndex;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        splashColor:    Colors.white.withValues(alpha: 0.15),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                // Shadow tinted toward the card's dominant color
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon bubble ───────────────────────────────────────────
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: AppColors.white, size: 22.sp),
              ),

              const Spacer(),

              // ── Title ─────────────────────────────────────────────────
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                maxLines: 2,
              ),

              SizedBox(height: 2.h),

              // ── Subtitle ──────────────────────────────────────────────
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 10.5.sp,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    // Staggered fade-slide entry animation per card position
    return card
        .animate(delay: (300 + animIndex * 80).ms)
        .fade(duration: 450.ms)
        .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
  }
}
