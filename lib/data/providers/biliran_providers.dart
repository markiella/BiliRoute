import '../transport/transport_route.dart';
import 'service_provider.dart';

// ── Official Biliran Provider Dataset ─────────────────────────────────────────

/// Pre-loaded Tourism Office verified provider registry.
///
/// Each provider is linked to a route segment and transport type.
/// Only [isVerified == true] providers should be displayed.
class BiliranProviders {
  BiliranProviders._();

  // ── Full dataset ─────────────────────────────────────────────────────────────

  static const List<ServiceProvider> _all = [

    // ── Naval ↔ Kawayan (Multicab / Van) ──────────────────────────────────────
    ServiceProvider(
      id:                       'sp-001',
      name:                     'Juan dela Cruz Transport',
      type:                     ProviderType.driver,
      contactNumber:            '09171234567',
      routeSegment:             'Naval → Kawayan Port',
      compatibleTransportTypes: [TransportType.multicab, TransportType.van],
      registrationCode:         'BTO-DRV-0001',
      availability:             'Daily 5:00 AM – 8:00 PM',
      rating:                   4.8,
    ),
    ServiceProvider(
      id:                       'sp-002',
      name:                     'Maria Santos Van Service',
      type:                     ProviderType.vanDriver,
      contactNumber:            '09209876543',
      routeSegment:             'Naval → Kawayan Port',
      compatibleTransportTypes: [TransportType.van, TransportType.multicab],
      registrationCode:         'BTO-DRV-0002',
      availability:             'Daily 6:00 AM – 7:00 PM',
      rating:                   4.7,
    ),
    ServiceProvider(
      id:                       'sp-003',
      name:                     'Reyes Multicab Services',
      type:                     ProviderType.driver,
      contactNumber:            '09351122334',
      routeSegment:             'Naval → Kawayan Port',
      compatibleTransportTypes: [TransportType.multicab],
      registrationCode:         'BTO-DRV-0003',
      availability:             'Daily 5:30 AM – 6:00 PM',
      rating:                   4.6,
    ),

    // ── Kawayan ↔ Sambawan (Boat Charter) ─────────────────────────────────────
    ServiceProvider(
      id:                       'sp-004',
      name:                     'Pedro Boat Services',
      type:                     ProviderType.boatOperator,
      contactNumber:            '09175556677',
      routeSegment:             'Kawayan Port → Sambawan Island',
      compatibleTransportTypes: [TransportType.boatCharter, TransportType.boat],
      registrationCode:         'BTO-BOT-0001',
      availability:             'Daily 6:00 AM – 3:00 PM (weather permitting)',
      rating:                   4.9,
      note:                     'Book at least 1 day in advance',
    ),
    ServiceProvider(
      id:                       'sp-005',
      name:                     'Lito\'s Sea Express',
      type:                     ProviderType.boatOperator,
      contactNumber:            '09334445566',
      routeSegment:             'Kawayan Port → Sambawan Island',
      compatibleTransportTypes: [TransportType.boatCharter, TransportType.boat],
      registrationCode:         'BTO-BOT-0002',
      availability:             'Mon–Sat 7:00 AM – 2:00 PM',
      rating:                   4.7,
      note:                     'Capacity: 8–12 passengers',
    ),

    // ── Sambawan Return ───────────────────────────────────────────────────────
    ServiceProvider(
      id:                       'sp-006',
      name:                     'Pedro Boat Services',
      type:                     ProviderType.boatOperator,
      contactNumber:            '09175556677',
      routeSegment:             'Sambawan Island → Kawayan Port',
      compatibleTransportTypes: [TransportType.boatCharter, TransportType.boat],
      registrationCode:         'BTO-BOT-0001',
      availability:             'Return by 3:00 PM latest',
      rating:                   4.9,
    ),

    // ── Kawayan ↔ Habal-habal segments ────────────────────────────────────────
    ServiceProvider(
      id:                       'sp-007',
      name:                     'Bong Habal-habal Riders',
      type:                     ProviderType.driver,
      contactNumber:            '09461234000',
      routeSegment:             'Kawayan Port → Sambawan Port',
      compatibleTransportTypes: [TransportType.habalHabal],
      registrationCode:         'BTO-DRV-0010',
      availability:             'Daily 6:00 AM – 5:00 PM',
      rating:                   4.5,
    ),
    ServiceProvider(
      id:                       'sp-008',
      name:                     'Ramon Habal Riders',
      type:                     ProviderType.driver,
      contactNumber:            '09278889900',
      routeSegment:             'Sambawan Port → Kawayan',
      compatibleTransportTypes: [TransportType.habalHabal],
      registrationCode:         'BTO-DRV-0011',
      availability:             'Daily 7:00 AM – 5:00 PM',
      rating:                   4.6,
    ),

    // ── Naval ↔ Higatangan (Boat) ─────────────────────────────────────────────
    ServiceProvider(
      id:                       'sp-009',
      name:                     'Higatangan Ferry Coop',
      type:                     ProviderType.boatOperator,
      contactNumber:            '09196667788',
      routeSegment:             'Naval Port → Higatangan Island',
      compatibleTransportTypes: [TransportType.boat, TransportType.ferry],
      registrationCode:         'BTO-BOT-0003',
      availability:             'Mon/Wed/Fri 8:00 AM',
      rating:                   4.6,
      note:                     'Public ferry — fixed schedule',
    ),
    ServiceProvider(
      id:                       'sp-010',
      name:                     'Bato Boat Charter Co.',
      type:                     ProviderType.boatOperator,
      contactNumber:            '09223334455',
      routeSegment:             'Naval Port → Higatangan Island',
      compatibleTransportTypes: [TransportType.boatCharter],
      registrationCode:         'BTO-BOT-0004',
      availability:             'Daily on request',
      rating:                   4.8,
    ),

    // ── Almeria area ──────────────────────────────────────────────────────────
    ServiceProvider(
      id:                       'sp-011',
      name:                     'Almeria Tricycle Association',
      type:                     ProviderType.tricycleDriver,
      contactNumber:            '09361112223',
      routeSegment:             'Almeria → Ulan-ulan Falls',
      compatibleTransportTypes: [TransportType.tricycle, TransportType.habalHabal],
      registrationCode:         'BTO-DRV-0020',
      availability:             'Daily 6:00 AM – 5:00 PM',
      rating:                   4.5,
    ),
    ServiceProvider(
      id:                       'sp-012',
      name:                     'Danny\'s Tricycle Services',
      type:                     ProviderType.tricycleDriver,
      contactNumber:            '09481234500',
      routeSegment:             'Almeria → Ulan-ulan Falls',
      compatibleTransportTypes: [TransportType.tricycle],
      registrationCode:         'BTO-DRV-0021',
      availability:             'Daily 7:00 AM – 4:00 PM',
      rating:                   4.4,
    ),

    // ── Tour guides ───────────────────────────────────────────────────────────
    ServiceProvider(
      id:                       'sp-013',
      name:                     'Tourism Office Guide — Carlo',
      type:                     ProviderType.guide,
      contactNumber:            '09501234789',
      routeSegment:             'Sambawan Island',
      compatibleTransportTypes: [],
      registrationCode:         'BTO-GDE-0001',
      availability:             'Daily, pre-book required',
      rating:                   5.0,
      note:                     'Official accredited guide — Biliran Tourism Office',
    ),
    ServiceProvider(
      id:                       'sp-014',
      name:                     'Tourism Office Guide — Ana',
      type:                     ProviderType.guide,
      contactNumber:            '09619876000',
      routeSegment:             'Higatangan Island',
      compatibleTransportTypes: [],
      registrationCode:         'BTO-GDE-0002',
      availability:             'Mon–Sat, pre-book required',
      rating:                   4.9,
    ),

    // ── Naval internal ────────────────────────────────────────────────────────
    ServiceProvider(
      id:                       'sp-015',
      name:                     'Naval Port Multicab Terminal',
      type:                     ProviderType.driver,
      contactNumber:            '09321234560',
      routeSegment:             'Naval → Almeria',
      compatibleTransportTypes: [TransportType.multicab, TransportType.van],
      registrationCode:         'BTO-DRV-0030',
      availability:             'Daily 5:00 AM – 8:00 PM',
      rating:                   4.5,
    ),
    ServiceProvider(
      id:                       'sp-016',
      name:                     'Almeria → Naval Multicab Line',
      type:                     ProviderType.driver,
      contactNumber:            '09432234567',
      routeSegment:             'Kawayan → Naval',
      compatibleTransportTypes: [TransportType.multicab],
      registrationCode:         'BTO-DRV-0031',
      availability:             'Daily 5:30 AM – 7:00 PM',
      rating:                   4.4,
    ),
  ];

