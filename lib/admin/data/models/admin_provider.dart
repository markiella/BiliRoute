import 'package:flutter/material.dart';
import '../../../data/transport/transport_route.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminProvider — Extended service provider with verification workflow
// ─────────────────────────────────────────────────────────────────────────────

enum ProviderStatus { pending, verified, suspended }

class AdminProvider {
  AdminProvider({
    required this.id,
    required this.name,
    required this.providerType,
    required this.contactNumber,
    required this.municipality,
    required this.serviceArea,
    required this.compatibleTransportTypes,
    required this.status,
    this.address,
    this.availableDays,
    this.operatingHours,
    this.maxCapacity,
    this.serviceNotes,
    this.registrationCode,
    this.availability,
    this.rating,
    this.profileImageAsset,
    this.vehicleImageAsset,
    this.verifiedBy,
    this.verifiedAt,
    this.dateAdded,
    this.dateUpdated,
  });

  final String                  id;
  String                        name;
  ProviderCategory              providerType;
  String                        contactNumber;
  String                        municipality;
  String                        serviceArea;
  List<TransportType>           compatibleTransportTypes;
  ProviderStatus                status;
  String?                       address;
  List<String>?                 availableDays;
  String?                       operatingHours;
  int?                          maxCapacity;
  String?                       serviceNotes;
  String?                       registrationCode;
  String?                       availability;
  double?                       rating;
  String?                       profileImageAsset;
  String?                       vehicleImageAsset;
  String?                       verifiedBy;
  DateTime?                     verifiedAt;
  DateTime?                     dateAdded;
  DateTime?                     dateUpdated;

  bool get isVerified => status == ProviderStatus.verified;

  String get statusLabel {
    switch (status) {
      case ProviderStatus.pending:   return 'Pending';
      case ProviderStatus.verified:  return 'Verified';
      case ProviderStatus.suspended: return 'Suspended';
    }
  }

  Color get statusColor {
    switch (status) {
      case ProviderStatus.pending:   return const Color(0xFFF59E0B);
      case ProviderStatus.verified:  return const Color(0xFF10B981);
      case ProviderStatus.suspended: return const Color(0xFFEF4444);
    }
  }

  String get formattedContact => '📞 $contactNumber';
  String get dialUri => 'tel:${contactNumber.replaceAll(RegExp(r'\s'), '')}';

  AdminProvider copyWith({
    String?               name,
    ProviderCategory?     providerType,
    String?               contactNumber,
    String?               municipality,
    String?               serviceArea,
    List<TransportType>?  compatibleTransportTypes,
    ProviderStatus?       status,
    String?               address,
    List<String>?         availableDays,
    String?               operatingHours,
    int?                  maxCapacity,
    String?               serviceNotes,
    String?               registrationCode,
    String?               availability,
    double?               rating,
    String?               profileImageAsset,
    String?               vehicleImageAsset,
    String?               verifiedBy,
    DateTime?             verifiedAt,
  }) => AdminProvider(
    id:                       id,
    name:                     name                     ?? this.name,
    providerType:             providerType             ?? this.providerType,
    contactNumber:            contactNumber            ?? this.contactNumber,
    municipality:             municipality             ?? this.municipality,
    serviceArea:              serviceArea              ?? this.serviceArea,
    compatibleTransportTypes: compatibleTransportTypes ?? this.compatibleTransportTypes,
    status:                   status                   ?? this.status,
    address:                  address                  ?? this.address,
    availableDays:            availableDays            ?? this.availableDays,
    operatingHours:           operatingHours           ?? this.operatingHours,
    maxCapacity:              maxCapacity              ?? this.maxCapacity,
    serviceNotes:             serviceNotes             ?? this.serviceNotes,
    registrationCode:         registrationCode         ?? this.registrationCode,
    availability:             availability             ?? this.availability,
    rating:                   rating                   ?? this.rating,
    profileImageAsset:        profileImageAsset        ?? this.profileImageAsset,
    vehicleImageAsset:        vehicleImageAsset        ?? this.vehicleImageAsset,
    verifiedBy:               verifiedBy               ?? this.verifiedBy,
    verifiedAt:               verifiedAt               ?? this.verifiedAt,
    dateAdded:                dateAdded,
    dateUpdated:              DateTime.now(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider Category (extended from ProviderType)
// ─────────────────────────────────────────────────────────────────────────────

enum ProviderCategory {
  boatOperator,
  vanOperator,
  habalHabal,
  multicabOperator,
  tourGuide,
  tricycleDriver,
  ferryOperator;

  String get label {
    switch (this) {
      case ProviderCategory.boatOperator:    return 'Boat Operator';
      case ProviderCategory.vanOperator:     return 'Van Operator';
      case ProviderCategory.habalHabal:      return 'Habal-habal Driver';
      case ProviderCategory.multicabOperator:return 'Multicab Operator';
      case ProviderCategory.tourGuide:       return 'Tour Guide';
      case ProviderCategory.tricycleDriver:  return 'Tricycle Driver';
      case ProviderCategory.ferryOperator:   return 'Ferry Operator';
    }
  }

  String get emoji {
    switch (this) {
      case ProviderCategory.boatOperator:    return '🚤';
      case ProviderCategory.vanOperator:     return '🚐';
      case ProviderCategory.habalHabal:      return '🏍';
      case ProviderCategory.multicabOperator:return '🚕';
      case ProviderCategory.tourGuide:       return '🧭';
      case ProviderCategory.tricycleDriver:  return '🛺';
      case ProviderCategory.ferryOperator:   return '⛴';
    }
  }

  IconData get icon {
    switch (this) {
      case ProviderCategory.boatOperator:    return Icons.sailing_rounded;
      case ProviderCategory.vanOperator:     return Icons.directions_car_rounded;
      case ProviderCategory.habalHabal:      return Icons.two_wheeler_rounded;
      case ProviderCategory.multicabOperator:return Icons.airport_shuttle_rounded;
      case ProviderCategory.tourGuide:       return Icons.person_pin_circle_rounded;
      case ProviderCategory.tricycleDriver:  return Icons.electric_rickshaw_rounded;
      case ProviderCategory.ferryOperator:   return Icons.directions_boat_filled_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ProviderCategory.boatOperator:
      case ProviderCategory.ferryOperator:   return const Color(0xFF0EA5E9);
      case ProviderCategory.tourGuide:       return const Color(0xFF10B981);
      case ProviderCategory.habalHabal:
      case ProviderCategory.tricycleDriver:  return const Color(0xFFF59E0B);
      case ProviderCategory.vanOperator:     return const Color(0xFF8B5CF6);
      default:                               return const Color(0xFF3B82F6);
    }
  }
}
