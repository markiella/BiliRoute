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
    this.recommendationScore,
    this.scoreBreakdown,
  });

  final String           id;
  final RouteLabel       label;
  final String           description;
  final List<TransportRoute> segments;
  final List<String>     tags;       // e.g. ['Sea Travel', 'Budget Friendly']
  final String?          note;       // optional advisory note
  final double?          recommendationScore; // Engine score from backend (e.g. 92.5)
  final Map<String, dynamic>? scoreBreakdown; // Score breakdown components

  /// Factory constructor parsing backend Route document JSON.
  factory RouteOption.fromJson(Map<String, dynamic> json) {
    final rawLabel = json['label'] as String? ?? 'Recommended';
    final labelEnum = _mapRouteLabel(rawLabel);

    final stepsList = json['steps'] as List?;
    final segmentsList = <TransportRoute>[];

    if (stepsList != null) {
      for (final step in stepsList) {
        if (step is Map<String, dynamic>) {
          segmentsList.add(TransportRoute.fromJson(step));
        }
      }
    }

    final tagsList = json['tags'] as List?;
    final tags = tagsList?.map((e) => e.toString()).toList() ?? [];

    return RouteOption(
      id: json['routeId'] as String? ?? json['_id'] as String? ?? '',
      label: labelEnum,
      description: json['availabilityNote'] as String? ?? json['note'] as String? ?? json['badge'] as String? ?? '',
      segments: segmentsList,
      tags: tags,
      note: json['note'] as String?,
      recommendationScore: (json['recommendationScore'] as num?)?.toDouble(),
      scoreBreakdown: json['scoreBreakdown'] as Map<String, dynamic>?,
    );
  }

  static RouteLabel _mapRouteLabel(String raw) {
    switch (raw.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_')) {
      case 'budget_friendly':
      case 'cheapest':
        return RouteLabel.cheapest;
      case 'fastest':
        return RouteLabel.fastest;
      case 'alternative':
        return RouteLabel.alternative;
      case 'comfort':
        return RouteLabel.comfort;
      case 'recommended':
      default:
        return RouteLabel.recommended;
    }
  }

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
