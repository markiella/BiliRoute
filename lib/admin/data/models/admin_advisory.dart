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
}
