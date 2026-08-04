import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../admin/screens/auth/admin_login_screen.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Profile Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Tourist profile screen — prototype phase.
///
/// All data displayed is placeholder / mock data.
/// In future implementation:
///   • User data will be fetched from Firebase Auth / Firestore.
///   • Saved itineraries will be loaded from the user's profile document.
///   • Travel preferences will persist via local storage or cloud sync.
///
/// [navClearance] — extra bottom padding so content clears the floating nav bar.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.navClearance = 0});
  final double navClearance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero header with avatar ──────────────────────────────────────
          SliverToBoxAdapter(child: _ProfileHeroHeader()),

          // ── Stats row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: const _StatsRow(),
            ),
          ),

          // ── Travel Preferences ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: _SectionLabel(label: 'Travel Preferences'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
              child: const _TravelPreferencesCard(),
            ),
          ),

          // ── Saved Itineraries ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: _SectionLabel(label: 'Saved Itineraries'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
              child: const _SavedItinerariesCard(),
            ),
          ),

          // ── Favorite Destinations ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: _SectionLabel(label: 'Favorite Destinations'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
              child: const _FavoriteDestinationsRow(),
            ),
          ),

          // ── App Settings ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: _SectionLabel(label: 'App Settings'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
              child: _SettingsCard(
                items: const [
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    trailing: _SettingsTrailing.toggle,
                  ),
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    label: 'Language',
                    value: 'English',
                    trailing: _SettingsTrailing.arrow,
                  ),
                  _SettingsItem(
                    icon: Icons.download_outlined,
                    label: 'Offline Maps',
                    value: 'Biliran Island',
                    trailing: _SettingsTrailing.arrow,
                  ),
                ],
              ),
            ),
          ),
          // ── Appearance ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: _SectionLabel(label: 'Appearance'),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _AppearanceCard(),
            ),
          ),

          // ── My Places ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: _SectionLabel(label: 'My Places'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
              child: _SettingsCard(
                items: [
                  _SettingsItem(
                    icon: Icons.favorite_border_rounded,
                    label: 'Saved Destinations',
                    trailing: _SettingsTrailing.arrow,
                    onTap: () => context.push(AppRouter.savedDestinations),
                  ),
                ],
              ),
            ),
          ),

          // ── About BiliRoute ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: _SectionLabel(label: 'About BiliRoute'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
              child: _SettingsCard(
                items: const [
                  _SettingsItem(
                    icon: Icons.info_outline_rounded,
                    label: 'App Version',
                    value: '1.0.0 (Prototype)',
                    trailing: _SettingsTrailing.none,
                  ),
                  _SettingsItem(
                    icon: Icons.people_outline_rounded,
                    label: 'Developer Team',
                    value: 'BiliRoute Research Team',
                    trailing: _SettingsTrailing.none,
                  ),
                  _SettingsItem(
                    icon: Icons.location_city_outlined,
                    label: 'Tourism Data',
                    value: 'Biliran Tourism Office',
                    trailing: _SettingsTrailing.none,
                  ),
                  _SettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    trailing: _SettingsTrailing.arrow,
                  ),
                  _SettingsItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    trailing: _SettingsTrailing.arrow,
                  ),
                ],
              ),
            ),
          ),

          // ── Hidden admin portal entry (long-press BiliRoute logo) ─────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: const _AdminPortalEntry(),
            ),
          ),

          // ── Bottom clearance ─────────────────────────────────────────────
          SliverToBoxAdapter(child: SizedBox(height: navClearance + 24.h)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero header with gradient background and avatar
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF0EA5E9)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
          child: Column(
            children: [
              // ── Top row: title + edit button ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined,
                            color: Colors.white, size: 13.sp),
                        SizedBox(width: 5.w),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),

              SizedBox(height: 24.h),

              // ── Avatar + name row ─────────────────────────────────────────
              Row(
                children: [
                  // Avatar with gradient ring
                  Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFB923C), Color(0xFFF59E0B)],
                      ),
                    ),
                    child: Container(
                      width: 70.r,
                      height: 70.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E40AF),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 36.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 18.w),

                  // Name & info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tourist Explorer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                color: Colors.white.withValues(alpha: 0.80),
                                size: 13.sp),
                            SizedBox(width: 3.w),
                            Text(
                              'Biliran Island, Eastern Visayas',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        // Verified badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: const Color(0xFF34D399), size: 12.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'Verified Tourist',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate(delay: 100.ms).fade(duration: 450.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row (trips, destinations, reviews)
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(value: '3', label: 'Trips', icon: Icons.luggage_rounded),
          _Divider(),
          _StatItem(value: '7', label: 'Destinations', icon: Icons.explore_rounded),
          _Divider(),
          _StatItem(value: '4', label: 'Saved', icon: Icons.bookmark_rounded),
        ],
      ),
    )
        .animate(delay: 200.ms)
        .fade(duration: 400.ms)
        .slideY(begin: 0.08, end: 0);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String   value;
  final String   label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40.h,
      color: AppColors.divider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Travel preferences card
