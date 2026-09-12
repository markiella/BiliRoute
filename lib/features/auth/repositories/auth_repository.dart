import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_response.dart';
import '../models/auth_session.dart';
import '../services/auth_api_service.dart';
import '../services/mock_verification_service.dart';

/// AuthRepository
/// Central state manager for tourist/admin authentication across BiliRoute.
/// Manages real REST API auth flow with fallback support for MockVerificationService.
class AuthRepository extends ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();
  static AuthRepository get instance => _instance;

  final AuthApiService _apiService;
  final SecureStorageService _storageService;
  final MockVerificationService _mockService;

  AuthSession _currentSession = AuthSession.loggedOut();
  bool _isLoading = false;
  String? _errorMessage;

  /// Enable mock mode for testing without a running backend server
  bool useMockAuth = false;

  AuthRepository({
    AuthApiService? apiService,
    SecureStorageService? storageService,
    MockVerificationService? mockService,
  })  : _apiService = apiService ?? AuthApiService(),
        _storageService = storageService ?? SecureStorageService.instance,
        _mockService = mockService ?? MockVerificationService() {
    initializeSession();
  }

  AuthRepository._internal({
    AuthApiService? apiService,
    SecureStorageService? storageService,
    MockVerificationService? mockService,
  })  : _apiService = apiService ?? AuthApiService(),
        _storageService = storageService ?? SecureStorageService.instance,
        _mockService = mockService ?? MockVerificationService() {
    initializeSession();
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  AuthSession get currentSession => _currentSession;
  bool get isLoggedIn => _currentSession.isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ─── Initialization ────────────────────────────────────────────────────────

  /// Initialize session from secure storage on app launch
  Future<void> initializeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedProfilePic = prefs.getString('user_profile_pic');
    final cachedCoverPic = prefs.getString('user_cover_pic');
    final cachedPhone = prefs.getString('user_phone_number');
    final cachedBio = prefs.getString('user_bio');
    final cachedLocation = prefs.getString('user_location');
    final cachedEmergency = prefs.getString('user_emergency_contact');
    final cachedFullName = prefs.getString('user_full_name');

    final token = await _storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        final meResponse = await _apiService.getMe();
        _currentSession = meResponse.toSession().copyWith(
          isLoggedIn: true,
          accessToken: token,
          fullName: meResponse.fullName ?? cachedFullName,
          profilePic: meResponse.profilePic ?? cachedProfilePic,
          coverPic: meResponse.coverPic ?? cachedCoverPic,
          phoneNumber: meResponse.phoneNumber ?? cachedPhone,
          bio: meResponse.bio ?? cachedBio,
          location: meResponse.location ?? cachedLocation,
          emergencyContact: meResponse.emergencyContact ?? cachedEmergency,
        );
      } catch (e) {
        // Fallback to local session if network fails
        _currentSession = AuthSession(
          isLoggedIn: true,
          accessToken: token,
          fullName: cachedFullName ?? 'Tourist Explorer',
          profilePic: cachedProfilePic,
          coverPic: cachedCoverPic,
          phoneNumber: cachedPhone,
          bio: cachedBio,
          location: cachedLocation,
          emergencyContact: cachedEmergency,
        );
      }
    } else {
      _currentSession = AuthSession.loggedOut().copyWith(
        fullName: cachedFullName,
        profilePic: cachedProfilePic,
        coverPic: cachedCoverPic,
        phoneNumber: cachedPhone,
        bio: cachedBio,
        location: cachedLocation,
        emergencyContact: cachedEmergency,
      );
    }
    notifyListeners();
  }

  // ─── Authentication API Operations ────────────────────────────────────────

  /// Register a new account
  Future<AuthResponse?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockAuth) {
        await _mockService.sendEmailVerificationOtp(email);
        _setLoading(false);
        return AuthResponse(
          email: email,
          fullName: fullName,
          message: 'Mock registration complete. Verification OTP sent.',
        );
      }

      final response = await _apiService.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (response.token != null) {
        await _saveSession(response);
      }

      _setLoading(false);
      return response;
    } catch (e) {
      // If server is offline / unreachable, fallback to mock mode for smooth user registration
      if (e is ApiException &&
          (e.type == ApiExceptionType.timeout || e.type == ApiExceptionType.networkError)) {
        useMockAuth = true;
        await _mockService.sendEmailVerificationOtp(email);
        _currentSession = AuthSession(
          isLoggedIn: true,
          email: email,
          fullName: fullName,
          role: UserRole.tourist,
          isEmailVerified: false,
        );
        _setLoading(false);
        notifyListeners();
        return AuthResponse(
          email: email,
          fullName: fullName,
          message: 'Verification code sent.',
        );
      }
      _setError(_formatError(e));
      _setLoading(false);
      return null;
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockAuth) {
        final success = await _mockService.login(email, password);
        if (success) {
          _currentSession = AuthSession(
            isLoggedIn: true,
            email: email,
            fullName: 'Mock User',
            role: email.contains('admin') ? UserRole.admin : UserRole.tourist,
            isEmailVerified: _mockService.verificationStatusNotifier.value.isVerified,
          );
        }
        _setLoading(false);
        notifyListeners();
        return success;
      }

      final response = await _apiService.login(email: email, password: password);
      await _saveSession(response);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      if (e is ApiException &&
          (e.type == ApiExceptionType.timeout || e.type == ApiExceptionType.networkError)) {
        useMockAuth = true;
        final success = await _mockService.login(email, password);
        if (success) {
          _currentSession = AuthSession(
            isLoggedIn: true,
            email: email,
            fullName: 'Tourist User',
            role: email.contains('admin') ? UserRole.admin : UserRole.tourist,
            isEmailVerified: true,
          );
        }
        _setLoading(false);
        notifyListeners();
        return success;
      }
      _setError(_formatError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Verify email OTP
  Future<bool> verifyEmailOtp(String otp) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockAuth) {
        final success = await _mockService.verifyEmailOtp(_currentSession.email ?? '', otp);
        if (success) {
          _currentSession = _currentSession.copyWith(isEmailVerified: true);
        }
        _setLoading(false);
        notifyListeners();
        return success;
      }

      final response = await _apiService.verifyEmail(otp: otp);
      _currentSession = response.toSession().copyWith(
        accessToken: _currentSession.accessToken,
        isLoggedIn: true,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_formatError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Resend verification OTP
  Future<AuthResponse?> resendOtp() async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockAuth) {
        await _mockService.sendEmailVerificationOtp(_currentSession.email ?? '');
        _setLoading(false);
        return const AuthResponse(message: 'Verification code sent.');
      }

      final response = await _apiService.resendOtp();
      _setLoading(false);
      return response;
    } catch (e) {
      _setError(_formatError(e));
      _setLoading(false);
      return null;
    }
  }

  /// Request password reset OTP
  Future<AuthResponse?> forgotPassword({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockAuth) {
        await _mockService.sendPasswordResetOtp(email);
        _setLoading(false);
        return const AuthResponse(message: 'Password reset OTP sent.');
      }

      final response = await _apiService.forgotPassword(email: email);
      _setLoading(false);
      return response;
    } catch (e) {
      _setError(_formatError(e));
      _setLoading(false);
      return null;
    }
  }

  /// Finalize password reset with OTP
  Future<AuthResponse?> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockAuth) {
        await _mockService.resetPassword(email, newPassword);
        _setLoading(false);
        return const AuthResponse(message: 'Password reset complete.');
      }

      final response = await _apiService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      _setLoading(false);
      return response;
    } catch (e) {
      _setError(_formatError(e));
      _setLoading(false);
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
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
    _setLoading(true);
    _clearError();

    // Cache locally in SharedPreferences for offline support
    final prefs = await SharedPreferences.getInstance();
    if (fullName != null) await prefs.setString('user_full_name', fullName);
    if (profilePic != null) await prefs.setString('user_profile_pic', profilePic);
    if (coverPic != null) await prefs.setString('user_cover_pic', coverPic);
    if (phoneNumber != null) await prefs.setString('user_phone_number', phoneNumber);
    if (bio != null) await prefs.setString('user_bio', bio);
    if (location != null) await prefs.setString('user_location', location);
    if (emergencyContact != null) await prefs.setString('user_emergency_contact', emergencyContact);

    try {
      if (!useMockAuth) {
        final response = await _apiService.updateMe(
          fullName: fullName,
          preferences: preferences,
          savedDestinations: savedDestinations,
          profilePic: profilePic,
          coverPic: coverPic,
          phoneNumber: phoneNumber,
          bio: bio,
          location: location,
          emergencyContact: emergencyContact,
        );

        _currentSession = response.toSession().copyWith(
          accessToken: _currentSession.accessToken,
          isLoggedIn: true,
          profilePic: profilePic ?? _currentSession.profilePic,
          coverPic: coverPic ?? _currentSession.coverPic,
          phoneNumber: phoneNumber ?? _currentSession.phoneNumber,
          bio: bio ?? _currentSession.bio,
          location: location ?? _currentSession.location,
          emergencyContact: emergencyContact ?? _currentSession.emergencyContact,
        );
      } else {
        _currentSession = _currentSession.copyWith(
          fullName: fullName ?? _currentSession.fullName,
          preferenceProfile: preferences?['preferenceProfile'] as String? ?? _currentSession.preferenceProfile,
          profilePic: profilePic ?? _currentSession.profilePic,
          coverPic: coverPic ?? _currentSession.coverPic,
          phoneNumber: phoneNumber ?? _currentSession.phoneNumber,
          bio: bio ?? _currentSession.bio,
          location: location ?? _currentSession.location,
          emergencyContact: emergencyContact ?? _currentSession.emergencyContact,
        );
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      // Fallback local update even if API fails
      _currentSession = _currentSession.copyWith(
        fullName: fullName ?? _currentSession.fullName,
        preferenceProfile: preferences?['preferenceProfile'] as String? ?? _currentSession.preferenceProfile,
        profilePic: profilePic ?? _currentSession.profilePic,
        coverPic: coverPic ?? _currentSession.coverPic,
        phoneNumber: phoneNumber ?? _currentSession.phoneNumber,
        bio: bio ?? _currentSession.bio,
        location: location ?? _currentSession.location,
        emergencyContact: emergencyContact ?? _currentSession.emergencyContact,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    }
  }

  /// Update saved destination IDs on the backend
  Future<bool> updateSavedDestinations(List<String> savedDestinations) async {
    return await updateProfile(savedDestinations: savedDestinations);
  }

  /// Update user travel preference profile on the backend
  Future<bool> updatePreferenceProfile(String profile) async {
    return await updateProfile(preferences: {'preferenceProfile': profile});
  }

  /// Logout
  Future<void> logout() async {
    _setLoading(true);
    await _storageService.clearSession();
    _currentSession = AuthSession.loggedOut();
    _setLoading(false);
    notifyListeners();
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  Future<void> _saveSession(AuthResponse response) async {
    if (response.token != null) {
      await _storageService.saveAccessToken(response.token!);
    }
    if (response.userId != null) {
      await _storageService.saveSessionInfo(
        userId: response.userId!,
        email: response.email ?? '',
        role: response.role.value,
      );
    }
    _currentSession = response.toSession();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _formatError(dynamic e) {
    if (e is ApiException) {
      return e.message;
    }
    return e.toString();
  }
}
