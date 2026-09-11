import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// AuthInterceptor
/// Interceptor that attaches the JWT Bearer token to outgoing HTTP requests
/// and handles HTTP 401 unauthorized responses cleanly.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;

  AuthInterceptor([SecureStorageService? storageService])
      : _storageService = storageService ?? SecureStorageService.instance;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Cleanly handle session expiration (e.g. token expired)
      _storageService.clearSession();
    }
    return handler.next(err);
  }
}
