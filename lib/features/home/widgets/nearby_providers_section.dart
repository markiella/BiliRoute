import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider data model
// ─────────────────────────────────────────────────────────────────────────────

enum _ProviderType { van, boat, habalHabal }

class _Provider {
  const _Provider({
    required this.name,
    required this.type,
    required this.rating,
    required this.responseTime,
    required this.avatarEmoji,
    required this.avatarColor,
    required this.isVerified,
    required this.isAvailable,
  });
  final String        name;
  final _ProviderType type;
  final double        rating;
  final String        responseTime;
  final String        avatarEmoji;
  final Color         avatarColor;
  final bool          isVerified;
  final bool          isAvailable;
}

const _providers = [
  _Provider(
    name:         'Mang Eddie Transport',
    type:         _ProviderType.van,
    rating:       4.8,
    responseTime: '~5 min',
    avatarEmoji:  '🚐',
    avatarColor:  Color(0xFF1E3A8A),
    isVerified:   true,
    isAvailable:  true,
  ),
  _Provider(
    name:         'Sambawan Sea Ferry',
    type:         _ProviderType.boat,
    rating:       4.9,
    responseTime: '~12 min',
    avatarEmoji:  '⛵',
    avatarColor:  Color(0xFF0891B2),
    isVerified:   true,
    isAvailable:  true,
  ),
  _Provider(
    name:         'Kuya Ricky Ride',
    type:         _ProviderType.habalHabal,
    rating:       4.7,
    responseTime: '~3 min',
    avatarEmoji:  '🏍️',
    avatarColor:  Color(0xFF059669),
    isVerified:   true,
    isAvailable:  true,
  ),
  _Provider(
    name:         'Naval Multi-Cab',
    type:         _ProviderType.van,
    rating:       4.6,
    responseTime: '~8 min',
    avatarEmoji:  '🚌',
    avatarColor:  Color(0xFF7C3AED),
    isVerified:   false,
    isAvailable:  true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Section widget
// ─────────────────────────────────────────────────────────────────────────────

class NearbyProvidersSection extends StatelessWidget {
  const NearbyProvidersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_providers.length, (i) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, i == 0 ? 10.h : 10.h, 16.w, 0),
        child: _ProviderCard(provider: _providers[i], delay: (i * 80).ms),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider card
// ─────────────────────────────────────────────────────────────────────────────

extension _ProviderTypeEx on _ProviderType {
  String get label {
    switch (this) {
      case _ProviderType.van:       return 'Van · Multi-cab';
      case _ProviderType.boat:      return 'Ferry · Boat';
      case _ProviderType.habalHabal: return 'Habal-habal';
    }
  }

  IconData get icon {
    switch (this) {
      case _ProviderType.van:       return Icons.airport_shuttle_rounded;
      case _ProviderType.boat:      return Icons.sailing_rounded;
      case _ProviderType.habalHabal: return Icons.two_wheeler_rounded;
    }
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider, required this.delay});
  final _Provider provider;
  final Duration  delay;

  @override
  Widget build(BuildContext context) {
    final p      = provider;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding:    EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color:        isDark ? DarkColors.card : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? DarkColors.border : Colors.grey.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width:  52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color:  p.avatarColor,
              shape:  BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:      p.avatarColor.withValues(alpha: 0.30),
                  blurRadius: 10,
                  offset:     const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(p.avatarEmoji,
                  style: TextStyle(fontSize: 22.sp)),
            ),
          ),
          SizedBox(width: 12.w),

          // Info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + verified badge
                Row(
                  children: [
                    Expanded(
                      child: Text(p.name,
                          style: TextStyle(
                            fontSize:   13.sp,
                            fontWeight: FontWeight.w800,
                            color:      isDark ? DarkColors.text : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (p.isVerified) ...[
                      SizedBox(width: 6.w),
                      Builder(builder: (ctx) {
                        final l10n = AppLocalizations.of(ctx)!;
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color:        const Color(0xFF1E3A8A)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: isDark ? AppColors.oceanCyan : const Color(0xFF1E3A8A),
                                  size: 9.sp),
                              SizedBox(width: 3.w),
                              Text(l10n.providerVerified,
                                  style: TextStyle(
                                    color:      isDark ? AppColors.oceanCyan : const Color(0xFF1E3A8A),
                                    fontSize:   8.sp,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),

                // Type + rating row
                Row(
                  children: [
                    Icon(p.type.icon,
                        size: 11.sp, color: isDark ? DarkColors.subtext : AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(p.type.label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color:    isDark ? DarkColors.subtext : AppColors.textSecondary,
                        )),
                    SizedBox(width: 8.w),
                    Icon(Icons.star_rounded,
                        size: 11.sp, color: const Color(0xFFF59E0B)),
                    SizedBox(width: 2.w),
                    Text(p.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize:   10.sp,
                          fontWeight: FontWeight.w700,
                          color:      isDark ? DarkColors.text : AppColors.textPrimary,
                        )),
                  ],
                ),
                SizedBox(height: 6.h),

                // Status + response
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color:        p.isAvailable
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : const Color(0xFFEF4444).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width:  5.r,
                            height: 5.r,
                            decoration: BoxDecoration(
                              color: p.isAvailable
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Builder(builder: (ctx) {
                            final l10n = AppLocalizations.of(ctx)!;
                            return Text(
                              p.isAvailable ? l10n.providerAvailableNow : l10n.providerUnavailable,
                              style: TextStyle(
                                color:      p.isAvailable
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFEF4444),
                                fontSize:   9.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.access_time_rounded,
                        size: 10.sp, color: isDark ? DarkColors.subtext : AppColors.textSecondary),
                    SizedBox(width: 3.w),
                    Text(p.responseTime,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color:    isDark ? DarkColors.subtext : AppColors.textSecondary,
                        )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Action buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(
                icon:    Icons.call_rounded,
                color:   const Color(0xFF10B981),
                onTap:   () => HapticFeedback.mediumImpact(),
              ),
              SizedBox(height: 6.h),
              _ActionBtn(
                icon:    Icons.chat_bubble_rounded,
                color:   AppColors.primary,
                onTap:   () => HapticFeedback.selectionClick(),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fade(duration: 350.ms)
        .slideY(begin: 0.10, end: 0);
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData     icon;
  final Color        color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color:  color.withValues(alpha: 0.12),
          shape:  BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 16.sp),
      ),
    );
  }
}
