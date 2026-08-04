import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Single featured advisory card matching the reference design.
/// Full-width warm-tinted card with icon, title, description, chevron.
class AnnouncementBanner extends StatelessWidget {
  const AnnouncementBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _AdvisoryCard(
            icon:       Icons.thunderstorm_rounded,
            title:      'Rainy Season Advisory',
            message:    'Expect heavy rainfall June–August. '
                        'Bring rain gear and check routes before traveling.',
            bgColor:    const Color(0xFFFFF8E7),
            borderColor: const Color(0xFFFDE68A),
            iconColor:  const Color(0xFFF59E0B),
          ),
          SizedBox(height: 10.h),
          _AdvisoryCard(
            icon:       Icons.warning_amber_rounded,
            title:      'Landslide Alert — Caibiran Road',
            message:    'Landslide-prone zones near Caibiran–Biliran road. Avoid during heavy rain.',
            bgColor:    const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
            iconColor:  const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
  });

  final IconData icon;
  final String   title;
  final String   message;
  final Color    bgColor;
  final Color    borderColor;
  final Color    iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border:       Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize:   13.sp,
                    fontWeight: FontWeight.w700,
                    color:      const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:    const Color(0xFF64748B),
                    height:   1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF94A3B8), size: 14.sp),
        ],
      ),
    );
  }
}
