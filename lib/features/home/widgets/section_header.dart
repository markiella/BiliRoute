import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// Reusable section header used throughout the HomePage.
///
/// ```dart
/// SectionHeader(
///   title: 'Popular Destinations',
///   onSeeAll: () => context.push('/destinations'),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  final String        title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color:      AppColors.textPrimary,
                fontSize:   17.sp,
              ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color:        AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color:      AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize:   11.5.sp,
                        ),
                  ),
                  SizedBox(width: 3.w),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 10.sp, color: AppColors.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
