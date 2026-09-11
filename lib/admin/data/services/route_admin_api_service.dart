import '../../../core/network/api_client.dart';

/// RouteAdminApiService
/// Admin API client for backend Route endpoints (`/api/v1/routes/*`).
class RouteAdminApiService {
  final ApiClient _apiClient;

  RouteAdminApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/routes
  Future<List<Map<String, dynamic>>> getRoutes() async {
    final response = await _apiClient.get('/routes');
    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } else if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// POST /api/v1/routes
  Future<Map<String, dynamic>?> createRoute(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/routes', data: payload);
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// PATCH /api/v1/routes/:id
  Future<Map<String, dynamic>?> updateRoute(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.patch('/routes/$id', data: payload);
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// PATCH /api/v1/routes/:id/deactivate
  Future<Map<String, dynamic>?> deactivateRoute(String id) async {
    final response = await _apiClient.patch('/routes/$id/deactivate');
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// DELETE /api/v1/routes/:id
  Future<bool> deleteRoute(String id) async {
    await _apiClient.delete('/routes/$id');
    return true;
  }
}
