import 'api_client.dart';
import 'api_exception.dart';

enum ApiHealthStatus {
  connected,
  serverError,
  networkError,
  timeout,
  unknown;

  bool get isConnected => this == ApiHealthStatus.connected;

  String get userMessage {
    switch (this) {
      case ApiHealthStatus.connected:
        return 'Connected to BiliRoute backend API server.';
      case ApiHealthStatus.serverError:
        return 'Server returned an error. Please try again later.';
      case ApiHealthStatus.networkError:
        return 'Cannot connect to backend server. Verify server is running and network is active.';
      case ApiHealthStatus.timeout:
        return 'Server connection timed out.';
      case ApiHealthStatus.unknown:
        return 'Unknown connection status.';
    }
  }
}

/// ApiHealthService
/// Checks connectivity to the Node.js Express backend API (`GET /health`).
class ApiHealthService {
  final ApiClient _apiClient;

  ApiHealthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Check health status of `GET /api/v1/health`
  Future<ApiHealthStatus> checkHealth() async {
    try {
      final response = await _apiClient.get('/health');
      if (response is Map<String, dynamic> && response['message'] != null) {
        return ApiHealthStatus.connected;
      }
      return ApiHealthStatus.connected;
    } on ApiException catch (e) {
      if (e.type == ApiExceptionType.timeout) {
        return ApiHealthStatus.timeout;
      }
      if (e.type == ApiExceptionType.networkError) {
        return ApiHealthStatus.networkError;
      }
      if (e.type == ApiExceptionType.serverError) {
        return ApiHealthStatus.serverError;
      }
      return ApiHealthStatus.networkError;
    } catch (_) {
      return ApiHealthStatus.networkError;
    }
  }
}
