import 'package:flutter/material.dart';
import '../../../data/transport/transport_route.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminRoute — Multi-step tourism route model
// ─────────────────────────────────────────────────────────────────────────────

enum RouteType { land, sea, mixed }

enum RouteStatus { active, inactive, draft }

class AdminRouteStep {
  AdminRouteStep({
    required this.id,
    required this.from,
    required this.to,
    required this.transportType,
    required this.fareAmount,
    required this.durationMinutes,
    this.notes,
    this.isSeaRoute = false,
  });

  String        id;
  String        from;
  String        to;
  TransportType transportType;
  int           fareAmount;
  int           durationMinutes;
  String?       notes;
  bool          isSeaRoute;

  String get stepSummary => '$from → $to  (${transportType.label}, ₱$fareAmount)';

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  AdminRouteStep copyWith({
    String?        from,
    String?        to,
    TransportType? transportType,
    int?           fareAmount,
    int?           durationMinutes,
    String?        notes,
    bool?          isSeaRoute,
  }) => AdminRouteStep(
    id:              id,
    from:            from            ?? this.from,
    to:              to              ?? this.to,
    transportType:   transportType   ?? this.transportType,
    fareAmount:      fareAmount      ?? this.fareAmount,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    notes:           notes           ?? this.notes,
    isSeaRoute:      isSeaRoute      ?? this.isSeaRoute,
  );
}

class AdminRoute {
  AdminRoute({
    required this.id,
    required this.label,
    required this.startingPoint,
    required this.destination,
    required this.destinationId,
    required this.routeType,
    required this.steps,
    required this.status,
    this.badge,
    this.badgeColor,
    this.isHighlighted = false,
    this.dateAdded,
    this.dateUpdated,
  });

  final String            id;
  String                  label;
  String                  startingPoint;
  String                  destination;
  String                  destinationId;
  RouteType               routeType;
  List<AdminRouteStep>    steps;
  RouteStatus             status;
  String?                 badge;
  Color?                  badgeColor;
  bool                    isHighlighted;
  DateTime?               dateAdded;
  DateTime?               dateUpdated;

  /// Total official fare across all steps.
  int get totalFare => steps.fold(0, (sum, s) => sum + s.fareAmount);

  /// Total travel time in minutes.
  int get totalDurationMinutes =>
      steps.fold(0, (sum, s) => sum + s.durationMinutes);

  String get totalFareLabel => '₱$totalFare';

  String get totalDurationLabel {
    final h = totalDurationMinutes ~/ 60;
    final m = totalDurationMinutes % 60;
    if (h == 0) return '${m}min';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  int get transferCount => steps.length - 1;

  bool get hasSeaTravel => steps.any((s) => s.isSeaRoute);

  String get routeSummary {
    if (steps.isEmpty) return '$startingPoint → $destination';
    final points = <String>[steps.first.from];
    for (final s in steps) { points.add(s.to); }
    return points.join(' → ');
  }

  String get statusLabel {
    switch (status) {
      case RouteStatus.active:   return 'Active';
      case RouteStatus.inactive: return 'Inactive';
      case RouteStatus.draft:    return 'Draft';
    }
  }

  Color get statusColor {
    switch (status) {
      case RouteStatus.active:   return const Color(0xFF10B981);
      case RouteStatus.inactive: return const Color(0xFF94A3B8);
      case RouteStatus.draft:    return const Color(0xFFF59E0B);
    }
  }

  AdminRoute copyWith({
    String?               label,
    String?               startingPoint,
    String?               destination,
    String?               destinationId,
    RouteType?            routeType,
    List<AdminRouteStep>? steps,
    RouteStatus?          status,
    String?               badge,
    Color?                badgeColor,
    bool?                 isHighlighted,
  }) => AdminRoute(
    id:            id,
    label:         label           ?? this.label,
    startingPoint: startingPoint   ?? this.startingPoint,
    destination:   destination     ?? this.destination,
    destinationId: destinationId   ?? this.destinationId,
    routeType:     routeType       ?? this.routeType,
    steps:         steps           ?? this.steps,
    status:        status          ?? this.status,
    badge:         badge           ?? this.badge,
    badgeColor:    badgeColor      ?? this.badgeColor,
    isHighlighted: isHighlighted   ?? this.isHighlighted,
    dateAdded:     dateAdded,
    dateUpdated:   DateTime.now(),
  );
}