  // ── Public API ────────────────────────────────────────────────────────────────

  /// All verified providers only.
  static List<ServiceProvider> get verified =>
      _all.where((p) => p.isVerified).toList();

  /// Find providers for a specific route segment and transport type.
  /// Returns at most [limit] providers (default: 2).
  static List<ServiceProvider> forSegment({
    required String origin,
    required String destination,
    required TransportType type,
    int limit = 2,
  }) {
    final key = '$origin → $destination'.toLowerCase();
    return verified
        .where((p) =>
            p.routeSegment.toLowerCase() == key && p.handles(type))
        .take(limit)
        .toList();
  }

  /// Get all providers attached to every segment of a route option's segments.
  /// Returns a map of segment label → providers list.
  static Map<String, List<ServiceProvider>> forSegments(
    List<dynamic> segments, // List<TransportRoute>
  ) {
    final result = <String, List<ServiceProvider>>{};
    for (final seg in segments) {
      final key = seg.routeLabel as String;
      final providers = forSegment(
        origin:      seg.origin as String,
        destination: seg.destination as String,
        type:        seg.type as TransportType,
      );
      if (providers.isNotEmpty) result[key] = providers;
    }
    return result;
  }

  /// All providers by type.
  static List<ServiceProvider> byType(ProviderType type) =>
      verified.where((p) => p.type == type).toList();
}
