import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/saved/saved_destinations_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/destination_model.dart';
import '../../widgets/heart_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SavedDestinationsScreen — list of all bookmarked destinations
// ─────────────────────────────────────────────────────────────────────────────

class SavedDestinationsScreen extends StatelessWidget {
  const SavedDestinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final saved = context.watch<SavedDestinationsNotifier>();

    final savedDests = allBiliranDestinations
        .where((d) => saved.isSaved(d.id))
        .toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned:          true,
            expandedHeight:  100.h,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18.sp, color: cs.onSurface),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Destinations',
                    style: TextStyle(
                      fontSize:   18.sp,
                      fontWeight: FontWeight.w800,
                      color:      cs.onSurface,
                    ),
                  ),
                  Text(
                    '${savedDests.length} place${savedDests.length == 1 ? '' : 's'} saved',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:    AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Empty state ───────────────────────────────────────────────────
          if (savedDests.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(),
            )
          else ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              sliver: SliverList.separated(
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemCount:        savedDests.length,
                itemBuilder:      (context, i) => _SavedDestinationTile(
                  item:  savedDests[i],
                  onTap: () => context.push(
                    AppRouter.destinationDetails,
                    extra: savedDests[i],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual saved destination tile
// ─────────────────────────────────────────────────────────────────────────────

class _SavedDestinationTile extends StatelessWidget {
  const _SavedDestinationTile({
    required this.item,
    required this.onTap,
  });

  final DestinationItem item;
  final VoidCallback    onTap;

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color:        isDark ? DarkColors.card : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 12,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Hero(
              tag: '${item.heroTag}_saved_list',
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft:    Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                ),
                child: Image.asset(
                  item.imageAsset,
                  width:       110.w,
                  height:      double.infinity,
                  fit:         BoxFit.cover,
                  errorBuilder: (_, e, s) => Container(
                    width:  110.w,
                    color:  AppColors.royalBlue.withValues(alpha: 0.15),
                    child:  Icon(Icons.landscape_rounded,
                        color: AppColors.royalBlue, size: 32.sp),
                  ),
                ),
              ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                  children: [
                    // Category chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color:        item.categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize:   10.sp,
                          fontWeight: FontWeight.w700,
                          color:      item.categoryColor,
                        ),
                      ),
                    ),

                    // Name
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:    TextStyle(
                        fontSize:   14.sp,
                        fontWeight: FontWeight.w800,
                        color:      cs.onSurface,
                      ),
                    ),

                    // Location + rating row
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 12.sp, color: AppColors.textSecondary),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            item.municipality,
                            overflow: TextOverflow.ellipsis,
                            style:    TextStyle(
                              fontSize: 11.sp,
                              color:    AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(Icons.star_rounded,
                            size: 12.sp, color: AppColors.warning),
                        SizedBox(width: 2.w),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize:   11.sp,
                            fontWeight: FontWeight.w700,
                            color:      cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Heart button (remove)
            Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: HeartButton(destinationId: item.id, size: 22.sp),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state illustration
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  96.r,
              height: 96.r,
              decoration: BoxDecoration(
                color:        AppColors.royalBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: AppColors.royalBlue.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size:  44.sp,
                color: AppColors.royalBlue.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No saved destinations yet',
              style: TextStyle(
                fontSize:   17.sp,
                fontWeight: FontWeight.w800,
                color:      cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              'Start exploring Biliran and save places\nyou\'d like to visit.',
              style: TextStyle(
                fontSize: 13.sp,
                color:    AppColors.textSecondary,
                height:   1.55,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.royalBlue, AppColors.teal],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '✦  Explore Destinations',
                  style: TextStyle(
                    fontSize:   13.sp,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
