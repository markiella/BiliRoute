import 'transport_route.dart';

// ── Route label / tag enums ────────────────────────────────────────────────────

enum RouteLabel {
  cheapest,
  fastest,
  recommended,
  alternative,
  comfort;

  String get text {
    switch (this) {
      case RouteLabel.cheapest:     return 'Cheapest';
      case RouteLabel.fastest:      return 'Fastest';
      case RouteLabel.recommended:  return 'Recommended';
      case RouteLabel.alternative:  return 'Alternative';
      case RouteLabel.comfort:      return 'Comfort';
    }
  }

  String get emoji {
    switch (this) {
      case RouteLabel.cheapest:     return '💸';
      case RouteLabel.fastest:      return '⚡';
      case RouteLabel.recommended:  return '⭐';
      case RouteLabel.alternative:  return '🔀';
      case RouteLabel.comfort:      return '🛋️';
    }
  }
}

// ── RouteOption model ──────────────────────────────────────────────────────────

/// A selectable route option shown in the Route Selection screen.
///
/// Each option bundles multiple [TransportRoute] segments with a [label],
/// a user-facing [description], and any applicable [tags].
///
/// All fares are official (Tourism Office) — never estimated.
class RouteOption {
  const RouteOption({
    required this.id,
    required this.label,
    required this.description,
    required this.segments,
    required this.tags,
    this.note,
  });

  final String           id;
  final RouteLabel       label;
  final String           description;
  final List<TransportRoute> segments;
  final List<String>     tags;       // e.g. ['Sea Travel', 'Budget Friendly']
  final String?          note;       // optional advisory note

  // ── Computed properties ────────────────────────────────────────────────────

  /// Sum of all segment official fares.
  int get totalFare =>
      segments.fold(0, (sum, r) => sum + r.officialFare);

  /// Sum of all segment durations in minutes.
  int get totalDurationMinutes =>
      segments.fold(0, (sum, r) => sum + r.durationMinutes);

  String get totalFareLabel => '₱$totalFare';

  String get totalDurationLabel {
    final h = totalDurationMinutes ~/ 60;
    final m = totalDurationMinutes % 60;
    if (h == 0) return '${m}min';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  /// True when any segment uses water transport.
  bool get hasSeaTravel =>
      segments.any((r) => r.type.isWater);

  /// All distinct transport types in this route.
  List<TransportType> get transportTypes =>
      segments.map((r) => r.type).toSet().toList();

  /// Step-by-step description: "Naval → Kawayan → Sambawan"
  String get routeSummary {
    final points = <String>[segments.first.origin];
    for (final s in segments) {
      points.add(s.destination);
    }
    return points.join(' → ');
  }
}
