import '../../../core/network/api_client.dart';
import '../../home/widgets/travel_advisory_section.dart';

/// AdvisoryApiService
/// Communicates with Node.js Express advisory endpoints (`/api/v1/advisories/*`).
class AdvisoryApiService {
  final ApiClient _apiClient;

  AdvisoryApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/advisories
  /// Returns active & non-expired travel advisories for tourists.
  Future<List<TravelAdvisory>> getActiveAdvisories({
    String? category,
    String? severity,
    String? destinationId,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (severity != null && severity.isNotEmpty) queryParams['severity'] = severity;
    if (destinationId != null && destinationId.isNotEmpty) queryParams['destinationId'] = destinationId;

    final response = await _apiClient.get(
      '/advisories',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list
          .map((item) => TravelAdvisory.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response is List) {
      return response
          .map((item) => TravelAdvisory.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /api/v1/advisories/:id
  Future<TravelAdvisory?> getAdvisoryById(String id) async {
    final response = await _apiClient.get('/advisories/$id');
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) {
        return TravelAdvisory.fromJson(data);
      }
    }
    return null;
  }
}
