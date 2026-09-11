import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminAdvisory — Travel advisory with severity and publication workflow
// ─────────────────────────────────────────────────────────────────────────────

enum AdvisoryCategory {
  weather, seaTravel, roadConditions, festivalAdvisory, tourismNotice, general;

  String get label {
    switch (this) {
      case AdvisoryCategory.weather:           return 'Weather';
      case AdvisoryCategory.seaTravel:         return 'Sea Travel';
      case AdvisoryCategory.roadConditions:    return 'Road Conditions';
      case AdvisoryCategory.festivalAdvisory:  return 'Festival Advisory';
      case AdvisoryCategory.tourismNotice:     return 'Tourism Notice';
      case AdvisoryCategory.general:           return 'General';
    }
  }

  String get emoji {
    switch (this) {
      case AdvisoryCategory.weather:           return '🌦️';
      case AdvisoryCategory.seaTravel:         return '⛵';
      case AdvisoryCategory.roadConditions:    return '🚧';
      case AdvisoryCategory.festivalAdvisory:  return '🎉';
      case AdvisoryCategory.tourismNotice:     return '📢';
      case AdvisoryCategory.general:           return 'ℹ️';
    }
  }
}

enum AdvisorySeverity { info, moderate, high, critical }

enum AdvisoryStatus { draft, published, expired }

class AdminAdvisory {
  AdminAdvisory({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.affectedDestinationIds = const [],
    this.affectedDestinationNames = const [],
    this.affectedRouteIds = const [],
    this.dateAdded,
    this.dateUpdated,
    this.publishedBy,
  });

  final String         id;
  String               title;
  String               description;
  AdvisoryCategory     category;
  AdvisorySeverity     severity;
  AdvisoryStatus       status;
  DateTime             startDate;
  DateTime             endDate;
  List<String>         affectedDestinationIds;
  List<String>         affectedDestinationNames;
  List<String>         affectedRouteIds;
  DateTime?            dateAdded;
  DateTime?            dateUpdated;
  String?              publishedBy;

