import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// Professional, stateless footer for BiliRoute.
class CinematicFooter extends StatelessWidget {
  const CinematicFooter({
    super.key,
    this.onExploreMap,
    this.onPlanTrip,
  });

  final VoidCallback? onExploreMap;
  final VoidCallback? onPlanTrip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? DarkColors.card : Colors.white;
    final borderColor = isDark ? DarkColors.border : AppColors.divider;
    final textColor = isDark ? DarkColors.text : AppColors.textPrimary;
    final subtextColor = isDark ? DarkColors.subtext : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 1. Brand header ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BiliRoute',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Smart Tourism & Mobility Platform',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // ── 2. Tagline ────────────────────────────────────────────────
            Text(
              'Connecting tourists and locals with verified transportation routes, fare guides, and safety advisories across Biliran Province.',
              style: TextStyle(
                fontSize: 11.5.sp,
                color: subtextColor,
                height: 1.5,
              ),
            ),

            SizedBox(height: 24.h),

            // ── 3. Platform highlights chips ──────────────────────────────
            Wrap(
              spacing: 10.w,
              runSpacing: 8.h,
              children: const [
                _StatBadge(icon: Icons.place_rounded, label: '120+ Destinations'),
                _StatBadge(icon: Icons.directions_bus_rounded, label: '48 Verified Transport'),
                _StatBadge(icon: Icons.alt_route_rounded, label: '350+ Routes'),
                _StatBadge(icon: Icons.security_rounded, label: '24/7 Monitoring'),
              ],
            ),

            SizedBox(height: 24.h),

            Divider(color: borderColor, height: 1),

            SizedBox(height: 20.h),

            // ── 4. Quick Links ───────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPLORE',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.oceanCyan : AppColors.primary,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _FooterLink(
                        label: 'Interactive Map',
                        onTap: onExploreMap,
                        icon: Icons.map_outlined,
                      ),
                      _FooterLink(
                        label: 'Route Planner',
                        onTap: onPlanTrip,
                        icon: Icons.route_outlined,
                      ),
                      _FooterLink(
                        label: 'Fare Directory',
                        onTap: null,
                        icon: Icons.payments_outlined,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SUPPORT & GOV',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.oceanCyan : AppColors.primary,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      const _FooterLink(
                        label: 'Tourism Office',
                        onTap: null,
                        icon: Icons.account_balance_outlined,
                      ),
                      const _FooterLink(
                        label: 'Safety Advisories',
                        onTap: null,
                        icon: Icons.shield_outlined,
                      ),
                      const _FooterLink(
                        label: 'Terms & Privacy',
                        onTap: null,
                        icon: Icons.privacy_tip_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            Divider(color: borderColor, height: 1),

            SizedBox(height: 16.h),

            // ── 5. Copyright & Status ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '© 2026 BiliRoute. Official Biliran Tourism System.',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: subtextColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.background : AppColors.backgroundStart,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? DarkColors.border : AppColors.divider,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.sp,
            color: isDark ? AppColors.oceanCyan : AppColors.primary,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkColors.text : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? DarkColors.subtext : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

