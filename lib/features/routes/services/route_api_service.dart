import '../../../core/network/api_client.dart';
import '../../../data/transport/route_option.dart';

/// RouteApiService
/// Communicates with Node.js Express route endpoints (`/api/v1/routes/*`).
class RouteApiService {
  final ApiClient _apiClient;

  RouteApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/routes?destinationId=
  Future<List<RouteOption>> getRoutesForDestination({required String destinationId, String? originName}) async {
    final Map<String, dynamic> queryParams = {
      'destinationId': destinationId,
    };
    if (originName != null && originName.isNotEmpty) {
      queryParams['originName'] = originName;
    }

    final response = await _apiClient.get(
      '/routes',
      queryParameters: queryParams,
    );

    if (response is List) {
      return response
          .map((item) => RouteOption.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /api/v1/routes/:id
  Future<RouteOption?> getRouteById(String id) async {
    final response = await _apiClient.get('/routes/$id');
    if (response is Map<String, dynamic>) {
      return RouteOption.fromJson(response);
    }
    return null;
  }
}
