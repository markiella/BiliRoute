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
  published,
  rejected;

  String get label {
    switch (this) {
      case SurveyStatus.pending:   return 'Pending Validation';
      case SurveyStatus.validated: return 'Validated / Approved';
      case SurveyStatus.published: return 'Published';
      case SurveyStatus.rejected:  return 'Rejected';
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

  /// Factory constructor parsing backend FieldSurvey document JSON.
  factory FieldSurveyRecord.fromBackendJson(Map<String, dynamic> json) {
    final statusStr = json['verificationStatus'] as String? ?? 'pending';
    SurveyStatus status;
    switch (statusStr.toLowerCase()) {
      case 'approved':
      case 'reviewed':
        status = SurveyStatus.validated;
        break;
      case 'published':
        status = SurveyStatus.published;
        break;
      case 'rejected':
        status = SurveyStatus.rejected;
        break;
      case 'pending':
      default:
        status = SurveyStatus.pending;
        break;
    }

    // GeoJSON [longitude, latitude]
    double lng = 124.26429026111757;
    double lat = 11.766384941701004;
    final gpsObj = json['gps'];
    if (gpsObj is Map<String, dynamic> && gpsObj['coordinates'] is List) {
      final coords = gpsObj['coordinates'] as List;
      if (coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    }

    final destId = json['destinationId'] is Map
        ? (json['destinationId']['_id'] as String? ?? '')
        : (json['destinationId'] as String? ?? '');

    final destName = json['destinationName'] as String? ??
        (json['destinationId'] is Map ? (json['destinationId']['name'] as String? ?? '') : '');

    final surveyors = json['surveyorTeam'] as List?;
    final surveyorName = surveyors?.map((e) => e.toString()).join(', ') ?? 'BiliRoute Research Team';

    final photos = json['photos'] as List?;
    final photoEvidence = photos
            ?.map((p) => p is Map ? (p['url'] as String? ?? '') : p.toString())
            .where((url) => url.isNotEmpty)
            .toList() ??
        [];

    return FieldSurveyRecord(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      destinationId: destId,
      destinationName: destName.isNotEmpty ? destName : 'Unspecified Destination',
      gpsLatitude: lat,
      gpsLongitude: lng,
      gpsAccuracyMeters: (json['gpsAccuracyMeters'] as num?)?.toDouble() ?? 5.0,
      surveyorName: surveyorName,
      surveyDate: DateTime.tryParse(json['surveyDate']?.toString() ?? '') ?? DateTime.now(),
      municipality: json['municipality'] as String? ?? 'Maripipi',
      barangay: json['barangay'] as String? ?? 'Sambawan',
      status: status,
      device: GpsDevice.smartphone,
      photoEvidence: photoEvidence,
      observations: json['rawFieldNotes'] as String? ?? json['safetyNotes'] as String?,
      weatherCondition: json['weatherCondition'] as String? ?? 'Clear',
      accessCondition: json['transport']?['notes'] as String? ?? 'Accessible',
      validatedBy: json['reviewedBy'] as String?,
      validatedAt: DateTime.tryParse(json['reviewedAt']?.toString() ?? ''),
      notes: json['reviewNotes'] as String?,
    );
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
