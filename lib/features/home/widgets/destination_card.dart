import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/heart_button.dart';

/// Image card for the Popular Destinations horizontal list.
/// Matches reference: "Top" teal badge · location name · city · star rating.
/// Supports Hero transition via [heroTag] and optional [onTap] callback.
/// Includes a [HeartButton] in the top-right corner for saving destinations.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.imageAsset,
    required this.index,
    this.destinationId,
    this.heroTag,
    this.onTap,
  });

  final String  title;
  final String  location;      // e.g. "Maripipi"
  final double  rating;        // e.g. 4.9
  final String  imageAsset;
  final int     index;
  final String? destinationId; // used by HeartButton
  final String? heroTag;       // for Hero transition to details screen
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: heroTag != null
          ? Hero(
              tag: heroTag!,
              child: _imageWidget(),
            )
          : _imageWidget(),
    );

    final card = SizedBox(
      width: 160.w,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit:      StackFit.expand,
          children: [
            image,

            // Dark gradient overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:  Alignment.topCenter,
                    end:    Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.68),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: "Top" badge + heart button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 9.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color:        const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Top',
                          style: TextStyle(
                            color:      Colors.white,
                            fontSize:   10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Heart button — only shown if destinationId is provided
                      if (destinationId != null)
                        Container(
                          width:  32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: HeartButton(
                              destinationId: destinationId!,
                              size:          18.sp,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // Destination name
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // City + rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:    Colors.white.withValues(alpha: 0.82),
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.warning, size: 12.sp),
                          SizedBox(width: 2.w),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              color:      Colors.white,
                              fontSize:   11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return card
        .animate(delay: (360 + index * 80).ms)
        .fade(duration: 450.ms)
        .slideX(begin: 0.15, end: 0, curve: Curves.easeOutCubic)
        .then(delay: (3000 + index * 400).ms)
        .shimmer(
          duration: 1200.ms,
          color:    Colors.white.withValues(alpha: 0.18),
          angle:    0.35,
        );
  }

  Widget _imageWidget() => imageAsset.startsWith('http')
      ? Image.network(
          imageAsset,
          fit:    BoxFit.cover,
          height: double.infinity,
          width:  double.infinity,
          errorBuilder: (_, e, s) => Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Icon(Icons.landscape_rounded,
                color: Colors.white70, size: 40.sp),
          ),
        )
      : Image.asset(
          imageAsset,
          fit:    BoxFit.cover,
          height: double.infinity,
          width:  double.infinity,
          errorBuilder: (_, e, s) => Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Icon(Icons.landscape_rounded,
                color: Colors.white70, size: 40.sp),
          ),
        );
}
