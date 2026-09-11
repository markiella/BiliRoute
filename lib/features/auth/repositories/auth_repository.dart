import 'package:flutter/foundation.dart';
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
    final token = await _storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        final meResponse = await _apiService.getMe();
        _currentSession = meResponse.toSession().copyWith(
          isLoggedIn: true,
          accessToken: token,
        );
      } catch (e) {
        // Token expired or server unreachable — clear session
        await _storageService.clearSession();
        _currentSession = AuthSession.loggedOut();
      }
    } else {
      _currentSession = AuthSession.loggedOut();
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
      _setError(e.toString());
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
      _setError(e.toString());
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
      _setError(e.toString());
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
        return const AuthResponse(message: 'Mock OTP sent.');
      }

      final response = await _apiService.resendOtp();
      _setLoading(false);
      return response;
    } catch (e) {
      _setError(e.toString());
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
        return const AuthResponse(message: 'Mock password reset OTP sent.');
      }

      final response = await _apiService.forgotPassword(email: email);
      _setLoading(false);
      return response;
    } catch (e) {
      _setError(e.toString());
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
        return const AuthResponse(message: 'Mock password reset complete.');
      }

      final response = await _apiService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      _setLoading(false);
      return response;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    Map<String, dynamic>? preferences,
    List<String>? savedDestinations,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.updateMe(
        fullName: fullName,
        preferences: preferences,
        savedDestinations: savedDestinations,
      );

      _currentSession = response.toSession().copyWith(
        accessToken: _currentSession.accessToken,
        isLoggedIn: true,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
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
}
