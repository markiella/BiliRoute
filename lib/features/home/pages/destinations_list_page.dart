import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/destination_model.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

/// Full list of all Biliran tourist destinations.
class DestinationsListPage extends StatelessWidget {
  const DestinationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      appBar: AppBar(
        backgroundColor:  Colors.white,
        elevation:        0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              size: 18.sp, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'All Destinations',
          style: TextStyle(
            fontSize:   17.sp,
            fontWeight: FontWeight.w800,
            color:      AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: ListView.separated(
        physics:  const BouncingScrollPhysics(),
        padding:  EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
        itemCount: allBiliranDestinations.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, i) =>
            _DestinationListTile(item: allBiliranDestinations[i]),
      ),
    );
  }
}

// ── List tile card ────────────────────────────────────────────────────────────

class _DestinationListTile extends StatelessWidget {
  const _DestinationListTile({required this.item});
  final DestinationItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.destinationDetails, extra: item),
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Hero-tagged image
            Hero(
              tag: item.heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft:    Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                ),
                child: Image.asset(
                  item.imageAsset,
                  width:  100.w,
                  height: 110.h,
                  fit:    BoxFit.cover,
                  errorBuilder: (_, e, s) => Container(
                    width:  100.w,
                    height: 110.h,
                    color:  AppColors.divider,
                    child:  Icon(Icons.image_rounded,
                        color: AppColors.textSecondary, size: 28.sp),
                  ),
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color:        item.categoryColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize:   9.5.sp,
                          fontWeight: FontWeight.w600,
                          color:      item.categoryColor,
                        ),
                      ),
                    ),

                    SizedBox(height: 5.h),

                    // Title
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize:   13.5.sp,
                        fontWeight: FontWeight.w800,
                        color:      AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Description
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color:    AppColors.textSecondary,
                        height:   1.4,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Location + Rating row
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: AppColors.textSecondary, size: 11.sp),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color:    AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(Icons.star_rounded,
                            color: AppColors.warning, size: 12.sp),
                        SizedBox(width: 2.w),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize:   10.5.sp,
                            fontWeight: FontWeight.w700,
                            color:      AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 13.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
