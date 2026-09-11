import 'auth_session.dart';

/// AuthResponse
/// Data Transfer Object parsing responses from `/api/v1/auth/*` endpoints.
class AuthResponse {
  final String? token;
  final String? userId;
  final String? fullName;
  final String? email;
  final UserRole role;
  final bool emailVerified;
  final List<String> savedDestinations;
  final String preferenceProfile;
  final String? simulatedOtp;
  final String? message;

  const AuthResponse({
    this.token,
    this.userId,
    this.fullName,
    this.email,
    this.role = UserRole.tourist,
    this.emailVerified = false,
    this.savedDestinations = const [],
    this.preferenceProfile = 'recommended',
    this.simulatedOtp,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json, {String? token, String? message}) {
    final dataObj = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final userData = dataObj['user'] is Map<String, dynamic>
        ? dataObj['user'] as Map<String, dynamic>
        : (json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : dataObj);

    final rawSaved = userData['savedDestinations'] as List<dynamic>?;
    final parsedSaved = rawSaved?.map((e) => e.toString()).toList() ?? [];

    final rawPref = userData['preferences'] is Map<String, dynamic>
        ? userData['preferences'] as Map<String, dynamic>
        : null;
    final parsedPrefProfile = rawPref?['preferenceProfile'] as String? ?? 'recommended';

    return AuthResponse(
      token: token ?? dataObj['token'] as String? ?? json['token'] as String?,
      userId: userData['_id'] as String? ?? userData['id'] as String?,
      fullName: userData['fullName'] as String?,
      email: userData['email'] as String?,
      role: UserRole.fromString(userData['role'] as String? ?? 'tourist'),
      emailVerified: userData['emailVerified'] as bool? ?? false,
      savedDestinations: parsedSaved,
      preferenceProfile: parsedPrefProfile,
      simulatedOtp: dataObj['simulatedOtp'] as String? ?? json['simulatedOtp'] as String?,
      message: message ?? json['message'] as String?,
    );
  }

  AuthSession toSession() {
    return AuthSession(
      isLoggedIn: token != null && token!.isNotEmpty,
      accessToken: token,
      userId: userId,
      fullName: fullName,
      email: email,
      role: role,
      isEmailVerified: emailVerified,
      savedDestinations: savedDestinations,
      preferenceProfile: preferenceProfile,
    );
  }
}
