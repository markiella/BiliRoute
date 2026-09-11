import '../../../core/network/api_client.dart';
import '../../../data/transport/transport_provider_model.dart';

/// TransportProviderApiService
/// Communicates with Node.js Express transport provider endpoints (`/api/v1/providers/*`).
class TransportProviderApiService {
  final ApiClient _apiClient;

  TransportProviderApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/providers
  /// Returns verified transport providers for tourists.
  Future<List<TransportProviderModel>> getVerifiedProviders({String? type}) async {
    final Map<String, dynamic> queryParams = {};
    if (type != null && type.isNotEmpty) queryParams['type'] = type;

    final response = await _apiClient.get(
      '/providers',
      queryParameters: queryParams,
    );

    if (response is List) {
      return response
          .map((item) => TransportProviderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /api/v1/providers/:id
  Future<TransportProviderModel?> getProviderById(String id) async {
    final response = await _apiClient.get('/providers/$id');
    if (response is Map<String, dynamic>) {
      return TransportProviderModel.fromJson(response);
    }
    return null;
  }
}
