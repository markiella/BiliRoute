import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminDestination — Full CRUD-capable destination model
//
// Superset of DestinationItem, adds verification workflow fields.
// ─────────────────────────────────────────────────────────────────────────────

enum DestinationStatus {
  pending,
  fieldSurveyed,
  verified,
  published,
  archived;

  String get label {
    switch (this) {
      case DestinationStatus.pending:       return 'Pending';
      case DestinationStatus.fieldSurveyed: return 'Field Surveyed';
      case DestinationStatus.verified:      return 'Verified';
      case DestinationStatus.published:     return 'Published';
      case DestinationStatus.archived:      return 'Archived';
    }
  }

  Color get color {
    switch (this) {
      case DestinationStatus.pending:       return const Color(0xFF94A3B8); // slate
      case DestinationStatus.fieldSurveyed: return const Color(0xFFF59E0B); // amber
      case DestinationStatus.verified:      return const Color(0xFF3B82F6); // blue
      case DestinationStatus.published:     return const Color(0xFF10B981); // green
      case DestinationStatus.archived:      return const Color(0xFFEF4444); // red
    }
  }

  IconData get icon {
    switch (this) {
      case DestinationStatus.pending:       return Icons.hourglass_empty_rounded;
      case DestinationStatus.fieldSurveyed: return Icons.gps_fixed_rounded;
      case DestinationStatus.verified:      return Icons.verified_rounded;
      case DestinationStatus.published:     return Icons.public_rounded;
      case DestinationStatus.archived:      return Icons.archive_rounded;
    }
  }

  /// Next logical status in the verification workflow.
  DestinationStatus? get next {
    switch (this) {
      case DestinationStatus.pending:       return DestinationStatus.fieldSurveyed;
      case DestinationStatus.fieldSurveyed: return DestinationStatus.verified;
      case DestinationStatus.verified:      return DestinationStatus.published;
      case DestinationStatus.published:     return null; // terminal state
      case DestinationStatus.archived:      return null;
    }
  }
}

enum DestinationCategory {
  island, beach, waterfall, resort, mountain, cave, culturalSite, park, spring;

  String get label {
    switch (this) {
      case DestinationCategory.island:       return 'Island';
      case DestinationCategory.beach:        return 'Beach';
      case DestinationCategory.waterfall:    return 'Waterfall';
      case DestinationCategory.resort:       return 'Resort';
      case DestinationCategory.mountain:     return 'Mountain';
      case DestinationCategory.cave:         return 'Cave';
      case DestinationCategory.culturalSite: return 'Cultural Site';
      case DestinationCategory.park:         return 'Park';
      case DestinationCategory.spring:       return 'Spring';
    }
  }
}

enum SignalStrength { none, weak, moderate, strong }

class AdminDestination {
  AdminDestination({
    required this.id,
    required this.name,
    required this.category,
    required this.municipality,
    required this.barangay,
    required this.province,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.entranceFee,
    required this.envFee,
    this.cottageFee,
    required this.estimatedFare,
    required this.travelTime,
    required this.bestSeason,
    required this.difficulty,
    required this.signalStrength,
    required this.thingsToDo,
    required this.whatToBring,
    required this.safetyReminders,
    required this.galleryAssets,
    required this.status,
    this.coverImageAsset,
    this.rating = 0.0,
    this.isFieldVerified = false,
    this.verifiedBy,
    this.verifiedAt,
    this.dateAdded,
    this.dateUpdated,
  });

  final String              id;
  String                    name;
  DestinationCategory       category;
  String                    municipality;
  String                    barangay;
  String                    province;
  String                    description;
  double                    latitude;
  double                    longitude;
  int                       entranceFee;
  int                       envFee;
  int?                      cottageFee;
  int                       estimatedFare;
  String                    travelTime;
  String                    bestSeason;
  String                    difficulty;
  SignalStrength             signalStrength;
  List<String>              thingsToDo;
  List<String>              whatToBring;
  List<String>              safetyReminders;
  List<String>              galleryAssets;
  DestinationStatus         status;
  String?                   coverImageAsset;
  double                    rating;
  bool                      isFieldVerified;
  String?                   verifiedBy;
  DateTime?                 verifiedAt;
  DateTime?                 dateAdded;
  DateTime?                 dateUpdated;

  String get locationDisplay => '$municipality, $province';

  String get coordinatesDisplay =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  String get signalLabel {
    switch (signalStrength) {
      case SignalStrength.none:     return 'None';
      case SignalStrength.weak:     return 'Weak';
      case SignalStrength.moderate: return 'Moderate';
      case SignalStrength.strong:   return 'Strong';
    }
  }

  AdminDestination copyWith({
    String?             name,
    DestinationCategory? category,
    String?             municipality,
    String?             barangay,
    String?             province,
    String?             description,
    double?             latitude,
    double?             longitude,
    int?                entranceFee,
    int?                envFee,
    int?                cottageFee,
    int?                estimatedFare,
    String?             travelTime,
    String?             bestSeason,
    String?             difficulty,
    SignalStrength?      signalStrength,
    List<String>?       thingsToDo,
    List<String>?       whatToBring,
    List<String>?       safetyReminders,
    List<String>?       galleryAssets,
    DestinationStatus?  status,
    String?             coverImageAsset,
    double?             rating,
    bool?               isFieldVerified,
    String?             verifiedBy,
    DateTime?           verifiedAt,
    DateTime?           dateUpdated,
  }) {
    return AdminDestination(
      id:               id,
      name:             name             ?? this.name,
      category:         category         ?? this.category,
      municipality:     municipality     ?? this.municipality,
      barangay:         barangay         ?? this.barangay,
      province:         province         ?? this.province,
      description:      description      ?? this.description,
      latitude:         latitude         ?? this.latitude,
      longitude:        longitude        ?? this.longitude,
      entranceFee:      entranceFee      ?? this.entranceFee,
      envFee:           envFee           ?? this.envFee,
      cottageFee:       cottageFee       ?? this.cottageFee,
      estimatedFare:    estimatedFare    ?? this.estimatedFare,
      travelTime:       travelTime       ?? this.travelTime,
      bestSeason:       bestSeason       ?? this.bestSeason,
      difficulty:       difficulty       ?? this.difficulty,
      signalStrength:   signalStrength   ?? this.signalStrength,
      thingsToDo:       thingsToDo       ?? this.thingsToDo,
      whatToBring:      whatToBring      ?? this.whatToBring,
      safetyReminders:  safetyReminders  ?? this.safetyReminders,
      galleryAssets:    galleryAssets    ?? this.galleryAssets,
      status:           status           ?? this.status,
      coverImageAsset:  coverImageAsset  ?? this.coverImageAsset,
      rating:           rating           ?? this.rating,
      isFieldVerified:  isFieldVerified  ?? this.isFieldVerified,
      verifiedBy:       verifiedBy       ?? this.verifiedBy,
      verifiedAt:       verifiedAt       ?? this.verifiedAt,
      dateAdded:        dateAdded,
      dateUpdated:      dateUpdated      ?? DateTime.now(),
    );
  }
}
