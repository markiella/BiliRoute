import 'route_option.dart';
import 'transport_route.dart';

// MIGRATION PENDING — replaced by API after backend validation
/// Pre-defined official route options for Biliran Island's top destinations.
///
/// All fares sourced from the Biliran Tourism Office (simulated for thesis).
/// Route options differ by transport combination, speed, and comfort level.
class BiliranRouteOptions {
  BiliranRouteOptions._();

  // ══════════════════════════════════════════════════════════════════════════
  // SAMBAWAN ISLAND  (Naval → Kawayan → Sambawan Port → Island)
  // ══════════════════════════════════════════════════════════════════════════

  static const List<RouteOption> sambawanIsland = [

    // Option 1 ── Recommended (balanced cost + comfort)
    RouteOption(
      id:          'sambawan_recommended',
      label:       RouteLabel.recommended,
      description: 'Most popular route among tourists. Good balance of cost and comfort.',
      tags:        ['Sea Travel', 'Island Hopping', 'Popular'],
      note:        'Book charter early — limited slots per day.',
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Kawayan',
          type: TransportType.multicab, officialFare: 55, durationMinutes: 45,
        ),
        TransportRoute(
          origin: 'Kawayan', destination: 'Sambawan Port',
          type: TransportType.habalHabal, officialFare: 60, durationMinutes: 25,
        ),
        TransportRoute(
          origin: 'Sambawan Port', destination: 'Sambawan Island',
          type: TransportType.boatCharter, officialFare: 800, durationMinutes: 30,
          perPerson: false, notes: 'Shared charter 8–12 pax',
        ),
      ],
    ),

    // Option 2 ── Cheapest (public transport only)
    RouteOption(
      id:          'sambawan_cheapest',
      label:       RouteLabel.cheapest,
      description: 'Best for budget travelers. Uses public multicab + shared habal-habal.',
      tags:        ['Sea Travel', 'Budget Friendly'],
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Biliran (town)',
          type: TransportType.jeepney, officialFare: 28, durationMinutes: 15,
        ),
        TransportRoute(
          origin: 'Biliran (town)', destination: 'Kawayan',
          type: TransportType.multicab, officialFare: 30, durationMinutes: 30,
        ),
        TransportRoute(
          origin: 'Kawayan', destination: 'Sambawan Port',
          type: TransportType.habalHabal, officialFare: 60, durationMinutes: 25,
        ),
        TransportRoute(
          origin: 'Sambawan Port', destination: 'Sambawan Island',
          type: TransportType.boatCharter, officialFare: 800, durationMinutes: 30,
          perPerson: false, notes: 'Shared charter 8–12 pax',
        ),
      ],
    ),

    // Option 3 ── Fastest (van + private boat)
    RouteOption(
      id:          'sambawan_fastest',
      label:       RouteLabel.fastest,
      description: 'Fastest route available. Van to Kawayan, private boat to island.',
      tags:        ['Sea Travel', 'Express', 'Comfort'],
      note:        'Includes sea travel. Higher fare for private charter.',
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Kawayan',
          type: TransportType.van, officialFare: 100, durationMinutes: 35,
          notes: 'Van for hire, seats 8',
        ),
        TransportRoute(
          origin: 'Kawayan', destination: 'Sambawan Port',
          type: TransportType.habalHabal, officialFare: 60, durationMinutes: 25,
        ),
        TransportRoute(
          origin: 'Sambawan Port', destination: 'Sambawan Island',
          type: TransportType.boatCharter, officialFare: 1500, durationMinutes: 20,
          perPerson: false, notes: 'Private charter, faster boat',
        ),
      ],
    ),

    // Option 4 ── Alternative (with Higatangan Island stopover)
    RouteOption(
      id:          'sambawan_alternative',
      label:       RouteLabel.alternative,
      description: 'Island-hopping route. Stop at Higatangan before Sambawan.',
      tags:        ['Sea Travel', 'Island Hopping', 'Scenic'],
      note:        'Add 2–3 hours for Higatangan stop.',
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Kawayan',
          type: TransportType.multicab, officialFare: 55, durationMinutes: 45,
        ),
        TransportRoute(
          origin: 'Kawayan', destination: 'Higatangan Island',
          type: TransportType.boat, officialFare: 200, durationMinutes: 45,
          notes: 'Scheduled boat',
        ),
        TransportRoute(
          origin: 'Higatangan Island', destination: 'Sambawan Island',
          type: TransportType.boatCharter, officialFare: 600, durationMinutes: 25,
          perPerson: false, notes: 'Island-to-island charter',
        ),
      ],
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // AGTA BEACH  (Naval → Almeria → Agta Beach)
  // ══════════════════════════════════════════════════════════════════════════

  static const List<RouteOption> agtaBeach = [

    RouteOption(
      id:          'agta_recommended',
      label:       RouteLabel.recommended,
      description: 'Direct habal-habal from Naval. Scenic coastal road.',
      tags:        ['Land Travel', 'Direct Route'],
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Agta Beach',
          type: TransportType.habalHabal, officialFare: 100, durationMinutes: 40,
          notes: 'Via Almeria coastal road',
        ),
      ],
    ),

    RouteOption(
      id:          'agta_cheapest',
      label:       RouteLabel.cheapest,
      description: 'Multicab to Almeria then short habal-habal to beach.',
      tags:        ['Land Travel', 'Budget Friendly'],
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Almeria',
          type: TransportType.multicab, officialFare: 70, durationMinutes: 50,
        ),
        TransportRoute(
          origin: 'Almeria', destination: 'Agta Beach',
          type: TransportType.habalHabal, officialFare: 30, durationMinutes: 15,
        ),
      ],
    ),

    RouteOption(
      id:          'agta_comfort',
      label:       RouteLabel.comfort,
      description: 'Van for hire — comfortable, air-conditioned, direct.',
      tags:        ['Land Travel', 'Comfort', 'Group Friendly'],
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Agta Beach',
          type: TransportType.van, officialFare: 200, durationMinutes: 35,
          perPerson: false, notes: 'Van for hire, seats 8',
        ),
      ],
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // TINAGO FALLS  (Naval → Almeria → Tinago Falls)
  // ══════════════════════════════════════════════════════════════════════════

  static const List<RouteOption> tinagoFalls = [

    RouteOption(
      id:          'tinago_recommended',
      label:       RouteLabel.recommended,
      description: 'Direct habal-habal from Naval to falls. Most convenient option.',
      tags:        ['Land Travel', 'Direct Route'],
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Tinago Falls',
          type: TransportType.habalHabal, officialFare: 150, durationMinutes: 60,
          notes: 'Includes rough trail section',
        ),
      ],
    ),

    RouteOption(
      id:          'tinago_cheapest',
      label:       RouteLabel.cheapest,
      description: 'Multicab to Almeria then habal-habal to falls. Budget option.',
      tags:        ['Land Travel', 'Budget Friendly'],
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Almeria',
          type: TransportType.multicab, officialFare: 70, durationMinutes: 50,
        ),
        TransportRoute(
          origin: 'Almeria', destination: 'Tinago Falls',
          type: TransportType.habalHabal, officialFare: 80, durationMinutes: 35,
        ),
      ],
    ),

    RouteOption(
      id:          'tinago_comfort',
      label:       RouteLabel.comfort,
      description: 'Van for hire directly to falls. Best for groups.',
      tags:        ['Land Travel', 'Comfort', 'Group Friendly'],
      segments: [
        TransportRoute(
          origin: 'Naval', destination: 'Tinago Falls',
          type: TransportType.van, officialFare: 350, durationMinutes: 50,
          perPerson: false, notes: 'Van for hire',
        ),
      ],
    ),
  ];

  // ── Destination lookup ─────────────────────────────────────────────────────

  /// Returns route options for a given destination name.
  static List<RouteOption> forDestination(String destination) {
    final d = destination.toLowerCase();
    if (d.contains('sambawan'))   return sambawanIsland;
    if (d.contains('agta'))       return agtaBeach;
    if (d.contains('tinago'))     return tinagoFalls;
    // Default fallback — generic Sambawan options
    return sambawanIsland;
  }
}
