import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ── Transport type enum ────────────────────────────────────────────────────────

enum TransportType {
  multicab,
  van,
  jeepney,
  habalHabal,
  boat,
  boatCharter,
  tricycle,
  bus,
  ferry;

  String get label {
    switch (this) {
      case TransportType.multicab:     return 'Multicab';
      case TransportType.van:          return 'Van';
      case TransportType.jeepney:      return 'Jeepney';
      case TransportType.habalHabal:   return 'Habal-habal';
      case TransportType.boat:         return 'Boat';
      case TransportType.boatCharter:  return 'Boat Charter';
      case TransportType.tricycle:     return 'Tricycle';
      case TransportType.bus:          return 'Bus';
      case TransportType.ferry:        return 'Ferry';
    }
  }

  IconData get icon {
    switch (this) {
      case TransportType.multicab:     return Icons.airport_shuttle_rounded;
      case TransportType.van:          return Icons.directions_car_rounded;
      case TransportType.jeepney:      return Icons.commute_rounded;
      case TransportType.habalHabal:   return Icons.two_wheeler_rounded;
      case TransportType.boat:         return Icons.directions_boat_rounded;
      case TransportType.boatCharter:  return Icons.sailing_rounded;
      case TransportType.tricycle:     return Icons.electric_rickshaw_rounded;
      case TransportType.bus:          return Icons.directions_bus_rounded;
      case TransportType.ferry:        return Icons.directions_boat_filled_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransportType.boat:
      case TransportType.boatCharter:
      case TransportType.ferry:        return AppColors.info;
      case TransportType.habalHabal:
      case TransportType.tricycle:     return AppColors.warning;
      case TransportType.van:          return AppColors.success;
      case TransportType.jeepney:      return AppColors.accentSoft;
      case TransportType.bus:          return const Color(0xFF7C3AED);
      default:                         return AppColors.primary;
    }
  }

  /// Land or water transport.
  bool get isWater =>
      this == TransportType.boat ||
      this == TransportType.boatCharter ||
      this == TransportType.ferry;
}

// ── TransportRoute model ───────────────────────────────────────────────────────

/// Represents a single official transport route with Tourism Office fare data.
///
/// All [officialFare] values are fixed and sourced from the
/// Biliran Tourism Office — NOT estimated or user-defined.
class TransportRoute {
  const TransportRoute({
    required this.origin,
    required this.destination,
    required this.type,
    required this.officialFare,
    required this.durationMinutes,
    this.fareSource   = 'Biliran Tourism Office',
    this.perPerson    = true,
    this.notes,
    this.providerId,
    this.providerName,
    this.scheduleId,
  });

  /// Origin municipality or landmark.
  final String origin;

  /// Destination municipality or landmark.
  final String destination;

  /// Mode of transport.
  final TransportType type;

  /// Fixed official fare in PHP (₱). Never estimated.
  final int officialFare;

  /// Approximate travel time in minutes.
  final int durationMinutes;

  /// Authority that set this fare.
  final String fareSource;

  /// True if fare is per-person; false if per-vehicle/charter.
  final bool perPerson;

  /// Optional clarification note (e.g. "Shared charter, 8–12 pax").
  final String? notes;

  /// Optional provider reference ID.
  final String? providerId;

  /// Optional provider name.
  final String? providerName;

  /// Optional schedule reference ID.
  final String? scheduleId;

  /// Factory constructor parsing backend embedded step JSON.
  factory TransportRoute.fromJson(Map<String, dynamic> json) {
    final modeStr = json['transportMode'] as String? ?? json['type'] as String? ?? 'Multicab';
    final fareTypeStr = json['fareType'] as String? ?? 'per_person';

    return TransportRoute(
      origin: json['fromName'] as String? ?? json['origin'] as String? ?? '',
      destination: json['toName'] as String? ?? json['destination'] as String? ?? '',
      type: _mapTransportType(modeStr),
      officialFare: (json['farePHP'] as num?)?.toInt() ?? (json['officialFare'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      fareSource: json['fareSource'] as String? ?? 'Biliran Tourism Office',
      perPerson: fareTypeStr != 'per_charter',
      notes: json['transferNote'] as String? ?? json['notes'] as String?,
      providerId: json['providerId'] as String?,
      providerName: json['providerName'] as String?,
      scheduleId: json['scheduleId'] as String?,
    );
  }

  static TransportType _mapTransportType(String raw) {
    switch (raw.toLowerCase().replaceAll('-', '').replaceAll(' ', '')) {
      case 'multicab':
        return TransportType.multicab;
      case 'van':
        return TransportType.van;
      case 'jeepney':
        return TransportType.jeepney;
      case 'habalhabal':
        return TransportType.habalHabal;
      case 'boat':
        return TransportType.boat;
      case 'boatcharter':
        return TransportType.boatCharter;
      case 'tricycle':
        return TransportType.tricycle;
      case 'bus':
        return TransportType.bus;
      case 'ferry':
        return TransportType.ferry;
      default:
        return TransportType.multicab;
    }
  }

  // ── Derived helpers ─────────────────────────────────────────────────────────

  String get fareLabel => '₱$officialFare';

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String get routeLabel => '$origin → $destination';

  /// Full official fare display string used in UI.
  String get officialFareDisplay =>
      '₱$officialFare — Official Fare ($fareSource)';
}
