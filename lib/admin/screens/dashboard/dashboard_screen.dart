import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../data/models/admin_destination.dart';
import '../../data/repositories/advisory_repository.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/repositories/field_survey_repository.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/route_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/admin_auth_repository.dart';
import '../../../admin_widgets/stat_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardScreen — BiliRoute Admin Portal overview
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = context.watch<DestinationRepository>();
    final routes       = context.watch<RouteRepository>();
    final providers    = context.watch<ProviderRepository>();
    final advisories   = context.watch<AdvisoryRepository>();
    final surveys      = context.watch<FieldSurveyRepository>();
    final users        = context.watch<UserRepository>();
    final auth         = context.watch<AdminAuthRepository>();

    return Scaffold(
      backgroundColor: AdminColors.contentBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            _buildHeader(context, auth.session?.name ?? 'Admin'),
            const SizedBox(height: 28),

            // ── Stats grid ────────────────────────────────────────────────
            _buildStatsGrid(context, destinations, routes, providers, advisories,
                surveys, users),
            const SizedBox(height: 28),

            // ── Bottom row: Verification pipeline + Recent Activity ───────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _VerificationPipelineCard(repo: destinations),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 5,
                  child: _RecentActivityCard(
                    destinations: destinations,
                    advisories:   advisories,
                    surveys:      surveys,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Quick Actions ─────────────────────────────────────────────
            _QuickActionsCard(),
            const SizedBox(height: 28),

            // ── Footer ────────────────────────────────────────────────────
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ── Page header ─────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String adminName) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' :
                     hour < 18 ? 'Good afternoon' : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $adminName 👋',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s an overview of the BiliRoute tourism data.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        // Date badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color:        AdminColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AdminColors.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AdminColors.textSecondary),
              const SizedBox(width: 7),
              Text(
                _formatDate(DateTime.now()),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:      AdminColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── Stats grid ──────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(
    BuildContext context,
    DestinationRepository destinations,
    RouteRepository routes,
    ProviderRepository providers,
    AdvisoryRepository advisories,
    FieldSurveyRepository surveys,
    UserRepository users,
  ) {
    final stats = [
      (
        title:       'Total Destinations',
        value:       '${destinations.count}',
        icon:        Icons.place_rounded,
        color:       AdminColors.destinationAccent,
        subtitle:    '${destinations.publishedCount} published',
        trend:       '+2',
        trendUp:     true,
      ),
      (
        title:       'Active Routes',
        value:       '${routes.activeCount}',
        icon:        Icons.alt_route_rounded,
        color:       AdminColors.routeAccent,
        subtitle:    '${routes.count} total routes',
        trend:       null,
        trendUp:     true,
      ),
      (
        title:       'Verified Providers',
        value:       '${providers.verifiedCount}',
        icon:        Icons.verified_rounded,
        color:       AdminColors.providerAccent,
        subtitle:    '${providers.pendingCount} pending review',
        trend:       null,
        trendUp:     true,
      ),
      (
        title:       'Active Advisories',
        value:       '${advisories.activeCount}',
        icon:        Icons.campaign_rounded,
        color:       AdminColors.advisoryAccent,
        subtitle:    '${advisories.count} total advisories',
        trend:       null,
        trendUp:     false,
      ),
      (
        title:       'Field Surveys',
        value:       '${surveys.validatedCount}',
        icon:        Icons.gps_fixed_rounded,
        color:       AdminColors.surveyAccent,
        subtitle:    '${surveys.pendingCount} pending validation',
        trend:       null,
        trendUp:     true,
      ),
      (
        title:       'Registered Users',
        value:       '${users.activeCount}',
        icon:        Icons.group_rounded,
        color:       AdminColors.userAccent,
        subtitle:    '${users.totalCount} total accounts',
        trend:       '+5',
        trendUp:     true,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics:    const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing:  16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: stats.map((s) => StatCard(
        title:      s.title,
        value:      s.value,
        icon:       s.icon,
        accentColor:s.color,
        subtitle:   s.subtitle,
        trend:      s.trend,
        trendUp:    s.trendUp,
      )).toList(),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text(
        'BiliRoute Admin Portal v1.0 · Biliran Tourism Office · '
        'Smart Tourism Mobility Platform',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verification Pipeline Card
// ─────────────────────────────────────────────────────────────────────────────

class _VerificationPipelineCard extends StatelessWidget {
  const _VerificationPipelineCard({required this.repo});
  final DestinationRepository repo;

  @override
  Widget build(BuildContext context) {
    final counts = {
      DestinationStatus.pending:       repo.items.where((d) => d.status == DestinationStatus.pending).length,
      DestinationStatus.fieldSurveyed: repo.items.where((d) => d.status == DestinationStatus.fieldSurveyed).length,
      DestinationStatus.verified:      repo.items.where((d) => d.status == DestinationStatus.verified).length,
      DestinationStatus.published:     repo.publishedCount,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.cardBorder),
        boxShadow: const [BoxShadow(color: AdminColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verification Pipeline', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Destination workflow status breakdown',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          ...counts.entries.map((e) => _PipelineRow(
            status: e.key,
            count:  e.value,
            total:  repo.count,
          )),
        ],
      ),
    );
  }
}

class _PipelineRow extends StatelessWidget {
  const _PipelineRow({
    required this.status,
    required this.count,
    required this.total,
  });
  final DestinationStatus status;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(status.icon, size: 13, color: status.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(status.label,
                    style: Theme.of(context).textTheme.labelMedium),
              ),
              Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: status.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value:            pct,
            backgroundColor:  AdminColors.tableHeader,
            color:            status.color,
            borderRadius:     BorderRadius.circular(4),
            minHeight:        5,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Activity Card
// ─────────────────────────────────────────────────────────────────────────────

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.destinations,
    required this.advisories,
    required this.surveys,
  });
  final DestinationRepository destinations;
  final AdvisoryRepository    advisories;
  final FieldSurveyRepository surveys;

  @override
  Widget build(BuildContext context) {
    // Build a combined activity feed from all repos
    final activities = <_Activity>[
      _Activity(
        icon:      Icons.gps_fixed_rounded,
        color:     AdminColors.surveyAccent,
        title:     'Sambawan Island GPS Validated',
        subtitle:  'Field survey record published',
        timeAgo:   '2 days ago',
      ),
      _Activity(
        icon:      Icons.public_rounded,
        color:     AdminColors.success,
        title:     'Sambawan Island Published',
        subtitle:  'Status: Published',
        timeAgo:   '2 days ago',
      ),
      _Activity(
        icon:      Icons.campaign_rounded,
        color:     AdminColors.advisoryAccent,
        title:     'Sea Travel Advisory Updated',
        subtitle:  'Biliran Strait moderate waves',
        timeAgo:   '5 days ago',
      ),
      _Activity(
        icon:      Icons.verified_rounded,
        color:     AdminColors.info,
        title:     'Pedro Boat Services Verified',
        subtitle:  'Provider status: Verified',
        timeAgo:   '7 days ago',
      ),
      _Activity(
        icon:      Icons.place_rounded,
        color:     AdminColors.destinationAccent,
        title:     'Agta Beach Added',
        subtitle:  'Status: Verified',
        timeAgo:   '10 days ago',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.cardBorder),
        boxShadow: const [BoxShadow(color: AdminColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Latest system updates',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          ...activities.map((a) => _ActivityRow(activity: a)),
        ],
      ),
    );
  }
}

class _Activity {
  const _Activity({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });
  final IconData icon;
  final Color    color;
  final String   title;
  final String   subtitle;
  final String   timeAgo;
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});
  final _Activity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color:        activity.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(activity.icon, size: 15, color: activity.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(activity.subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(activity.timeAgo,
              style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions Card
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: Icons.add_location_alt_rounded, label: 'Add\nDestination', color: AdminColors.destinationAccent),
      (icon: Icons.add_road_rounded,         label: 'Add\nRoute',       color: AdminColors.routeAccent),
      (icon: Icons.person_add_rounded,       label: 'Add\nProvider',    color: AdminColors.providerAccent),
      (icon: Icons.campaign_rounded,         label: 'New\nAdvisory',    color: AdminColors.advisoryAccent),
      (icon: Icons.gps_fixed_rounded,        label: 'Log GPS\nSurvey',  color: AdminColors.surveyAccent),
      (icon: Icons.tune_rounded,             label: 'Route\nWeights',   color: AdminColors.royalBlue),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.cardBorder),
        boxShadow: const [BoxShadow(color: AdminColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: actions.map((a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _QuickActionButton(
                  icon:  a.icon,
                  label: a.label,
                  color: a.color,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String   label;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color:      color,
                height:     1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