// ─────────────────────────────────────────────────────────────────────────────

class _TravelPreferencesCard extends StatelessWidget {
  const _TravelPreferencesCard();

  static const _prefs = [
    (icon: Icons.beach_access_rounded,    label: 'Beaches',    color: Color(0xFF3B82F6)),
    (icon: Icons.water_rounded,           label: 'Waterfalls', color: Color(0xFF6366F1)),
    (icon: Icons.holiday_village_rounded, label: 'Islands',    color: Color(0xFF14B8A6)),
    (icon: Icons.landscape_rounded,       label: 'Mountains',  color: Color(0xFF10B981)),
    (icon: Icons.restaurant_rounded,      label: 'Food',       color: Color(0xFFFB923C)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Interests',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Edit',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _prefs.map((p) => _PrefChip(
              icon: p.icon,
              label: p.label,
              color: p.color,
            )).toList(),
          ),
        ],
      ),
    ).animate(delay: 280.ms).fade(duration: 400.ms).slideY(begin: 0.07, end: 0);
  }
}

class _PrefChip extends StatelessWidget {
  const _PrefChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String   label;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Saved itineraries card
// ─────────────────────────────────────────────────────────────────────────────

class _SavedItinerariesCard extends StatelessWidget {
  const _SavedItinerariesCard();

