class TransportScheduleModel {
  final String id;
  final String providerId;
  final String routeId;
  final int routeStepSequence;
  final String transportMode;
  final List<String> departureTimes;
  final int estimatedDurationMinutes;
  final List<String> operatingDays;
  final bool isSeasonalOnly;
  final List<int>? seasonalMonths;
  final bool isAvailable;
  final String notes;

  const TransportScheduleModel({
    required this.id,
    required this.providerId,
    required this.routeId,
    required this.routeStepSequence,
    required this.transportMode,
    this.departureTimes = const [],
    required this.estimatedDurationMinutes,
    this.operatingDays = const [],
    this.isSeasonalOnly = false,
    this.seasonalMonths,
    this.isAvailable = true,
    this.notes = '',
  });

  factory TransportScheduleModel.fromJson(Map<String, dynamic> json) {
    return TransportScheduleModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      providerId: json['providerId'] is Map
          ? (json['providerId']['_id'] as String? ?? '')
          : json['providerId'] as String? ?? '',
      routeId: json['routeId'] is Map
          ? (json['routeId']['_id'] as String? ?? '')
          : json['routeId'] as String? ?? '',
      routeStepSequence: (json['routeStepSequence'] as num?)?.toInt() ?? 1,
      transportMode: json['transportMode'] as String? ?? '',
      departureTimes: (json['departureTimes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
      operatingDays: (json['operatingDays'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isSeasonalOnly: json['isSeasonalOnly'] as bool? ?? false,
      seasonalMonths: (json['seasonalMonths'] as List?)?.map((e) => (e as num).toInt()).toList(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      notes: json['notes'] as String? ?? '',
    );
  }
}
