import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers/service_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reusable provider card widgets
// ─────────────────────────────────────────────────────────────────────────────

/// A full-detail provider card used in the Itinerary Result screen.
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.provider,
    this.index = 0,
  });

  final ServiceProvider provider;
  final int             index;

  @override
  Widget build(BuildContext context) {
    final color = provider.type.color;
    return Container(
      margin:     EdgeInsets.only(bottom: 10.h),
      padding:    EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border:       Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color:      color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Top row: icon + name + verified badge ────────────────────────────
          Row(
            children: [
              Container(
                width:  36.r, height: 36.r,
                decoration: BoxDecoration(
                  color:  color.withValues(alpha: 0.12),
                  shape:  BoxShape.circle,
                ),
                child: Icon(provider.type.icon, color: color, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: TextStyle(
                        fontSize:   13.5.sp,
                        fontWeight: FontWeight.w700,
                        color:      AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      provider.type.label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color:    AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Verified badge
              if (provider.isVerified)
                _VerifiedBadge(small: false),
            ],
          ),

          SizedBox(height: 10.h),
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 10.h),

          // ── Details row ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.phone_rounded, size: 13.sp, color: AppColors.success),
              SizedBox(width: 5.w),
              Text(
                provider.contactNumber,
                style: TextStyle(
                  fontSize:   12.sp,
                  fontWeight: FontWeight.w600,
                  color:      AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (provider.availability != null)
                Flexible(
                  child: Text(
                    provider.availability!,
                    textAlign: TextAlign.right,
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color:    AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),

          if (provider.registrationCode != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Reg. Code: ${provider.registrationCode}',
              style: TextStyle(
                fontSize:  10.sp,
                color:     AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          if (provider.note != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color:        AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 12.sp, color: AppColors.warning),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      provider.note!,
                      style: TextStyle(
                          fontSize: 10.5.sp, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 10.h),

          // ── Action buttons ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon:    Icons.phone_rounded,
                  label:   'Call',
                  color:   AppColors.success,
                  onTap:   () => _dial(provider.contactNumber),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ActionBtn(
                  icon:    Icons.message_rounded,
                  label:   'Message',
                  color:   AppColors.primary,
                  outline: true,
                  onTap:   () => _sms(provider.contactNumber),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: (80 + index * 60).ms)
        .fade(duration: 350.ms)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }
}

// ── Compact preview card used inside Route Selection cards ────────────────────

class ProviderPreviewRow extends StatelessWidget {
  const ProviderPreviewRow({
    super.key,
    required this.provider,
  });

  final ServiceProvider provider;

  @override
  Widget build(BuildContext context) {
    final color = provider.type.color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border:       Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(provider.type.icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: TextStyle(
                    fontSize:   11.5.sp,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.textPrimary,
                  ),
                ),
                Text(
                  provider.contactNumber,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color:    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _dial(provider.contactNumber),
            child: Container(
              width:  28.r, height: 28.r,
              decoration: BoxDecoration(
                color:  AppColors.success.withValues(alpha: 0.12),
                shape:  BoxShape.circle,
              ),
              child: Icon(Icons.phone_rounded,
                  size: 14.sp, color: AppColors.success),
            ),
          ),
          SizedBox(width: 6.w),
          if (provider.isVerified) _VerifiedBadge(small: true),
        ],
      ),
    );
  }
}

// ── Segment providers section header ─────────────────────────────────────────

class SegmentProviderSection extends StatelessWidget {
  const SegmentProviderSection({
    super.key,
    required this.segmentLabel,
    required this.providers,
    required this.isWater,
    this.compact = false,
    this.index   = 0,
  });

  final String               segmentLabel;
  final List<ServiceProvider> providers;
  final bool                 isWater;
  final bool                 compact;
  final int                  index;

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segment label
        Row(
          children: [
            Icon(
              isWater ? Icons.sailing_rounded : Icons.directions_car_rounded,
              size:  14.sp,
              color: isWater ? AppColors.info : AppColors.primary,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                segmentLabel,
                style: TextStyle(
                  fontSize:   12.sp,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),

        if (compact)
          ...providers.map((p) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child:   ProviderPreviewRow(provider: p),
              ))
        else
          ...providers.asMap().entries.map(
                (e) => ProviderCard(
                  provider: e.value,
                  index:    index + e.key,
                ),
              ),
      ],
    );
  }
}

// ── Verified badge ────────────────────────────────────────────────────────────

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.small});
  final bool small;

  @override
  Widget build(BuildContext context) {
    if (small) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color:        AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded,
                size: 10.sp, color: AppColors.success),
            SizedBox(width: 3.w),
            Text(
              'Verified',
              style: TextStyle(
                fontSize:   9.sp,
                fontWeight: FontWeight.w700,
                color:      AppColors.success,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color:        AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border:       Border.all(
            color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded,
              size: 12.sp, color: AppColors.success),
          SizedBox(width: 4.w),
          Text(
            'Tourism Office',
            style: TextStyle(
              fontSize:   10.sp,
              fontWeight: FontWeight.w700,
              color:      AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.outline = false,
  });
  final IconData   icon;
  final String     label;
  final Color      color;
  final VoidCallback onTap;
  final bool       outline;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color:        outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(10.r),
          border:       outline
              ? Border.all(color: color.withValues(alpha: 0.55))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size:  14.sp,
                color: outline ? color : Colors.white),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize:   12.sp,
                fontWeight: FontWeight.w700,
                color:      outline ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Launch helpers ────────────────────────────────────────────────────────────

Future<void> _dial(String number) async {
  final uri = Uri.parse('tel:${number.replaceAll(RegExp(r'\s'), '')}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    // Copy to clipboard as fallback
    await Clipboard.setData(ClipboardData(text: number));
  }
}

Future<void> _sms(String number) async {
  final uri = Uri.parse('sms:${number.replaceAll(RegExp(r'\s'), '')}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
