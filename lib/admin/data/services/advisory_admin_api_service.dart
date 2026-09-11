import '../../../core/network/api_client.dart';

/// AdvisoryAdminApiService
/// Admin API client for backend Advisory endpoints (`/api/v1/advisories/*`).
class AdvisoryAdminApiService {
  final ApiClient _apiClient;

  AdvisoryAdminApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/advisories/admin/all
  Future<List<Map<String, dynamic>>> getAllAdvisoriesAdmin() async {
    final response = await _apiClient.get('/advisories/admin/all');
    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } else if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// POST /api/v1/advisories
  Future<Map<String, dynamic>?> createAdvisory(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/advisories', data: payload);
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// PATCH /api/v1/advisories/:id
  Future<Map<String, dynamic>?> updateAdvisory(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.patch('/advisories/$id', data: payload);
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// PATCH /api/v1/advisories/:id/deactivate
  Future<Map<String, dynamic>?> deactivateAdvisory(String id) async {
    final response = await _apiClient.patch('/advisories/$id/deactivate');
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }
}
