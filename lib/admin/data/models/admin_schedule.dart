// ─────────────────────────────────────────────────────────────────────────────
// AdminSchedule — Transport departure schedule model
// ─────────────────────────────────────────────────────────────────────────────

enum ScheduleStatus { active, inactive, seasonal }

class AdminSchedule {
  AdminSchedule({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.routeId,
    required this.routeLabel,
    required this.departureTimes,
    required this.operatingDays,
    required this.status,
    this.arrivalTime,
    this.lastTripNote,
    this.isLastTripIndicator = false,
    this.notes,
    this.dateAdded,
    this.dateUpdated,
  });

  final String         id;
  String               providerId;
  String               providerName;
  String               routeId;
  String               routeLabel;
  List<String>         departureTimes;    // e.g. ['06:00', '09:00', '13:00']
  List<String>         operatingDays;     // e.g. ['Mon', 'Tue', 'Wed', ...]
  ScheduleStatus       status;
  String?              arrivalTime;
  String?              lastTripNote;
  bool                 isLastTripIndicator;
  String?              notes;
  DateTime?            dateAdded;
  DateTime?            dateUpdated;

  String get departureDisplay => departureTimes.join(', ');

  String get daysDisplay => operatingDays.join(', ');

  String get statusLabel {
    switch (status) {
      case ScheduleStatus.active:   return 'Active';
      case ScheduleStatus.inactive: return 'Inactive';
      case ScheduleStatus.seasonal: return 'Seasonal';
    }
  }

  AdminSchedule copyWith({
    String?         providerId,
    String?         providerName,
    String?         routeId,
    String?         routeLabel,
    List<String>?   departureTimes,
    List<String>?   operatingDays,
    ScheduleStatus? status,
    String?         arrivalTime,
    String?         lastTripNote,
    bool?           isLastTripIndicator,
    String?         notes,
  }) => AdminSchedule(
    id:                  id,
    providerId:          providerId          ?? this.providerId,
    providerName:        providerName        ?? this.providerName,
    routeId:             routeId             ?? this.routeId,
    routeLabel:          routeLabel          ?? this.routeLabel,
    departureTimes:      departureTimes      ?? this.departureTimes,
    operatingDays:       operatingDays       ?? this.operatingDays,
    status:              status              ?? this.status,
    arrivalTime:         arrivalTime         ?? this.arrivalTime,
    lastTripNote:        lastTripNote        ?? this.lastTripNote,
    isLastTripIndicator: isLastTripIndicator ?? this.isLastTripIndicator,
    notes:               notes               ?? this.notes,
    dateAdded:           dateAdded,
    dateUpdated:         DateTime.now(),
  );

  factory AdminSchedule.fromBackendJson(Map<String, dynamic> json) {
    final prov = json['providerId'];
    final providerId = prov is Map ? (prov['_id'] as String? ?? '') : (prov as String? ?? '');
    final providerName = prov is Map ? (prov['name'] as String? ?? '') : '';

    final rt = json['routeId'];
    final routeId = rt is Map ? (rt['_id'] as String? ?? '') : (rt as String? ?? '');
    final routeLabel = rt is Map ? (rt['label'] as String? ?? '') : '';

    final isActive = json['isActive'] as bool? ?? true;
    final isSeasonal = json['isSeasonal'] as bool? ?? false;

    return AdminSchedule(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      providerId: providerId,
      providerName: providerName.isNotEmpty ? providerName : 'Transport Provider',
      routeId: routeId,
      routeLabel: routeLabel.isNotEmpty ? routeLabel : 'Transport Route',
      departureTimes: (json['departureTimes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      operatingDays: (json['operatingDays'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: isSeasonal
          ? ScheduleStatus.seasonal
          : isActive
              ? ScheduleStatus.active
              : ScheduleStatus.inactive,
      notes: json['notes'] as String?,
      dateAdded: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      dateUpdated: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'providerId': providerId,
      'routeId': routeId,
      'departureTimes': departureTimes,
      'operatingDays': operatingDays,
      'isSeasonal': status == ScheduleStatus.seasonal,
      'isActive': status == ScheduleStatus.active || status == ScheduleStatus.seasonal,
      if (notes != null) 'notes': notes,
    };
  }
}
