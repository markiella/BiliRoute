import '../../../core/network/api_client.dart';

/// ScheduleAdminApiService
/// Admin API client for backend TransportSchedule endpoints (`/api/v1/schedules/*`).
class ScheduleAdminApiService {
  final ApiClient _apiClient;

  ScheduleAdminApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/schedules
  Future<List<Map<String, dynamic>>> getSchedules() async {
    final response = await _apiClient.get('/schedules');
    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } else if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// POST /api/v1/schedules
  Future<Map<String, dynamic>?> createSchedule(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/schedules', data: payload);
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// PATCH /api/v1/schedules/:id
  Future<Map<String, dynamic>?> updateSchedule(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.patch('/schedules/$id', data: payload);
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// DELETE /api/v1/schedules/:id
  Future<bool> deleteSchedule(String id) async {
    await _apiClient.delete('/schedules/$id');
    return true;
  }
}
