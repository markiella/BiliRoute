import '../../../core/network/api_client.dart';
import '../../../data/transport/route_option.dart';

/// RecommendationApiService
/// Communicates with Node.js Express recommendation endpoint (`POST /api/v1/recommendations/query`).
class RecommendationApiService {
  final ApiClient _apiClient;

  RecommendationApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// POST /api/v1/recommendations/query
  /// Sends user travel preferences to backend recommendation engine.
  Future<List<RouteOption>> queryRecommendations({
    required String originName,
    required String destinationId,
    String preferenceProfile = 'recommended',
  }) async {
    final response = await _apiClient.post(
      '/recommendations/query',
      data: {
        'originName': originName,
        'destinationId': destinationId,
        'preferenceProfile': preferenceProfile,
      },
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list
          .map((item) => RouteOption.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response is List) {
      return response
          .map((item) => RouteOption.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
