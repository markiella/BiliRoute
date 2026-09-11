import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class ServiceItem {
  const ServiceItem({
    required this.name,
    required this.type,
    required this.location,
    required this.contact,
    required this.rating,
    required this.icon,
    required this.color,
  });
  final String   name;
  final String   type;
  final String   location;
  final String   contact;
  final double   rating;
  final IconData icon;
  final Color    color;
}

// ── Mock data (replace with real Biliran data) ────────────────────────────────

const _services = [
  ServiceItem(
    name:     'Higatangan Island Homestay',
    type:     'Accommodation',
    location: 'Higatangan, Naval',
    contact:  '+63 917 000 0001',
    rating:   4.8,
    icon:     Icons.house_rounded,
    color:    Color(0xFF10B981),
  ),
  ServiceItem(
    name:     'Sambawan Island Tours',
    type:     'Boat Rental',
    location: 'Maripipi, Biliran',
    contact:  '+63 917 000 0002',
    rating:   4.9,
    icon:     Icons.sailing_rounded,
    color:    Color(0xFF3B82F6),
  ),
  ServiceItem(
    name:     'Naval Bay Motorcycle Rental',
    type:     'Transport',
    location: 'Naval, Biliran',
    contact:  '+63 917 000 0003',
    rating:   4.5,
    icon:     Icons.two_wheeler_rounded,
    color:    Color(0xFFF59E0B),
  ),
  ServiceItem(
    name:     'Biliran Mountain Guide',
    type:     'Tour Guide',
    location: 'Caibiran, Biliran',
    contact:  '+63 917 000 0004',
    rating:   4.7,
    icon:     Icons.hiking_rounded,
    color:    Color(0xFF8B5CF6),
  ),
  ServiceItem(
    name:     'Agta Beach Cottages',
    type:     'Accommodation',
    location: 'Almeria, Biliran',
    contact:  '+63 917 000 0005',
    rating:   4.6,
    icon:     Icons.beach_access_rounded,
    color:    Color(0xFFFB923C),
  ),
];

// ── Section widget ────────────────────────────────────────────────────────────

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:         EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 4.h),
        itemCount:       _services.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (context, i) => ServiceCard(item: _services[i]),
      ),
    );
  }
}

// ── Single card ───────────────────────────────────────────────────────────────

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.item});
  final ServiceItem item;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Resolve the localized type label
    final typeLabel = _localizedType(item.type, l10n);
    return Container(
      width:  180.w,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color:        isDark ? DarkColors.card : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(color: DarkColors.border)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + type badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width:  40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color:        item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(item.icon, color: item.color, size: 20.sp),
              ),
              // Rating pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color:        AppColors.warning.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 11.sp),
                    SizedBox(width: 2.w),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize:   10.sp,
                        fontWeight: FontWeight.w700,
                        color:      AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Service name
          Text(
            item.name,
            maxLines:  2,
            overflow:  TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:   12.sp,
              fontWeight: FontWeight.w700,
              color:      AppColors.textPrimary,
              height:     1.3,
            ),
          ),

          SizedBox(height: 4.h),

          // Type badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
            decoration: BoxDecoration(
              color:        item.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              typeLabel,
              style: TextStyle(
                fontSize:   9.5.sp,
                fontWeight: FontWeight.w600,
                color:      item.color,
              ),
            ),
          ),

          const Spacer(),

          // Location row
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  color: AppColors.textSecondary, size: 11.sp),
              SizedBox(width: 3.w),
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
            ],
          ),

          SizedBox(height: 3.h),

          // Contact row
          Row(
            children: [
              Icon(Icons.phone_rounded,
                  color: AppColors.primary, size: 11.sp),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  item.contact,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:   10.sp,
                    color:      AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Resolve the localized service type label
String _localizedType(String type, AppLocalizations l10n) {
  switch (type) {
    case 'Accommodation': return l10n.serviceAccommodation;
    case 'Boat Rental':   return l10n.serviceBoatRental;
    case 'Transport':     return l10n.serviceTransport;
    case 'Tour Guide':    return l10n.serviceTourGuide;
    default:              return type;
  }
}
