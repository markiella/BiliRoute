import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AccountVerificationStatus — Reusable profile verification status widget
// Reflects real-time AuthRepository user session state
// ─────────────────────────────────────────────────────────────────────────────

class AccountVerificationStatus extends StatelessWidget {
  const AccountVerificationStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthRepository>().currentSession;
    final userEmail = session.email ?? 'explorer@biliroute.ph';
    final isVerified = session.isEmailVerified;
    final isPending = session.isLoggedIn && !session.isEmailVerified;

    final badgeColor = isVerified
        ? const Color(0xFF10B981) // Emerald Green
        : isPending
            ? const Color(0xFFF59E0B) // Amber
            : const Color(0xFF6B7280); // Slate

    final badgeText = isVerified
        ? '🟢 Email Verified'
        : isPending
            ? '🟡 Verification Pending'
            : '⚪ Email Unverified';

    final descriptionText = isVerified
        ? 'Your email address has been successfully verified.'
        : isPending
            ? 'Please verify your email address to secure your account.'
            : 'Verify your email to unlock all BiliRoute feature access.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color:      badgeColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color:        badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.30),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize:   11.5.sp,
                    fontWeight: FontWeight.w800,
                    color:      badgeColor,
                  ),
                ),
              ),
              const Spacer(),
              if (!isVerified)
                TextButton(
                  onPressed: () {
                    context.push(
                      AppRouter.emailVerification,
                      extra: userEmail,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Verify Now →',
                    style: TextStyle(
                      fontSize:   11.5.sp,
                      fontWeight: FontWeight.w800,
                      color:      const Color(0xFF0D9488),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            descriptionText,
            style: TextStyle(
              fontSize: 11.5.sp,
              color:    AppColors.textSecondary,
              height:   1.4,
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 350.ms).slideY(begin: 0.08, end: 0);
  }
}

