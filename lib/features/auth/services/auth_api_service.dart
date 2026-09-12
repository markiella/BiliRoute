import '../../../core/network/api_client.dart';
import '../models/auth_response.dart';

/// AuthApiService
/// Communicates directly with Node.js Express authentication endpoints (`/api/v1/auth/*`).
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// POST /api/v1/auth/register
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      },
    );

    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/v1/auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/v1/auth/verify-email
  Future<AuthResponse> verifyEmail({required String otp}) async {
    final response = await _apiClient.post(
      '/auth/verify-email',
      data: {'otp': otp},
    );

    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/v1/auth/resend-otp
  Future<AuthResponse> resendOtp() async {
    final response = await _apiClient.post('/auth/resend-otp');
    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/v1/auth/forgot-password
  Future<AuthResponse> forgotPassword({required String email}) async {
    final response = await _apiClient.post(
      '/auth/forgot-password',
      data: {'email': email},
    );

    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/v1/auth/reset-password
  Future<AuthResponse> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/reset-password',
      data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      },
    );

    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  /// GET /api/v1/auth/me
  Future<AuthResponse> getMe() async {
    final response = await _apiClient.get('/auth/me');
    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  /// PATCH /api/v1/auth/me
  Future<AuthResponse> updateMe({
    String? fullName,
    Map<String, dynamic>? preferences,
    List<String>? savedDestinations,
    String? profilePic,
    String? coverPic,
    String? phoneNumber,
    String? bio,
    String? location,
    String? emergencyContact,
  }) async {
    final Map<String, dynamic> bodyData = {};
    if (fullName != null) bodyData['fullName'] = fullName;
    if (preferences != null) bodyData['preferences'] = preferences;
    if (savedDestinations != null) bodyData['savedDestinations'] = savedDestinations;
    if (profilePic != null) bodyData['profilePic'] = profilePic;
    if (coverPic != null) bodyData['coverPic'] = coverPic;
    if (phoneNumber != null) bodyData['phoneNumber'] = phoneNumber;
    if (bio != null) bodyData['bio'] = bio;
    if (location != null) bodyData['location'] = location;
    if (emergencyContact != null) bodyData['emergencyContact'] = emergencyContact;

    final response = await _apiClient.patch(
      '/auth/me',
      data: bodyData,
    );

    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }
}
