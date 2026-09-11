import 'package:dio/dio.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

/// ApiClient
/// Main HTTP client wrapper using Dio for BiliRoute REST API communication.
class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? customDio}) {
    _dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            sendTimeout: ApiConfig.sendTimeout,
            headers: ApiConfig.defaultHeaders,
          ),
        );

    _dio.interceptors.add(AuthInterceptor());
  }

  /// Update base URL dynamically (e.g. if switching to custom LAN IP)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // ─── HTTP Methods ──────────────────────────────────────────────────────────

  /// GET Request
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST Request
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH Request
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE Request
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Response & Error Processing ─────────────────────────────────────────

  dynamic _processResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final bool success = data['success'] ?? true;
      if (!success) {
        throw ApiException(
          message: data['message'] ?? 'API request failed',
          statusCode: response.statusCode,
          type: _getTypeFromStatusCode(response.statusCode),
          errors: data['errors'],
        );
      }
      return data['data'] ?? data;
    }
    return data;
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException.timeout();
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException.networkError();
    }

    final response = error.response;
    if (response != null && response.data is Map<String, dynamic>) {
      final resData = response.data as Map<String, dynamic>;
      return ApiException(
        message: resData['message'] ?? 'Server error occurred',
        statusCode: response.statusCode,
        type: _getTypeFromStatusCode(response.statusCode),
        errors: resData['errors'],
      );
    }

    return ApiException(
      message: error.message ?? 'An unexpected network error occurred',
      statusCode: response?.statusCode,
      type: _getTypeFromStatusCode(response?.statusCode),
    );
  }

  ApiExceptionType _getTypeFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
      case 422:
        return ApiExceptionType.validationError;
      case 401:
        return ApiExceptionType.unauthorized;
      case 403:
        return ApiExceptionType.forbidden;
      case 404:
        return ApiExceptionType.notFound;
      case 500:
      case 502:
      case 503:
        return ApiExceptionType.serverError;
      default:
        return ApiExceptionType.unknown;
    }
  }
}
