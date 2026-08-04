import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

// ── All categories data ───────────────────────────────────────────────────────

class _CategoryItem {
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.count,
    required this.color,
    required this.description,
  });
  final String   label;
  final IconData icon;
  final int      count;
  final Color    color;
  final String   description;
}

const _allCategories = [
  _CategoryItem(
    label: 'Beach', icon: Icons.beach_access_rounded, count: 8,
    color: Color(0xFF3B82F6),
    description: 'White sand, crystal clear waters, and stunning sunsets.',
  ),
  _CategoryItem(
    label: 'Mountain', icon: Icons.landscape_rounded, count: 5,
    color: Color(0xFF10B981),
    description: 'Verdant highlands, trekking trails, and cool mountain air.',
  ),
  _CategoryItem(
    label: 'Waterfall', icon: Icons.water_rounded, count: 7,
    color: Color(0xFF6366F1),
    description: 'Hidden cascades and refreshing natural pools.',
  ),
  _CategoryItem(
    label: 'Culture', icon: Icons.museum_rounded, count: 4,
    color: Color(0xFFF59E0B),
    description: 'Local heritage sites, festivals, and community traditions.',
  ),
  _CategoryItem(
    label: 'Food', icon: Icons.restaurant_rounded, count: 12,
    color: Color(0xFFFB923C),
    description: 'Fresh seafood, native delicacies, and Biliran cuisine.',
  ),
  _CategoryItem(
    label: 'Island', icon: Icons.holiday_village_rounded, count: 6,
    color: Color(0xFF14B8A6),
    description: 'Remote island escapes with pristine shores and reefs.',
  ),
  _CategoryItem(
    label: 'Hot Spring', icon: Icons.hot_tub_rounded, count: 3,
    color: Color(0xFFEF4444),
    description: 'Natural geothermal springs with therapeutic waters.',
  ),
  _CategoryItem(
    label: 'Adventure', icon: Icons.hiking_rounded, count: 9,
    color: Color(0xFF8B5CF6),
    description: 'Kayaking, cliff diving, spelunking, and more.',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

/// Full-screen grid of all Biliran destination categories.
class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation:       0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              size: 18.sp, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Browse Categories',
          style: TextStyle(
            fontSize:   17.sp,
            fontWeight: FontWeight.w800,
            color:      AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
        child: GridView.builder(
          physics:     const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:   2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing:  12.h,
            childAspectRatio: 1.1,
          ),
          itemCount:   _allCategories.length,
          itemBuilder: (context, i) =>
              _CategoryGridCard(item: _allCategories[i]),
        ),
      ),
    );
  }
}

// ── Grid card ─────────────────────────────────────────────────────────────────

class _CategoryGridCard extends StatelessWidget {
  const _CategoryGridCard({required this.item});
  final _CategoryItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding:    EdgeInsets.all(16.r),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width:  44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color:        item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(item.icon, color: item.color, size: 22.sp),
            ),
            const Spacer(),
            Text(
              item.label,
              style: TextStyle(
                fontSize:   14.sp,
                fontWeight: FontWeight.w800,
                color:      AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              '${item.count} spots',
              style: TextStyle(
                fontSize: 11.sp,
                color:    AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                color:    AppColors.textSecondary,
                height:   1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
