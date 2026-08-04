import 'package:flutter/material.dart';

import '../admin/core/admin_colors.dart';
import '../admin/core/admin_theme.dart';
import '../admin/screens/dashboard/dashboard_screen.dart';
import '../admin/screens/destinations/destinations_screen.dart';
import '../admin/screens/providers/providers_screen.dart';
import 'admin_nav_drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminScaffold — Main shell for all admin portal screens
//
// Layout: fixed left drawer (256px) + scrollable content area.
// The [body] is swapped via IndexedStack-style routing when the
// selected [AdminModule] changes.
// ─────────────────────────────────────────────────────────────────────────────

class AdminScaffold extends StatefulWidget {
  const AdminScaffold({super.key});

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  AdminModule _selected = AdminModule.dashboard;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AdminTheme.theme,
      child: Scaffold(
        backgroundColor: AdminColors.contentBg,
        body: Row(
          children: [
            // ── Left navigation drawer (fixed) ────────────────────────────
            AdminNavDrawer(
              selectedModule:    _selected,
              onModuleSelected:  (m) => setState(() => _selected = m),
            ),

            // ── Vertical divider ──────────────────────────────────────────
            const VerticalDivider(
              width: 1,
              color: AdminColors.sidebarDivider,
            ),

            // ── Main content area ─────────────────────────────────────────
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: KeyedSubtree(
        key: ValueKey(_selected),
        child: _screenFor(_selected),
      ),
    );
  }

  Widget _screenFor(AdminModule module) {
    switch (module) {
      case AdminModule.dashboard:
        return const DashboardScreen();
      case AdminModule.destinations:
        return const DestinationsScreen();
      case AdminModule.routes:
        return const _ComingSoonScreen(
          module: 'Route Management',
          icon: Icons.alt_route_rounded,
          subtitle: 'Manage multi-step transport routes and fare information.',
        );
      case AdminModule.providers:
        return const ProvidersScreen();
      case AdminModule.schedules:
        return const _ComingSoonScreen(
          module: 'Transport Schedules',
          icon: Icons.schedule_rounded,
          subtitle: 'Manage departure times and operating schedules.',
        );
      case AdminModule.advisories:
        return const _ComingSoonScreen(
          module: 'Travel Advisories',
          icon: Icons.campaign_rounded,
          subtitle: 'Publish and manage travel advisories for tourists.',
        );
      case AdminModule.gallery:
        return const _ComingSoonScreen(
          module: 'Gallery Management',
          icon: Icons.photo_library_rounded,
          subtitle: 'Upload and organize destination photos.',
        );
      case AdminModule.fieldSurvey:
        return const _ComingSoonScreen(
          module: 'Field Survey Records',
          icon: Icons.gps_fixed_rounded,
          subtitle: 'Manage primary GPS data from field surveys.',
        );
      case AdminModule.recommendationSettings:
        return const _ComingSoonScreen(
          module: 'Recommendation Settings',
          icon: Icons.tune_rounded,
          subtitle: 'Configure route recommendation scoring weights.',
        );
      case AdminModule.users:
        return const _ComingSoonScreen(
          module: 'User Management',
          icon: Icons.group_rounded,
          subtitle: 'Manage tourist and researcher accounts.',
        );
      case AdminModule.reports:
        return const _ComingSoonScreen(
          module: 'Reports & Analytics',
          icon: Icons.bar_chart_rounded,
          subtitle: 'View destination and route statistics.',
        );
      case AdminModule.settings:
        return const _ComingSoonScreen(
          module: 'System Settings',
          icon: Icons.settings_rounded,
          subtitle: 'Configure application and tourism office details.',
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder — screens are replaced module by module
// ─────────────────────────────────────────────────────────────────────────────

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({
    required this.module,
    required this.icon,
    required this.subtitle,
  });

  final String   module;
  final IconData icon;
  final String   subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AdminColors.royalBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AdminColors.royalBlue.withValues(alpha: 0.20),
              ),
            ),
            child: Icon(icon, size: 36, color: AdminColors.royalBlue),
          ),
          const SizedBox(height: 20),
          Text(
            module,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AdminColors.teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminColors.teal.withValues(alpha: 0.30)),
            ),
            child: Text(
              '🚧  Screen being implemented',
              style: TextStyle(
                fontSize: 12,
                color: AdminColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
