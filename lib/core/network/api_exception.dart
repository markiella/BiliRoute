/// ApiExceptionType
/// Enum categorizing network/HTTP error categories
enum ApiExceptionType {
  networkError,
  timeout,
  unauthorized,     // HTTP 401
  forbidden,        // HTTP 403
  notFound,         // HTTP 404
  validationError,  // HTTP 400 / 422
  serverError,      // HTTP 500
  unknown,
}

/// ApiException
/// Unified exception class for all REST API communication failures.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiExceptionType type;
  final List<dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.type = ApiExceptionType.unknown,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, type: $type, message: $message)';
  }

  /// Factory helper for network connection failures
  factory ApiException.networkError([String? customMsg]) {
    return ApiException(
      message: customMsg ?? 'Unable to connect to BiliRoute server. Please check your network connection.',
      type: ApiExceptionType.networkError,
    );
  }

  /// Factory helper for request timeouts
  factory ApiException.timeout() {
    return const ApiException(
      message: 'Connection timed out. The server is taking too long to respond.',
      type: ApiExceptionType.timeout,
    );
  }
}
