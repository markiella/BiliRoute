class TransportProviderModel {
  final String id;
  final String name;
  final String type;
  final String? contactNumber;
  final List<String> serviceArea;
  final List<String> supportedRouteIds;
  final String verificationStatus;
  final bool isActive;
  final double? rating;
  final int ratingCount;
  final String notes;

  const TransportProviderModel({
    required this.id,
    required this.name,
    required this.type,
    this.contactNumber,
    this.serviceArea = const [],
    this.supportedRouteIds = const [],
    this.verificationStatus = 'unverified',
    this.isActive = true,
    this.rating,
    this.ratingCount = 0,
    this.notes = '',
  });

  factory TransportProviderModel.fromJson(Map<String, dynamic> json) {
    return TransportProviderModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      contactNumber: json['contactNumber'] as String?,
      serviceArea: (json['serviceArea'] as List?)?.map((e) => e.toString()).toList() ?? [],
      supportedRouteIds: (json['supportedRouteIds'] as List?)
              ?.map((e) => e is Map ? (e['_id'] as String? ?? '') : e.toString())
              .toList() ??
          [],
      verificationStatus: json['verificationStatus'] as String? ?? 'unverified',
      isActive: json['isActive'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }
}
