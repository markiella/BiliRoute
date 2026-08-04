import 'package:flutter/material.dart';
import '../transport/transport_route.dart';

// ── Provider type enum ─────────────────────────────────────────────────────────

enum ProviderType {
  driver,
  boatOperator,
  guide,
  tricycleDriver,
  vanDriver;

  String get label {
    switch (this) {
      case ProviderType.driver:         return 'Driver';
      case ProviderType.boatOperator:   return 'Boat Operator';
      case ProviderType.guide:          return 'Tour Guide';
      case ProviderType.tricycleDriver: return 'Tricycle Driver';
      case ProviderType.vanDriver:      return 'Van Driver';
    }
  }

  IconData get icon {
    switch (this) {
      case ProviderType.driver:         return Icons.airport_shuttle_rounded;
      case ProviderType.boatOperator:   return Icons.sailing_rounded;
      case ProviderType.guide:          return Icons.person_pin_circle_rounded;
      case ProviderType.tricycleDriver: return Icons.electric_rickshaw_rounded;
      case ProviderType.vanDriver:      return Icons.directions_car_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ProviderType.boatOperator:   return const Color(0xFF0EA5E9); // sky blue
      case ProviderType.guide:          return const Color(0xFF10B981); // green
      case ProviderType.tricycleDriver: return const Color(0xFFF59E0B); // amber
      case ProviderType.vanDriver:      return const Color(0xFF8B5CF6); // purple
      default:                          return const Color(0xFF3B82F6); // blue
    }
  }

  /// True if this type handles water transport.
  bool get isWater => this == ProviderType.boatOperator;
}

// ── ServiceProvider model ──────────────────────────────────────────────────────

/// A verified service provider linked to a specific transport route segment.
///
/// All providers in the official dataset must have [isVerified] == true.
/// Non-verified providers are excluded from the matching logic.
class ServiceProvider {
  const ServiceProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.contactNumber,
    required this.routeSegment,
    required this.compatibleTransportTypes,
    this.registrationCode,
    this.availability,
    this.isVerified = true,
    this.rating,
    this.note,
  });

  /// Unique identifier.
  final String id;

  /// Full name of provider / business.
  final String name;

  /// Provider category.
  final ProviderType type;

  /// Phone number — displayed and used for tel: URL.
  final String contactNumber;

  /// Route segment this provider serves, e.g. "Naval → Kawayan Port".
  final String routeSegment;

  /// Transport types this provider can service.
  final List<TransportType> compatibleTransportTypes;

  /// Tourism Office registration code (optional display).
  final String? registrationCode;

  /// Optional availability note, e.g. "Daily 6 AM – 5 PM".
  final String? availability;

  /// Only verified providers are displayed in the UI.
  final bool isVerified;

  /// Average rating out of 5 (optional).
  final double? rating;

  /// Extra advisory note.
  final String? note;

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Returns true when the provider handles the given transport type.
  bool handles(TransportType t) => compatibleTransportTypes.contains(t);

  /// Returns true when the provider's route segment matches origin → destination.
  bool matchesSegment(String origin, String destination) {
    final key = '$origin → $destination'.toLowerCase();
    return routeSegment.toLowerCase() == key;
  }

  /// tel: URI for launching the phone dialer.
  String get dialUri => 'tel:${contactNumber.replaceAll(RegExp(r'\s'), '')}';

  /// Formatted display — e.g. "📞 09123 456 789".
  String get formattedContact => '📞 $contactNumber';
}
