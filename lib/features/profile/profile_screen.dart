import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/preferences/app_font_size.dart';
import '../../core/preferences/user_preferences_notifier.dart';
import '../../core/router/app_router.dart';
import '../../core/saved/saved_destinations_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_notifier.dart';
import '../../data/models/destination_model.dart';
import '../../l10n/app_localizations.dart';
import '../auth/repositories/auth_repository.dart';
import '../auth/widgets/account_verification_status.dart';
import '../destinations/repositories/destination_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Profile Screen — BiliRoute Tourist Application
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.navClearance = 0});
  final double navClearance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero header with avatar & edit profile button ────────────────
          SliverToBoxAdapter(child: _ProfileHeroHeader()),

          // ── Real Statistics row ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: const _StatsRow(),
            ),
          ),

          // ── Account Verification Status ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: const AccountVerificationStatus(),
            ),
          ),

          // ── Contact & Emergency Details ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: const _ContactDetailsCard(),
            ),
          ),

          // ── Travel Preferences ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _SectionLabel(label: 'Travel Preferences'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
              child: const _TravelPreferencesCard(),
            ),
          ),

          // ── Saved Destinations Section ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(label: 'Saved Destinations'),
                  TextButton(
                    onPressed: () => context.push(AppRouter.savedDestinations),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.royalBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
              child: const _SavedDestinationsProfileSection(),
            ),
          ),

          // ── Appearance (Theme Selector) ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _SectionLabel(
                  label: AppLocalizations.of(context)?.appearance ?? 'Appearance'),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: _AppearanceCard(),
            ),
          ),

          // ── Accessibility & Language ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _SectionLabel(
                  label: AppLocalizations.of(context)?.accessibilityAndLanguage ??
                         'Accessibility & Language'),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: _AccessibilityCard(),
            ),
          ),

          // ── My Places ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _SectionLabel(label: 'My Places'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
              child: _SettingsCard(
                items: [
                  _SettingsItem(
                    icon: Icons.bookmark_border_rounded,
                    label: 'Manage Saved Destinations',
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
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
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
                    value: '1.0.0 (Production Release)',
                    trailing: _SettingsTrailing.none,
                  ),
                  _SettingsItem(
                    icon: Icons.location_city_outlined,
                    label: 'Tourism Data',
                    value: 'Biliran Tourism Office',
                    trailing: _SettingsTrailing.none,
                  ),
                ],
              ),
            ),
          ),

          // ── Account Session ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _SectionLabel(label: 'Account Session'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
              child: _SettingsCard(
                items: [
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    label: 'Log Out',
                    trailing: _SettingsTrailing.arrow,
                    onTap: () async {
                      await context.read<AuthRepository>().logout();
                      if (context.mounted) {
                        context.go(AppRouter.login);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── App Footer Branding ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: const _AppFooterBranding(),
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
  static const _presetAvatars = {
    'avatar_1': (icon: Icons.explore_rounded, color: Color(0xFF1458D4)),
    'avatar_2': (icon: Icons.hiking_rounded, color: Color(0xFF10B981)),
    'avatar_3': (icon: Icons.camera_alt_rounded, color: Color(0xFFF59E0B)),
    'avatar_4': (icon: Icons.directions_boat_rounded, color: Color(0xFF06B6D4)),
    'avatar_5': (icon: Icons.map_rounded, color: Color(0xFF8B5CF6)),
    'avatar_6': (icon: Icons.stars_rounded, color: Color(0xFFEC4899)),
  };

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthRepository>().currentSession;
    final displayName = session.fullName?.isNotEmpty == true
        ? session.fullName!
        : 'Tourist Explorer';
    final emailText = session.email?.isNotEmpty == true ? session.email! : 'explorer@biliroute.ph';

    final coverPic = session.coverPic;
    final profilePic = session.profilePic;
    final bioText = session.bio;

    final isCustomCover = coverPic != null && coverPic != 'default_blue';
    final isAssetCover = coverPic != null && coverPic.startsWith('assets/');

    Widget coverWidget;
    if (!isCustomCover) {
      coverWidget = Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2E73), Color(0xFF1458D4), Color(0xFF15C6D9)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
      );
    } else if (isAssetCover) {
      coverWidget = Image.asset(coverPic, fit: BoxFit.cover);
    } else if (kIsWeb || coverPic.startsWith('http') || coverPic.startsWith('blob:')) {
      coverWidget = Image.network(
        coverPic,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A2E73), Color(0xFF1458D4), Color(0xFF15C6D9)],
            ),
          ),
        ),
      );
    } else {
      bool exists = false;
      try {
        exists = File(coverPic).existsSync();
      } catch (_) {}

      if (exists) {
        coverWidget = Image.file(
          File(coverPic),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A2E73), Color(0xFF1458D4), Color(0xFF15C6D9)],
              ),
            ),
          ),
        );
      } else {
        coverWidget = Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A2E73), Color(0xFF1458D4), Color(0xFF15C6D9)],
            ),
          ),
        );
      }
    }

    final isCustomAvatar = profilePic != null && !profilePic.startsWith('avatar_');
    final isPresetAvatar = profilePic != null && _presetAvatars.containsKey(profilePic);
    final presetAvatarObj = isPresetAvatar ? _presetAvatars[profilePic] : null;

    Widget avatarWidget;
    if (isPresetAvatar) {
      avatarWidget = Icon(presetAvatarObj!.icon, color: Colors.white, size: 34.sp);
    } else if (isCustomAvatar) {
      if (kIsWeb || profilePic.startsWith('http') || profilePic.startsWith('blob:')) {
        avatarWidget = ClipOval(
          child: Image.network(
            profilePic,
            width: 68.r,
            height: 68.r,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Icon(Icons.person_rounded, color: Colors.white, size: 36.sp),
          ),
        );
      } else {
        bool exists = false;
        try {
          exists = File(profilePic).existsSync();
        } catch (_) {}

        if (exists) {
          avatarWidget = ClipOval(
            child: Image.file(
              File(profilePic),
              width: 68.r,
              height: 68.r,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Icon(Icons.person_rounded, color: Colors.white, size: 36.sp),
            ),
          );
        } else {
          avatarWidget = Icon(Icons.person_rounded, color: Colors.white, size: 36.sp);
        }
      }
    } else {
      avatarWidget = Icon(Icons.person_rounded, color: Colors.white, size: 36.sp);
    }

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: Stack(
          children: [
            // ── Background Cover Picture / Gradient ────────────────────────
            Positioned.fill(child: coverWidget),

            // Gradient Overlay for Readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.70),
                    ],
                  ),
                ),
              ),
            ),

            // ── Header Content ─────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: title + edit button
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
                            shadows: const [Shadow(blurRadius: 6, color: Colors.black45)],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRouter.editProfile),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.40),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined, color: Colors.white, size: 13.sp),
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
                        ),
                      ],
                    ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),

                    SizedBox(height: 20.h),

                    // Avatar + name row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Avatar
                        Container(
                          padding: EdgeInsets.all(3.r),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF15C6D9), Color(0xFF4DD9E8)],
                            ),
                          ),
                          child: Container(
                            width: 68.r,
                            height: 68.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPresetAvatar ? presetAvatarObj!.color : const Color(0xFF0A2E73),
                            ),
                            child: avatarWidget,
                          ),
                        ),

                        SizedBox(width: 16.w),

                        // Name & info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  shadows: const [Shadow(blurRadius: 4, color: Colors.black45)],
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: Colors.white.withValues(alpha: 0.90),
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      emailText,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.90),
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              // Verified badge
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      session.isEmailVerified
                                          ? Icons.verified_rounded
                                          : Icons.mark_email_unread_rounded,
                                      color: session.isEmailVerified
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFFFBBF24),
                                      size: 12.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      session.isEmailVerified ? 'Verified Tourist' : 'Pending Verification',
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

                    // Optional Bio line
                    if (bioText != null && bioText.trim().isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.format_quote_rounded, color: Colors.white70, size: 16.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                bioText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 11.5.sp,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
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
// Contact & Emergency Details Card
// ─────────────────────────────────────────────────────────────────────────────

class _ContactDetailsCard extends StatelessWidget {
  const _ContactDetailsCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final session = context.watch<AuthRepository>().currentSession;

    final phone = session.phoneNumber?.isNotEmpty == true ? session.phoneNumber! : 'Not added';
    final location = session.location?.isNotEmpty == true ? session.location! : 'Not added';
    final emergency = session.emergencyContact?.isNotEmpty == true ? session.emergencyContact! : 'Not added';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              Icon(Icons.badge_outlined, color: AppColors.royalBlue, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'Contact & Safety Info',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phone,
          ),
          SizedBox(height: 8.h),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: location,
          ),
          SizedBox(height: 8.h),
          _DetailRow(
            icon: Icons.health_and_safety_outlined,
            label: 'Emergency Contact',
            value: emergency,
            isEmergency: true,
          ),
        ],
      ),
    ).animate(delay: 240.ms).fade(duration: 400.ms).slideY(begin: 0.07, end: 0);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmergency = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isEmergency;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          icon,
          size: 15.sp,
          color: isEmergency ? const Color(0xFFEF4444) : AppColors.textSecondary,
        ),
        SizedBox(width: 8.w),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: isEmergency && value != 'Not added'
                  ? const Color(0xFFDC2626)
                  : cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Real Stats row (Saved count, Travel preference, Verification)
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthRepository>().currentSession;
    final savedCount = context.watch<SavedDestinationsNotifier>().savedIds.length;

    String prefLabel;
    switch (session.preferenceProfile) {
      case 'budget':
        prefLabel = 'Budget';
        break;
      case 'fastest':
        prefLabel = 'Fastest';
        break;
      case 'fewer_transfers':
        prefLabel = 'Direct';
        break;
      case 'safer':
        prefLabel = 'Safer';
        break;
      case 'recommended':
      default:
        prefLabel = 'Balanced';
        break;
    }

    final verificationLabel = session.isEmailVerified ? 'Verified' : 'Pending';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          _StatItem(value: '$savedCount', label: 'Saved Places', icon: Icons.bookmark_rounded),
          _Divider(),
          _StatItem(value: prefLabel, label: 'Preference', icon: Icons.tune_rounded),
          _Divider(),
          _StatItem(value: verificationLabel, label: 'Account', icon: Icons.verified_user_rounded),
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
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.royalBlue, size: 20.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
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
      height: 36.h,
      color: AppColors.divider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Travel preferences card
