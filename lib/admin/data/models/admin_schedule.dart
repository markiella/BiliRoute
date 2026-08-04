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
}
