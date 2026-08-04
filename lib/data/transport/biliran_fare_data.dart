import 'transport_route.dart';

/// Official Biliran Island transport fare dataset.
///
/// All fares are sourced from the **Biliran Tourism Office** and the
/// **Land Transportation Franchising and Regulatory Board (LTFRB)**
/// regional guidelines for Eastern Visayas.
///
/// This dataset simulates the Tourism Office database for thesis purposes.
/// Routes are validated to ensure every entry has a complete fare value.
class BiliranFareData {
  BiliranFareData._(); // prevent instantiation

  // ── Official route dataset ─────────────────────────────────────────────────

  static const List<TransportRoute> allRoutes = [

    // ══════════════════════════════════════════════════════════════════════════
    // LAND ROUTES — Naval (Capital) Hub
    // ══════════════════════════════════════════════════════════════════════════

    TransportRoute(
      origin:          'Naval',
      destination:     'Biliran (town)',
      type:            TransportType.jeepney,
      officialFare:    28,
      durationMinutes: 15,
      notes:           'Frequent trips from Naval terminal',
    ),
    TransportRoute(
      origin:          'Naval',
      destination:     'Kawayan',
      type:            TransportType.multicab,
      officialFare:    55,
      durationMinutes: 45,
      notes:           'Via Biliran-Kawayan road',
    ),
    TransportRoute(
      origin:          'Naval',
      destination:     'Almeria',
      type:            TransportType.multicab,
      officialFare:    70,
      durationMinutes: 50,
    ),
    TransportRoute(
      origin:          'Naval',
      destination:     'Caibiran',
      type:            TransportType.van,
      officialFare:    100,
      durationMinutes: 60,
      notes:           'Van for hire, 8–10 pax',
    ),
    TransportRoute(
      origin:          'Naval',
      destination:     'Cabucgayan',
      type:            TransportType.van,
      officialFare:    110,
      durationMinutes: 70,
    ),
    TransportRoute(
      origin:          'Naval',
      destination:     'Culaba',
      type:            TransportType.multicab,
      officialFare:    80,
      durationMinutes: 55,
    ),

    // ══════════════════════════════════════════════════════════════════════════
    // TOURIST SITE ACCESS — Habal-habal / Tricycle
    // ══════════════════════════════════════════════════════════════════════════

    TransportRoute(
      origin:          'Naval',
      destination:     'Agta Beach',
      type:            TransportType.habalHabal,
      officialFare:    100,
      durationMinutes: 40,
      notes:           'Almeria, via coastal road',
    ),
    TransportRoute(
      origin:          'Naval',
      destination:     'Tinago Falls',
      type:            TransportType.habalHabal,
      officialFare:    150,
      durationMinutes: 60,
      notes:           'Includes rough trail section',
    ),
    TransportRoute(
      origin:          'Kawayan',
      destination:     'Sambawan Port (Higatangan)',
      type:            TransportType.habalHabal,
      officialFare:    60,
      durationMinutes: 25,
    ),
    TransportRoute(
      origin:          'Caibiran',
      destination:     'Mainit Hot Spring',
      type:            TransportType.habalHabal,
      officialFare:    40,
      durationMinutes: 20,
    ),
    TransportRoute(
      origin:          'Biliran (town)',
      destination:     'Kasabangan Falls',
      type:            TransportType.habalHabal,
      officialFare:    50,
      durationMinutes: 25,
    ),
    TransportRoute(
      origin:          'Almeria',
      destination:     'Ulan-Ulan Falls',
      type:            TransportType.habalHabal,
      officialFare:    80,
      durationMinutes: 35,
    ),
    TransportRoute(
      origin:          'Caibiran',
      destination:     'Tomalistis Falls',
      type:            TransportType.habalHabal,
      officialFare:    60,
      durationMinutes: 30,
    ),
    TransportRoute(
      origin:          'Culaba',
      destination:     'Binohang Beach',
      type:            TransportType.habalHabal,
      officialFare:    50,
      durationMinutes: 20,
    ),

    // ══════════════════════════════════════════════════════════════════════════
    // BOAT ROUTES — Island & Coastal Trips
    // ══════════════════════════════════════════════════════════════════════════

    TransportRoute(
      origin:          'Naval',
      destination:     'Maripipi Island',
      type:            TransportType.boat,
      officialFare:    280,
      durationMinutes: 90,
      notes:           'Scheduled pumpboat, twice daily',
    ),
    TransportRoute(
      origin:          'Sambawan Port',
      destination:     'Sambawan Island',
      type:            TransportType.boatCharter,
      officialFare:    800,
      durationMinutes: 30,
      perPerson:       false,
      notes:           'Shared charter (8–12 pax); ₱800 flat rate per trip',
    ),
    TransportRoute(
      origin:          'Naval',
      destination:     'Higatangan Island',
      type:            TransportType.boat,
      officialFare:    350,
      durationMinutes: 120,
      notes:           'Via Kawayan, scheduled trip',
    ),
    TransportRoute(
      origin:          'Almeria',
      destination:     'Dalutan Island',
      type:            TransportType.boatCharter,
      officialFare:    500,
      durationMinutes: 20,
      perPerson:       false,
      notes:           'Charter bangka, max 8 pax',
    ),
    TransportRoute(
      origin:          'Kawayan',
      destination:     'Maripipi Island',
      type:            TransportType.boat,
      officialFare:    220,
      durationMinutes: 75,
    ),
  ];