// ─────────────────────────────────────────────────────────────────────────────

class _TravelPreferencesCard extends StatelessWidget {
  const _TravelPreferencesCard();

  static const _profiles = [
    (key: 'recommended', label: 'Balanced', emoji: '⭐', color: Color(0xFF1458D4)),
    (key: 'budget', label: 'Budget-Friendly', emoji: '💰', color: Color(0xFF10B981)),
    (key: 'fastest', label: 'Fastest Route', emoji: '⚡', color: Color(0xFFF59E0B)),
    (key: 'fewer_transfers', label: 'Fewer Transfers', emoji: '🚌', color: Color(0xFF8B5CF6)),
    (key: 'safer', label: 'Safer Travel', emoji: '🛡️', color: Color(0xFF06B6D4)),
  ];

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthRepository>().currentSession;
    final activeProfile = session.preferenceProfile;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                'Route Optimization Preference',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (context.watch<AuthRepository>().isLoading)
                SizedBox(
                  width: 14.r,
                  height: 14.r,
                  child: const CircularProgressIndicator(strokeWidth: 2.0),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _profiles.map((p) {
              final isSelected = activeProfile == p.key;
              return GestureDetector(
                onTap: () async {
                  if (!isSelected) {
                    final success = await context
                        .read<AuthRepository>()
                        .updatePreferenceProfile(p.key);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<AuthRepository>().errorMessage ??
                                'Failed to update preference on backend.',
                          ),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? p.color : p.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isSelected ? p.color : p.color.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    '${p.emoji} ${p.label}',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate(delay: 280.ms).fade(duration: 400.ms).slideY(begin: 0.07, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Real Saved Destinations Profile Section
// ─────────────────────────────────────────────────────────────────────────────

class _SavedDestinationsProfileSection extends StatelessWidget {
  const _SavedDestinationsProfileSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final savedNotifier = context.watch<SavedDestinationsNotifier>();
    final repo = context.watch<TouristDestinationRepository>();
    final allDests = repo.destinations.isNotEmpty ? repo.destinations : allBiliranDestinations;

    final savedDests = allDests.where((d) => savedNotifier.isSaved(d.id)).toList();

    if (savedDests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(Icons.bookmark_outline_rounded, color: AppColors.textSecondary, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'No saved destinations yet',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Explore Biliran destinations and tap the bookmark icon to save places.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: savedDests.take(3).map((dest) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: GestureDetector(
            onTap: () => context.push(
              AppRouter.destinationDetails,
              extra: dest,
            ),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: dest.imageAsset.startsWith('http')
                        ? Image.network(
                            dest.imageAsset,
                            width: 50.r,
                            height: 50.r,
                            fit: BoxFit.cover,
                            errorBuilder: (_, err, stack) => Container(
                              width: 50.r, height: 50.r,
                              color: AppColors.royalBlue.withValues(alpha: 0.1),
                              child: Icon(Icons.place_rounded, color: AppColors.royalBlue, size: 24.sp),
                            ),
                          )
                        : Image.asset(
                            dest.imageAsset,
                            width: 50.r,
                            height: 50.r,
                            fit: BoxFit.cover,
                            errorBuilder: (_, err, stack) => Container(
                              width: 50.r, height: 50.r,
                              color: AppColors.royalBlue.withValues(alpha: 0.1),
                              child: Icon(Icons.place_rounded, color: AppColors.royalBlue, size: 24.sp),
                            ),
                          ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dest.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          dest.municipality,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark_remove_rounded, color: const Color(0xFFEF4444), size: 20.sp),
                    tooltip: 'Unsave',
                    onPressed: () async {
                      try {
                        await savedNotifier.toggle(dest.id);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable settings card
// ─────────────────────────────────────────────────────────────────────────────

enum _SettingsTrailing { arrow, none }

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    required this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String? value;
  final _SettingsTrailing trailing;
  final VoidCallback? onTap;
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.items});
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          final i = entry.key;
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
    ).animate(delay: 350.ms).fade(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.item});
  final _SettingsItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.royalBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(item.icon, color: AppColors.royalBlue, size: 17.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (item.value != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      item.value!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.trailing == _SettingsTrailing.arrow)
              Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary, size: 13.sp),
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
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Footer Branding
// ─────────────────────────────────────────────────────────────────────────────

class _AppFooterBranding extends StatelessWidget {
  const _AppFooterBranding();

  @override
  Widget build(BuildContext context) {
    return Center(
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
            'Smart Tourist Route Recommendation Platform',
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    final options = [
      (
        mode: ThemeMode.light,
        emoji: '☀️',
        label: 'Light',
        desc: 'Classic look',
      ),
      (
        mode: ThemeMode.dark,
        emoji: '🌙',
        label: 'Dark',
        desc: 'Easy on eyes',
      ),
      (
        mode: ThemeMode.system,
        emoji: '📱',
        label: 'System',
        desc: 'Follow device',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.card : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
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
              fontSize: 12.sp,
              color: AppColors.textSecondary,
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
                      color: selected
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
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : (isDark ? DarkColors.text : AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          opt.desc,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            color: selected
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

// ─────────────────────────────────────────────────────────────────────────────
// _AccessibilityCard — Font Size + Language pickers
// ─────────────────────────────────────────────────────────────────────────────

class _AccessibilityCard extends StatelessWidget {
  const _AccessibilityCard();

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesNotifier>();
    final l10n  = AppLocalizations.of(context);
    final cs    = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.card : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Font Size section ──────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.text_fields_rounded,
                  color: AppColors.royalBlue, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                l10n?.fontSize ?? 'Font Size',
                style: TextStyle(
                  fontSize:   13.sp,
                  fontWeight: FontWeight.w700,
                  color:      cs.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Font size option chips
          Row(
            children: AppFontSize.values.map((size) {
              final selected = prefs.fontSize == size;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: GestureDetector(
                    onTap: () => context.read<UserPreferencesNotifier>().setFontSize(size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.royalBlue
                            : (isDark ? DarkColors.elevated : AppColors.backgroundStart),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: selected ? AppColors.royalBlue
                              : (isDark ? DarkColors.border : AppColors.divider),
                          width: selected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          size.label,
                          style: TextStyle(
                            fontSize:   size == AppFontSize.small  ? 10.5.sp
                                      : size == AppFontSize.medium ? 12.sp
                                      : 13.5.sp,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected ? Colors.white
                                : (isDark ? DarkColors.text : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Preview text
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.royalBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              l10n?.fontSizePreview ??
                  'The quick brown fox jumps over the lazy dog.',
              style: TextStyle(
                fontSize:   13.sp,
                color:      AppColors.textSecondary,
                fontStyle:  FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 20.h),
          Divider(height: 1, color: AppColors.divider),
          SizedBox(height: 20.h),

          // ── Language section ───────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.language_rounded,
                  color: AppColors.royalBlue, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                l10n?.appLanguage ?? 'App Language',
                style: TextStyle(
                  fontSize:   13.sp,
                  fontWeight: FontWeight.w700,
                  color:      cs.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Language option tiles
          ...UserPreferencesNotifier.supportedLocales.map((locale) {
            final selected = prefs.locale == locale;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: GestureDetector(
                onTap: () => context.read<UserPreferencesNotifier>().setLocale(locale),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.royalBlue.withValues(alpha: 0.08)
                        : (isDark ? DarkColors.elevated : AppColors.backgroundStart),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: selected ? AppColors.royalBlue
                          : (isDark ? DarkColors.border : AppColors.divider),
                      width: selected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        UserPreferencesNotifier.localeFlag(locale),
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          UserPreferencesNotifier.localeDisplayName(locale),
                          style: TextStyle(
                            fontSize:   13.sp,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected ? AppColors.royalBlue : cs.onSurface,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.royalBlue, size: 18.sp),
                    ],
                  ),
                ),
              ),
            );
          }),

        ],
      ),
    ).animate(delay: 400.ms).fade(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}