  bool get isActive =>
      status == AdvisoryStatus.published &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);

  String get severityLabel {
    switch (severity) {
      case AdvisorySeverity.info:     return 'Info';
      case AdvisorySeverity.moderate: return 'Moderate';
      case AdvisorySeverity.high:     return 'High';
      case AdvisorySeverity.critical: return 'Critical';
    }
  }

  Color get severityColor {
    switch (severity) {
      case AdvisorySeverity.info:     return const Color(0xFF3B82F6);
      case AdvisorySeverity.moderate: return const Color(0xFFF59E0B);
      case AdvisorySeverity.high:     return const Color(0xFFEF4444);
      case AdvisorySeverity.critical: return const Color(0xFF7F1D1D);
    }
  }

  String get statusLabel {
    switch (status) {
      case AdvisoryStatus.draft:     return 'Draft';
      case AdvisoryStatus.published: return 'Published';
      case AdvisoryStatus.expired:   return 'Expired';
    }
  }

  Color get statusColor {
    switch (status) {
      case AdvisoryStatus.draft:     return const Color(0xFF94A3B8);
      case AdvisoryStatus.published: return const Color(0xFF10B981);
      case AdvisoryStatus.expired:   return const Color(0xFFEF4444);
    }
  }

  AdminAdvisory copyWith({
    String?          title,
    String?          description,
    AdvisoryCategory? category,
    AdvisorySeverity? severity,
    AdvisoryStatus?  status,
    DateTime?        startDate,
    DateTime?        endDate,
    List<String>?    affectedDestinationIds,
    List<String>?    affectedDestinationNames,
    List<String>?    affectedRouteIds,
    String?          publishedBy,
  }) => AdminAdvisory(
    id:                      id,
    title:                   title                   ?? this.title,
    description:             description             ?? this.description,
    category:                category                ?? this.category,
    severity:                severity                ?? this.severity,
    status:                  status                  ?? this.status,
    startDate:               startDate               ?? this.startDate,
    endDate:                 endDate                 ?? this.endDate,
    affectedDestinationIds:  affectedDestinationIds  ?? this.affectedDestinationIds,
    affectedDestinationNames:affectedDestinationNames?? this.affectedDestinationNames,
    affectedRouteIds:        affectedRouteIds        ?? this.affectedRouteIds,
    publishedBy:             publishedBy             ?? this.publishedBy,
    dateAdded:               dateAdded,
    dateUpdated:             DateTime.now(),
  );

  factory AdminAdvisory.fromBackendJson(Map<String, dynamic> json) {
    final catStr = json['category'] as String? ?? 'General';
    AdvisoryCategory cat;
    switch (catStr.toLowerCase()) {
      case 'weather': cat = AdvisoryCategory.weather; break;
      case 'sea condition':
      case 'sea travel': cat = AdvisoryCategory.seaTravel; break;
      case 'road condition':
      case 'road conditions': cat = AdvisoryCategory.roadConditions; break;
      case 'safety':
      case 'festival advisory': cat = AdvisoryCategory.festivalAdvisory; break;
      case 'general tourism':
      case 'tourism notice': cat = AdvisoryCategory.tourismNotice; break;
      default: cat = AdvisoryCategory.general; break;
    }

    final sevStr = json['severity'] as String? ?? 'Info';
    AdvisorySeverity sev;
    switch (sevStr.toLowerCase()) {
      case 'caution':
      case 'moderate': sev = AdvisorySeverity.moderate; break;
      case 'warning':
      case 'high': sev = AdvisorySeverity.high; break;
      case 'critical': sev = AdvisorySeverity.critical; break;
      case 'info':
      default: sev = AdvisorySeverity.info; break;
    }

    final isActive = json['isActive'] as bool? ?? true;
    final expiresAt = DateTime.tryParse(json['expiresAt']?.toString() ?? '');
    final isExpired = expiresAt != null && expiresAt.isBefore(DateTime.now());

    AdvisoryStatus status;
    if (!isActive) {
      status = AdvisoryStatus.draft;
    } else if (isExpired) {
      status = AdvisoryStatus.expired;
    } else {
      status = AdvisoryStatus.published;
    }

    return AdminAdvisory(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['message'] as String? ?? '',
      category: cat,
      severity: sev,
      status: status,
      startDate: DateTime.tryParse(json['effectiveFrom']?.toString() ?? '') ?? DateTime.now(),
      endDate: expiresAt ?? DateTime.now().add(const Duration(days: 7)),
      affectedDestinationIds: (json['affectedDestinationIds'] as List?)
              ?.map((e) => e is Map ? (e['_id'] as String? ?? '') : e.toString())
              .toList() ??
          [],
      affectedDestinationNames: (json['affectedDestinationIds'] as List?)
              ?.map((e) => e is Map ? (e['name'] as String? ?? '') : '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          [],
      affectedRouteIds: (json['affectedRouteIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      publishedBy: json['issuedBy'] as String? ?? 'Biliran Tourism Office',
      dateAdded: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      dateUpdated: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toBackendJson() {
    String sevStr;
    switch (severity) {
      case AdvisorySeverity.moderate: sevStr = 'Caution'; break;
      case AdvisorySeverity.high: sevStr = 'Warning'; break;
      case AdvisorySeverity.critical: sevStr = 'Critical'; break;
      case AdvisorySeverity.info: sevStr = 'Info'; break;
    }

    String catStr;
    switch (category) {
      case AdvisoryCategory.weather: catStr = 'Weather'; break;
      case AdvisoryCategory.seaTravel: catStr = 'Sea Condition'; break;
      case AdvisoryCategory.roadConditions: catStr = 'Road Condition'; break;
      case AdvisoryCategory.festivalAdvisory: catStr = 'Safety'; break;
      case AdvisoryCategory.tourismNotice: catStr = 'General Tourism'; break;
      case AdvisoryCategory.general: catStr = 'General Tourism'; break;
    }

    return {
      'title': title,
      'message': description,
      'category': catStr,
      'severity': sevStr,
      'effectiveFrom': startDate.toIso8601String(),
      'expiresAt': endDate.toIso8601String(),
      'isActive': status == AdvisoryStatus.published,
      'issuedBy': publishedBy ?? 'Biliran Tourism Office',
      if (affectedDestinationIds.isNotEmpty) 'affectedDestinationIds': affectedDestinationIds,
      if (affectedRouteIds.isNotEmpty) 'affectedRouteIds': affectedRouteIds,
    };
  }
}