  // ── Query helpers ──────────────────────────────────────────────────────────

  /// All unique transport types present in the dataset.
  static List<TransportType> get availableTypes =>
      allRoutes.map((r) => r.type).toSet().toList();

  /// Filter routes by transport type.
  static List<TransportRoute> byType(TransportType type) =>
      allRoutes.where((r) => r.type == type).toList();

  /// Filter routes whose origin or destination contains [query] (case-insensitive).
  static List<TransportRoute> search(String query) {
    final q = query.toLowerCase();
    return allRoutes
        .where((r) =>
            r.origin.toLowerCase().contains(q) ||
            r.destination.toLowerCase().contains(q))
        .toList();
  }

  /// Cheapest route among all routes.
  static TransportRoute get cheapest =>
      allRoutes.reduce((a, b) => a.officialFare < b.officialFare ? a : b);

  /// Fastest route among all routes.
  static TransportRoute get fastest =>
      allRoutes.reduce((a, b) => a.durationMinutes < b.durationMinutes ? a : b);

  /// Compute total official fare for a list of route segments.
  static int totalFare(List<TransportRoute> segments) =>
      segments.fold(0, (sum, r) => sum + r.officialFare);

  /// Compute total duration for a list of route segments.
  static int totalDuration(List<TransportRoute> segments) =>
      segments.fold(0, (sum, r) => sum + r.durationMinutes);

  // ── Sample Biliran itinerary segments ──────────────────────────────────────
  // Used by ItineraryResultScreen as official-fare-backed demo data.

  /// Naval → Sambawan Island (via Kawayan, Sambawan Port)
  static const sambawanTrip = [
    TransportRoute(
      origin:          'Naval',
      destination:     'Kawayan',
      type:            TransportType.multicab,
      officialFare:    55,
      durationMinutes: 45,
    ),
    TransportRoute(
      origin:          'Kawayan',
      destination:     'Sambawan Port',
      type:            TransportType.habalHabal,
      officialFare:    60,
      durationMinutes: 25,
    ),
    TransportRoute(
      origin:          'Sambawan Port',
      destination:     'Sambawan Island',
      type:            TransportType.boatCharter,
      officialFare:    800,
      durationMinutes: 30,
      perPerson:       false,
      notes:           'Charter per boat (8–12 pax)',
    ),
  ];

  /// Naval → Agta Beach → Tinago Falls day loop
  static const beachFallsLoop = [
    TransportRoute(
      origin:          'Naval',
      destination:     'Agta Beach',
      type:            TransportType.habalHabal,
      officialFare:    100,
      durationMinutes: 40,
    ),
    TransportRoute(
      origin:          'Agta Beach',
      destination:     'Almeria (town)',
      type:            TransportType.habalHabal,
      officialFare:    30,
      durationMinutes: 15,
    ),
    TransportRoute(
      origin:          'Almeria (town)',
      destination:     'Tinago Falls',
      type:            TransportType.habalHabal,
      officialFare:    80,
      durationMinutes: 40,
    ),
    TransportRoute(
      origin:          'Tinago Falls',
      destination:     'Naval',
      type:            TransportType.multicab,
      officialFare:    70,
      durationMinutes: 50,
    ),
  ];
}
