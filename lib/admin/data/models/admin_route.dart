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

  factory AdminRouteStep.fromBackendJson(Map<String, dynamic> json) {
    final modeStr = json['transportMode'] as String? ?? 'multicab';
    TransportType type;
    switch (modeStr.toLowerCase()) {
      case 'van': type = TransportType.van; break;
      case 'boat': type = TransportType.boat; break;
      case 'boatcharter':
      case 'boat_charter': type = TransportType.boatCharter; break;
      case 'habalhabal':
      case 'habal_habal': type = TransportType.habalHabal; break;
      case 'tricycle': type = TransportType.tricycle; break;
      case 'multicab':
      default: type = TransportType.multicab; break;
    }

    return AdminRouteStep(
      id: json['_id'] as String? ?? 'step_${json['sequenceOrder'] ?? 1}',
      from: json['origin'] as String? ?? '',
      to: json['destination'] as String? ?? '',
      transportType: type,
      fareAmount: (json['farePHP'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      isSeaRoute: json['isSeaSegment'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toBackendJson(int sequenceOrder) {
    return {
      'sequenceOrder': sequenceOrder,
      'origin': from,
      'destination': to,
      'transportMode': transportType.name,
      'durationMinutes': durationMinutes,
      'farePHP': fareAmount,
      'notes': notes,
      'isSeaSegment': isSeaRoute,
    };
  }
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

  factory AdminRoute.fromBackendJson(Map<String, dynamic> json) {
    final stepsList = json['steps'] as List?;
    final steps = <AdminRouteStep>[];
    if (stepsList != null) {
      for (final s in stepsList) {
        if (s is Map<String, dynamic>) {
          steps.add(AdminRouteStep.fromBackendJson(s));
        }
      }
    }

    final routeTypeStr = json['routeType'] as String? ?? 'Mixed';
    RouteType routeType;
    switch (routeTypeStr.toLowerCase()) {
      case 'land': routeType = RouteType.land; break;
      case 'sea': routeType = RouteType.sea; break;
      case 'mixed':
      default: routeType = RouteType.mixed; break;
    }

    final isActive = json['isActive'] as bool? ?? true;
    final destId = json['destinationId'] is Map
        ? (json['destinationId']['_id'] as String? ?? '')
        : (json['destinationId'] as String? ?? '');
    final destName = json['destinationName'] as String? ??
        (json['destinationId'] is Map ? (json['destinationId']['name'] as String? ?? '') : '');

    return AdminRoute(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      startingPoint: json['originName'] as String? ?? '',
      destination: destName,
      destinationId: destId,
      routeType: routeType,
      steps: steps,
      status: isActive ? RouteStatus.active : RouteStatus.inactive,
      badge: json['badge'] as String?,
      dateAdded: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      dateUpdated: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toBackendJson() {
    final mappedSteps = steps.asMap().entries.map((entry) {
      return entry.value.toBackendJson(entry.key + 1);
    }).toList();

    return {
      'label': label,
      'originName': startingPoint,
      'destinationId': destinationId,
      'destinationName': destination,
      'routeType': routeType.name[0].toUpperCase() + routeType.name.substring(1),
      'steps': mappedSteps,
      'isActive': status == RouteStatus.active,
      if (badge != null) 'badge': badge,
    };
  }
}
