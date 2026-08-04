import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../admin/core/admin_colors.dart';
import '../admin/data/repositories/admin_auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminNavDrawer — Left-side collapsible navigation for the admin portal
// ─────────────────────────────────────────────────────────────────────────────

enum AdminModule {
  dashboard,
  destinations,
  routes,
  providers,
  schedules,
  advisories,
  gallery,
  fieldSurvey,
  recommendationSettings,
  users,
  reports,
  settings,
}

extension AdminModuleX on AdminModule {
  String get label {
    switch (this) {
      case AdminModule.dashboard:              return 'Dashboard';
      case AdminModule.destinations:           return 'Destinations';
      case AdminModule.routes:                 return 'Routes';
      case AdminModule.providers:              return 'Service Providers';
      case AdminModule.schedules:              return 'Schedules';
      case AdminModule.advisories:             return 'Travel Advisories';
      case AdminModule.gallery:                return 'Gallery';
      case AdminModule.fieldSurvey:            return 'Field Survey Records';
      case AdminModule.recommendationSettings: return 'Recommendation Settings';
      case AdminModule.users:                  return 'User Management';
      case AdminModule.reports:                return 'Reports & Analytics';
      case AdminModule.settings:               return 'System Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case AdminModule.dashboard:              return Icons.dashboard_rounded;
      case AdminModule.destinations:           return Icons.place_rounded;
      case AdminModule.routes:                 return Icons.alt_route_rounded;
      case AdminModule.providers:              return Icons.directions_car_rounded;
      case AdminModule.schedules:              return Icons.schedule_rounded;
      case AdminModule.advisories:             return Icons.campaign_rounded;
      case AdminModule.gallery:                return Icons.photo_library_rounded;
      case AdminModule.fieldSurvey:            return Icons.gps_fixed_rounded;
      case AdminModule.recommendationSettings: return Icons.tune_rounded;
      case AdminModule.users:                  return Icons.group_rounded;
      case AdminModule.reports:                return Icons.bar_chart_rounded;
      case AdminModule.settings:               return Icons.settings_rounded;
    }
  }

  String get emoji {
    switch (this) {
      case AdminModule.dashboard:              return '🏠';
      case AdminModule.destinations:           return '🏝';
      case AdminModule.routes:                 return '🛣';
      case AdminModule.providers:              return '🚐';
      case AdminModule.schedules:              return '📅';
      case AdminModule.advisories:             return '📢';
      case AdminModule.gallery:                return '🖼';
      case AdminModule.fieldSurvey:            return '🔬';
      case AdminModule.recommendationSettings: return '⚙';
      case AdminModule.users:                  return '👥';
      case AdminModule.reports:                return '📊';
      case AdminModule.settings:               return '🔧';
    }
  }
}

class AdminNavDrawer extends StatelessWidget {
  const AdminNavDrawer({
    super.key,
    required this.selectedModule,
    required this.onModuleSelected,
  });

  final AdminModule selectedModule;
  final ValueChanged<AdminModule> onModuleSelected;

  // P1 modules (always visible)
  static const _p1Modules = [
    AdminModule.dashboard,
    AdminModule.destinations,
    AdminModule.routes,
    AdminModule.providers,
    AdminModule.schedules,
    AdminModule.advisories,
  ];

  // P2 modules
  static const _p2Modules = [
    AdminModule.gallery,
    AdminModule.fieldSurvey,
    AdminModule.recommendationSettings,
  ];

  // P3 modules
  static const _p3Modules = [
    AdminModule.users,
    AdminModule.reports,
    AdminModule.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthRepository>();

    return Container(
      width: 256,
      color: AdminColors.sidebarBg,
      child: Column(
        children: [
          // ── Brand Header ────────────────────────────────────────────────────
          _buildHeader(),

          // ── Admin Badge ─────────────────────────────────────────────────────
          _buildAdminBadge(auth.session?.name ?? 'Admin', auth.currentRole.label),

          const SizedBox(height: 8),

          // ── Nav Items ───────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildSection('CORE MANAGEMENT'),
                ..._p1Modules.map((m) => _NavItem(
                  module:   m,
                  selected: selectedModule == m,
                  onTap:    () => onModuleSelected(m),
                )),

                const SizedBox(height: 12),
                _buildSection('RESEARCH & INTELLIGENCE'),
                ..._p2Modules.map((m) => _NavItem(
                  module:   m,
                  selected: selectedModule == m,
                  onTap:    () => onModuleSelected(m),
                )),

                const SizedBox(height: 12),
                _buildSection('ADMINISTRATION'),
                ..._p3Modules.map((m) => _NavItem(
                  module:   m,
                  selected: selectedModule == m,
                  onTap:    () => onModuleSelected(m),
                )),
              ],
            ),
          ),

          // ── Logout ──────────────────────────────────────────────────────────
          _buildLogout(context, auth),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AdminColors.royalBlue, AdminColors.teal],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.route_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BiliRoute',
                style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Admin Portal',
                style: GoogleFonts.inter(
                  color: AdminColors.teal, fontSize: 10, fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBadge(String name, String role) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AdminColors.sidebarActive,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.sidebarDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AdminColors.teal.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: AdminColors.teal, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600,
                )),
                Text(role, style: GoogleFonts.inter(
                  color: AdminColors.teal, fontSize: 10, fontWeight: FontWeight.w500,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: AdminColors.sidebarIcon,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context, AdminAuthRepository auth) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AdminColors.sidebarDivider)),
      ),
      child: InkWell(
        onTap: () => auth.logout(),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded,
                  color: AdminColors.sidebarIcon, size: 18),
              const SizedBox(width: 10),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: AdminColors.sidebarText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual nav item
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.module,
    required this.selected,
    required this.onTap,
  });

  final AdminModule module;
  final bool        selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? AdminColors.royalBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: AdminColors.sidebarHover,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(
                  module.icon,
                  size: 16,
                  color: selected
                      ? Colors.white
                      : AdminColors.sidebarIcon,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    module.label,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : AdminColors.sidebarText,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 5, height: 5,
                    decoration: const BoxDecoration(
                      color: AdminColors.teal,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