  static const _itineraries = [
    (
      destination: 'Sambawan Island',
      date: 'May 18, 2026',
      fare: '₱1,830',
      icon: Icons.sailing_rounded,
      color: Color(0xFF0EA5E9),
    ),
    (
      destination: 'Agta Beach Day Trip',
      date: 'Apr 30, 2026',
      fare: '₱400',
      icon: Icons.beach_access_rounded,
      color: Color(0xFF3B82F6),
    ),
    (
      destination: 'Tinago Falls Explorer',
      date: 'Apr 12, 2026',
      fare: '₱570',
      icon: Icons.water_rounded,
      color: Color(0xFF6366F1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _itineraries.asMap().entries.map((entry) {
        final i = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: i.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: Icon(i.icon, color: i.color, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i.destination,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        i.date,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      i.fare,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Official fare',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: (300 + entry.key * 60).ms)
              .fade(duration: 380.ms)
              .slideY(begin: 0.06, end: 0),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Favorite destinations horizontal row
// ─────────────────────────────────────────────────────────────────────────────

class _FavoriteDestinationsRow extends StatelessWidget {
  const _FavoriteDestinationsRow();

  static const _favorites = [
    (name: 'Sambawan\nIsland',   emoji: '🏝️', color: Color(0xFF0EA5E9)),
    (name: 'Agta\nBeach',        emoji: '🌊', color: Color(0xFF3B82F6)),
    (name: 'Tinago\nFalls',      emoji: '💧', color: Color(0xFF6366F1)),
    (name: 'Higatangan\nIsland', emoji: '⛵', color: Color(0xFF14B8A6)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _favorites.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (context, i) {
          final f = _favorites[i];
          return Container(
            width: 84.w,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: f.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: f.color.withValues(alpha: 0.20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(f.emoji, style: TextStyle(fontSize: 24.sp)),
                SizedBox(height: 6.h),
                Text(
                  f.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                    color: f.color,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ).animate(delay: (350 + i * 60).ms)
              .fade(duration: 380.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable settings card
// ─────────────────────────────────────────────────────────────────────────────

enum _SettingsTrailing { arrow, toggle, none }

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    required this.trailing,
    this.onTap,
  });
  final IconData           icon;
  final String             label;
  final String?            value;
  final _SettingsTrailing  trailing;
  final VoidCallback?      onTap;
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.items});
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i    = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;

          return Column(
            children: [
              _SettingsTile(item: item),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
            ],
          );
        }).toList(),
      ),
    ).animate(delay: 400.ms).fade(duration: 420.ms).slideY(begin: 0.06, end: 0);
  }
}

class _SettingsTile extends StatefulWidget {
  const _SettingsTile({required this.item});
  final _SettingsItem item;

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _toggled = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.item.onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(widget.item.icon, color: AppColors.primary, size: 17.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (widget.item.value != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      widget.item.value!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trailing widget
            if (widget.item.trailing == _SettingsTrailing.arrow)
              Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary, size: 13.sp)
            else if (widget.item.trailing == _SettingsTrailing.toggle)
              GestureDetector(
                onTap: () => setState(() => _toggled = !_toggled),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 44.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: _toggled ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 220),
                    alignment:
                        _toggled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.all(3.r),
                      width: 18.r,
                      height: 18.r,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Section label widget
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hidden admin portal entry — long-press the BiliRoute logo to open admin login
// ─────────────────────────────────────────────────────────────────────────────

class _AdminPortalEntry extends StatefulWidget {
  const _AdminPortalEntry();

  @override
  State<_AdminPortalEntry> createState() => _AdminPortalEntryState();
}

class _AdminPortalEntryState extends State<_AdminPortalEntry> {
  int _tapCount = 0;

  void _onTap() {
    setState(() => _tapCount++);
    if (_tapCount >= 5) {
      _tapCount = 0;
      _openAdminPortal();
    }
  }

  void _onLongPress() {
    HapticFeedback.mediumImpact();
    _openAdminPortal();
  }

  void _openAdminPortal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _onLongPress,
      onTap: _onTap,
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22.r, height: 22.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1458D4), Color(0xFF15C6D9)],
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(Icons.route_rounded, color: Colors.white, size: 12.sp),
                ),
                SizedBox(width: 7.w),
                Text(
                  'BiliRoute',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              'Smart Tourism Mobility Platform',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textSecondary.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Appearance Card — Light / Dark / Follow System picker
// ─────────────────────────────────────────────────────────────────────────────

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ThemeNotifier>();
    final cs       = Theme.of(context).colorScheme;
    final isDark   = cs.brightness == Brightness.dark;

    final options = [
      (
        mode:  ThemeMode.light,
        emoji: '☀️',
        label: 'Light',
        desc:  'Classic look',
      ),
      (
        mode:  ThemeMode.dark,
        emoji: '🌙',
        label: 'Dark',
        desc:  'Easy on eyes',
      ),
      (
        mode:  ThemeMode.system,
        emoji: '📱',
        label: 'System',
        desc:  'Follow device',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color:        isDark ? DarkColors.card : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 14,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose theme',
            style: TextStyle(
              fontSize:   12.sp,
              color:      AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: options.map((opt) {
              final selected = notifier.mode == opt.mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.read<ThemeNotifier>().setTheme(opt.mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color:        selected
                          ? AppColors.royalBlue
                          : (isDark ? DarkColors.elevated : AppColors.backgroundStart),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: selected
                            ? AppColors.royalBlue
                            : (isDark ? DarkColors.border : AppColors.divider),
                        width: selected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          opt.emoji,
                          style: TextStyle(fontSize: 22.sp),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          opt.label,
                          style: TextStyle(
                            fontSize:   12.sp,
                            fontWeight: FontWeight.w700,
                            color:      selected
                                ? Colors.white
                                : (isDark ? DarkColors.text : AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          opt.desc,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            color:    selected
                                ? Colors.white.withValues(alpha: 0.80)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate(delay: 380.ms).fade(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}
