import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EmailSuggestionCard — Glassmorphic domain typo suggestion card
//
// Appears below email inputs when a typo in common domains is detected
// (e.g. gmail.con -> Did you mean mark@gmail.com?).
// ─────────────────────────────────────────────────────────────────────────────

class EmailSuggestionCard extends StatelessWidget {
  const EmailSuggestionCard({
    super.key,
    required this.suggestedEmail,
    required this.onTap,
  });

  final String       suggestedEmail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.28),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  color: const Color(0xFF0D9488),
                  size:  16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Did you mean ',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color:    AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: suggestedEmail,
                          style: TextStyle(
                            fontSize:   12.sp,
                            fontWeight: FontWeight.w700,
                            color:      const Color(0xFF0D9488),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: '?',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:    AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: const Color(0xFF0D9488),
                  size:  14.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fade(duration: 250.ms)
        .slideY(begin: -0.15, end: 0, curve: Curves.easeOut);
  }
}
