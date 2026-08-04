import 'package:flutter/material.dart';

import '../../../data/transport/transport_route.dart';
import '../models/admin_route.dart';
import 'base_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RouteRepository — Seeded with Biliran route options
// ─────────────────────────────────────────────────────────────────────────────

class RouteRepository extends BaseRepository<AdminRoute> {
  RouteRepository() {
    _seedRoutes();
  }

  void _seedRoutes() {
    seed(_sambawanRoutes + _agtaRoutes + _higatanganRoutes + _otherRoutes);
  }

  // ── BaseRepository ──────────────────────────────────────────────────────────

  @override
  String idOf(AdminRoute item) => item.id;

  @override
  AdminRoute? getById(String id) {
    try {
      return items.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Queries ─────────────────────────────────────────────────────────────────

  List<AdminRoute> getActive() =>
      items.where((r) => r.status == RouteStatus.active).toList();

  List<AdminRoute> forDestination(String destinationId) =>
      items.where((r) => r.destinationId == destinationId).toList();

  List<AdminRoute> search(String query) {
    final q = query.toLowerCase();
    return items
        .where((r) =>
            r.label.toLowerCase().contains(q) ||
            r.startingPoint.toLowerCase().contains(q) ||
            r.destination.toLowerCase().contains(q))
        .toList();
  }

  void updateRoute(AdminRoute updated) {
    final idx = indexById(updated.id);
    if (idx == -1) return;
    updateAt(idx, updated);
  }

  // ── Dashboard stats ─────────────────────────────────────────────────────────

  int get activeCount =>
      items.where((r) => r.status == RouteStatus.active).length;

  // ── Seed data ────────────────────────────────────────────────────────────────

  static final List<AdminRoute> _sambawanRoutes = [
    AdminRoute(
      id:            'route-sambawan-recommended',
      label:         'Best Route — Sambawan',
      badge:         '⭐ Recommended',
      badgeColor:    const Color(0xFF1E3A8A),
      startingPoint: 'Tacloban Airport',
      destination:   'Sambawan Island',
      destinationId: 'sambawan_island',
      routeType:     RouteType.mixed,
      isHighlighted: true,
      status:        RouteStatus.active,
      dateAdded:     DateTime(2025, 1, 1),
      steps: [
        AdminRouteStep(id: 'rs-001-1', from: 'Tacloban Airport', to: 'Naval Terminal',  transportType: TransportType.van,         fareAmount: 120, durationMinutes: 120),
        AdminRouteStep(id: 'rs-001-2', from: 'Naval',            to: 'Kawayan Port',    transportType: TransportType.multicab,    fareAmount: 55,  durationMinutes: 45),
        AdminRouteStep(id: 'rs-001-3', from: 'Kawayan Port',     to: 'Sambawan Island', transportType: TransportType.boatCharter, fareAmount: 800, durationMinutes: 30, isSeaRoute: true),
      ],
    ),
    AdminRoute(
      id:            'route-sambawan-budget',
      label:         'Budget Route — Sambawan',
      badge:         '💰 Cheapest',
      badgeColor:    const Color(0xFF059669),
      startingPoint: 'Tacloban',
      destination:   'Sambawan Island',
      destinationId: 'sambawan_island',
      routeType:     RouteType.mixed,
      status:        RouteStatus.active,
      dateAdded:     DateTime(2025, 1, 1),
      steps: [
        AdminRouteStep(id: 'rs-002-1', from: 'Tacloban',  to: 'Naval',         transportType: TransportType.van,         fareAmount: 80,  durationMinutes: 150),
        AdminRouteStep(id: 'rs-002-2', from: 'Naval',     to: 'Kawayan',       transportType: TransportType.multicab,    fareAmount: 55,  durationMinutes: 45),
        AdminRouteStep(id: 'rs-002-3', from: 'Kawayan',   to: 'Sambawan Port', transportType: TransportType.habalHabal,  fareAmount: 60,  durationMinutes: 25),
        AdminRouteStep(id: 'rs-002-4', from: 'Port',      to: 'Sambawan',      transportType: TransportType.boat,        fareAmount: 420, durationMinutes: 30, isSeaRoute: true),
      ],
    ),
    AdminRoute(
      id:            'route-sambawan-express',
      label:         'Express Route — Sambawan',
      badge:         '⚡ Fastest',
      badgeColor:    const Color(0xFFF59E0B),
      startingPoint: 'Tacloban Airport',
      destination:   'Sambawan Island',
      destinationId: 'sambawan_island',
      routeType:     RouteType.mixed,
      status:        RouteStatus.active,
      dateAdded:     DateTime(2025, 1, 1),
      steps: [
        AdminRouteStep(id: 'rs-003-1', from: 'Tacloban Airport', to: 'Naval Port',      transportType: TransportType.van,         fareAmount: 600,  durationMinutes: 90),
        AdminRouteStep(id: 'rs-003-2', from: 'Naval Port',       to: 'Sambawan Island', transportType: TransportType.boatCharter, fareAmount: 2000, durationMinutes: 50, isSeaRoute: true),
      ],
    ),
  ];

  static final List<AdminRoute> _agtaRoutes = [
    AdminRoute(
      id:            'route-agta-recommended',
      label:         'Best Route — Agta Beach',
      badge:         '⭐ Recommended',
      badgeColor:    const Color(0xFF1E3A8A),
      startingPoint: 'Naval Terminal',
      destination:   'Agta Beach',
      destinationId: 'agta_beach',
      routeType:     RouteType.land,
      isHighlighted: true,
      status:        RouteStatus.active,
      dateAdded:     DateTime(2025, 1, 1),
      steps: [
        AdminRouteStep(id: 'ra-001-1', from: 'Naval Terminal', to: 'Almeria',   transportType: TransportType.multicab,   fareAmount: 80, durationMinutes: 30),
        AdminRouteStep(id: 'ra-001-2', from: 'Almeria',        to: 'Agta Beach',transportType: TransportType.tricycle,   fareAmount: 30, durationMinutes: 10),
      ],
    ),
    AdminRoute(
      id:            'route-agta-budget',
      label:         'Budget Route — Agta Beach',
      badge:         '💰 Cheapest',
      badgeColor:    const Color(0xFF059669),
      startingPoint: 'Naval',
      destination:   'Agta Beach',
      destinationId: 'agta_beach',
      routeType:     RouteType.land,
      status:        RouteStatus.active,
      dateAdded:     DateTime(2025, 1, 1),
      steps: [
        AdminRouteStep(id: 'ra-002-1', from: 'Naval', to: 'Agta Beach', transportType: TransportType.habalHabal, fareAmount: 100, durationMinutes: 40),
      ],
    ),
  ];

  static final List<AdminRoute> _higatanganRoutes = [
    AdminRoute(
      id:            'route-higatangan-recommended',
      label:         'Best Route — Higatangan Island',
      badge:         '⭐ Recommended',
      badgeColor:    const Color(0xFF1E3A8A),
      startingPoint: 'Naval Port',
      destination:   'Higatangan Island',
      destinationId: 'higatangan_island',
      routeType:     RouteType.sea,
      isHighlighted: true,
      status:        RouteStatus.active,
      dateAdded:     DateTime(2025, 1, 1),
      steps: [
        AdminRouteStep(id: 'rh-001-1', from: 'Naval Port', to: 'Higatangan Island', transportType: TransportType.boat, fareAmount: 150, durationMinutes: 90, isSeaRoute: true),
      ],
    ),
    AdminRoute(
      id:            'route-higatangan-express',
      label:         'Express Route — Higatangan Island',
      badge:         '⚡ Fastest',
      badgeColor:    const Color(0xFFF59E0B),
      startingPoint: 'Naval Port',
      destination:   'Higatangan Island',
      destinationId: 'higatangan_island',
      routeType:     RouteType.sea,
      status:        RouteStatus.active,
      dateAdded:     DateTime(2025, 1, 1),
      steps: [
        AdminRouteStep(id: 'rh-002-1', from: 'Naval Port', to: 'Higatangan Island', transportType: TransportType.boatCharter, fareAmount: 1000, durationMinutes: 45, isSeaRoute: true),
      ],
    ),
  ];

  static final List<AdminRoute> _otherRoutes = [
    AdminRoute(
      id:            'route-tinago-recommended',
      label:         'Best Route — Tinago Falls',
      badge:         '⭐ Recommended',
      badgeColor:    const Color(0xFF1E3A8A),
      startingPoint: 'Naval',
      destination:   'Tinago Falls',
      destinationId: 'tinago_falls',
      routeType:     RouteType.land,
      isHighlighted: true,
      status:        RouteStatus.active,
      dateAdded:     DateTime(2025, 1, 1),
      steps: [
        AdminRouteStep(id: 'rt-001-1', from: 'Naval',  to: 'Caibiran',    transportType: TransportType.van,        fareAmount: 80,  durationMinutes: 45),
        AdminRouteStep(id: 'rt-001-2', from: 'Caibiran',to: 'Tinago Falls',transportType: TransportType.habalHabal, fareAmount: 100, durationMinutes: 30),
      ],
    ),
    AdminRoute(
      id:            'route-dalutan-recommended',
      label:         'Best Route — Dalutan Island',
      badge:         '⭐ Recommended',
      badgeColor:    const Color(0xFF1E3A8A),
      startingPoint: 'Naval',
      destination:   'Dalutan Island',
      destinationId: 'dalutan_island',
      routeType:     RouteType.mixed,
      isHighlighted: true,
      status:        RouteStatus.active,
      dateAdded:     DateTime(2025, 1, 1),
      steps: [
        AdminRouteStep(id: 'rd-001-1', from: 'Naval',   to: 'Almeria',       transportType: TransportType.multicab,    fareAmount: 70,  durationMinutes: 50),
        AdminRouteStep(id: 'rd-001-2', from: 'Almeria', to: 'Dalutan Island', transportType: TransportType.boatCharter, fareAmount: 500, durationMinutes: 20, isSeaRoute: true),
      ],
    ),
  ];
}
