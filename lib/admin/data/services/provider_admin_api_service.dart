import '../../../core/network/api_client.dart';

/// ProviderAdminApiService
/// Admin API client for backend TransportProvider endpoints (`/api/v1/providers/*`).
class ProviderAdminApiService {
  final ApiClient _apiClient;

  ProviderAdminApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/providers/admin/all
  Future<List<Map<String, dynamic>>> getAllProvidersAdmin() async {
    final response = await _apiClient.get('/providers/admin/all');
    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } else if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// POST /api/v1/providers
  Future<Map<String, dynamic>?> createProvider(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/providers', data: payload);
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// PATCH /api/v1/providers/:id
  Future<Map<String, dynamic>?> updateProvider(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.patch('/providers/$id', data: payload);
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// PATCH /api/v1/providers/:id/verify
  Future<Map<String, dynamic>?> verifyProvider(String id) async {
    final response = await _apiClient.patch('/providers/$id/verify');
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }
}
