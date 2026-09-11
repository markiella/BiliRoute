import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// Vertical icon-above-label chip used in the Categories section.
/// Matches the reference design: circular icon container + label below.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  final String     label;
  final IconData   icon;
  final Color      iconColor;
  final bool       isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve:    Curves.easeOutCubic,
        width:    68.w,
        padding:  EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? iconColor.withValues(alpha: 0.18)
              : (isDark ? DarkColors.elevated : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? iconColor : (isDark ? DarkColors.border : AppColors.divider),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular icon badge
            Container(
              width:  36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),

            SizedBox(height: 5.h),

            // Label
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:   10.sp,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? iconColor
                    : (isDark ? DarkColors.text : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
