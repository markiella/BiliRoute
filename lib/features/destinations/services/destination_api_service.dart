import '../../../core/network/api_client.dart';
import '../../../data/models/destination_model.dart';

/// DestinationApiService
/// Interacts with Node.js Express destination endpoints (`/api/v1/destinations/*`).
class DestinationApiService {
  final ApiClient _apiClient;

  DestinationApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/destinations
  /// Returns all published destinations from MongoDB.
  Future<List<DestinationItem>> getPublishedDestinations({String? category, String? search}) async {
    final Map<String, dynamic> queryParams = {};
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.get(
      '/destinations',
      queryParameters: queryParams,
    );

    if (response is List) {
      return response
          .map((item) => DestinationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /api/v1/destinations/:slug
  Future<DestinationItem?> getDestinationBySlug(String slug) async {
    final response = await _apiClient.get('/destinations/$slug');
    if (response is Map<String, dynamic>) {
      return DestinationItem.fromJson(response);
    }
    return null;
  }

  /// GET /api/v1/destinations/category/:category
  Future<List<DestinationItem>> getDestinationsByCategory(String category) async {
    final response = await _apiClient.get('/destinations/category/$category');
    if (response is List) {
      return response
          .map((item) => DestinationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /api/v1/destinations/nearby?lng=&lat=&maxDistanceMeters=
  /// GeoJSON 2dsphere proximity search
  Future<List<DestinationItem>> getNearbyDestinations({
    required double latitude,
    required double longitude,
    int maxDistanceMeters = 50000,
  }) async {
    final response = await _apiClient.get(
      '/destinations/nearby',
      queryParameters: {
        'lng': longitude,
        'lat': latitude,
        'maxDistanceMeters': maxDistanceMeters,
      },
    );

    if (response is List) {
      return response
          .map((item) => DestinationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
