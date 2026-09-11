import '../../../core/network/api_client.dart';
import '../../../data/transport/transport_schedule_model.dart';

/// TransportScheduleApiService
/// Communicates with Node.js Express transport schedule endpoints (`/api/v1/schedules/*`).
class TransportScheduleApiService {
  final ApiClient _apiClient;

  TransportScheduleApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/schedules?routeId=
  Future<List<TransportScheduleModel>> getSchedulesForRoute({required String routeId, String? providerId}) async {
    final Map<String, dynamic> queryParams = {
      'routeId': routeId,
    };
    if (providerId != null && providerId.isNotEmpty) {
      queryParams['providerId'] = providerId;
    }

    final response = await _apiClient.get(
      '/schedules',
      queryParameters: queryParams,
    );

    if (response is List) {
      return response
          .map((item) => TransportScheduleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
