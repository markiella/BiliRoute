// ─────────────────────────────────────────────────────────────────────────────
// FieldSurveyRecord — Primary GPS data collection and validation record
//
// Each record documents a BiliRoute field survey visit:
// GPS coordinates, surveyor info, validation status, and photo evidence.
// Sambawan Island is the first validated entry in the system.
// ─────────────────────────────────────────────────────────────────────────────

enum SurveyStatus {
  pending,
  validated,
  published;

  String get label {
    switch (this) {
      case SurveyStatus.pending:   return 'Pending Validation';
      case SurveyStatus.validated: return 'Validated';
      case SurveyStatus.published: return 'Published';
    }
  }
}

enum GpsDevice { smartphone, gpsUnit, droneGps, other }

class FieldSurveyRecord {
  FieldSurveyRecord({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.gpsAccuracyMeters,
    required this.surveyorName,
    required this.surveyDate,
    required this.municipality,
    required this.barangay,
    required this.status,
    this.device = GpsDevice.smartphone,
    this.deviceModel,
    this.photoEvidence = const [],
    this.observations,
    this.weatherCondition,
    this.accessCondition,
    this.validatedBy,
    this.validatedAt,
    this.notes,
  });

  final String         id;
  String               destinationId;
  String               destinationName;
  double               gpsLatitude;
  double               gpsLongitude;
  double               gpsAccuracyMeters;
  String               surveyorName;
  DateTime             surveyDate;
  String               municipality;
  String               barangay;
  SurveyStatus         status;
  GpsDevice            device;
  String?              deviceModel;
  List<String>         photoEvidence;     // image asset paths
  String?              observations;
  String?              weatherCondition;
  String?              accessCondition;
  String?              validatedBy;
  DateTime?            validatedAt;
  String?              notes;

  String get coordinatesDisplay =>
      '${gpsLatitude.toStringAsFixed(6)}, ${gpsLongitude.toStringAsFixed(6)}';

  String get accuracyDisplay => '±${gpsAccuracyMeters.toStringAsFixed(1)}m';

  String get surveyDateDisplay {
    return '${surveyDate.day.toString().padLeft(2, '0')}/'
           '${surveyDate.month.toString().padLeft(2, '0')}/'
           '${surveyDate.year}';
  }

  String get deviceLabel {
    switch (device) {
      case GpsDevice.smartphone: return 'Smartphone GPS';
      case GpsDevice.gpsUnit:    return 'GPS Unit';
      case GpsDevice.droneGps:   return 'Drone GPS';
      case GpsDevice.other:      return 'Other Device';
    }
  }

  FieldSurveyRecord copyWith({
    String?       destinationId,
    String?       destinationName,
    double?       gpsLatitude,
    double?       gpsLongitude,
    double?       gpsAccuracyMeters,
    String?       surveyorName,
    DateTime?     surveyDate,
    String?       municipality,
    String?       barangay,
    SurveyStatus? status,
    GpsDevice?    device,
    String?       deviceModel,
    List<String>? photoEvidence,
    String?       observations,
    String?       weatherCondition,
    String?       accessCondition,
    String?       validatedBy,
    DateTime?     validatedAt,
    String?       notes,
  }) => FieldSurveyRecord(
    id:                id,
    destinationId:     destinationId     ?? this.destinationId,
    destinationName:   destinationName   ?? this.destinationName,
    gpsLatitude:       gpsLatitude       ?? this.gpsLatitude,
    gpsLongitude:      gpsLongitude      ?? this.gpsLongitude,
    gpsAccuracyMeters: gpsAccuracyMeters ?? this.gpsAccuracyMeters,
    surveyorName:      surveyorName      ?? this.surveyorName,
    surveyDate:        surveyDate        ?? this.surveyDate,
    municipality:      municipality      ?? this.municipality,
    barangay:          barangay          ?? this.barangay,
    status:            status            ?? this.status,
    device:            device            ?? this.device,
    deviceModel:       deviceModel       ?? this.deviceModel,
    photoEvidence:     photoEvidence     ?? this.photoEvidence,
    observations:      observations      ?? this.observations,
    weatherCondition:  weatherCondition  ?? this.weatherCondition,
    accessCondition:   accessCondition   ?? this.accessCondition,
    validatedBy:       validatedBy       ?? this.validatedBy,
    validatedAt:       validatedAt       ?? this.validatedAt,
    notes:             notes             ?? this.notes,
  );
}
