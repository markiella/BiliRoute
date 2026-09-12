import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';
import 'auth_verification_service.dart';

/// RealApiVerificationService
/// Bridges [AuthVerificationService] to the real Node.js Express REST API backend via [AuthRepository].
class RealApiVerificationService implements AuthVerificationService {
  final AuthRepository _authRepository;
  String? _lastResetOtp;

  RealApiVerificationService({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository.instance;

  @override
  ValueNotifier<VerificationStatus> get verificationStatusNotifier {
    final session = _authRepository.currentSession;
    if (!session.isLoggedIn) {
      return ValueNotifier<VerificationStatus>(VerificationStatus.unverified);
    }
    return ValueNotifier<VerificationStatus>(
      session.isEmailVerified ? VerificationStatus.verified : VerificationStatus.pending,
    );
  }

  @override
  Future<bool> login(String email, String password) async {
    return await _authRepository.login(email: email, password: password);
  }

  @override
  Future<void> sendEmailVerificationOtp(String email) async {
    await _authRepository.resendOtp();
  }

  @override
  Future<bool> verifyEmailOtp(String email, String otp) async {
    return await _authRepository.verifyEmailOtp(otp);
  }

  @override
  Future<void> sendPasswordResetOtp(String email) async {
    await _authRepository.forgotPassword(email: email);
  }

  @override
  Future<bool> verifyPasswordResetOtp(String email, String otp) async {
    final cleanOtp = otp.trim();
    _lastResetOtp = cleanOtp;
    if (_authRepository.useMockAuth) {
      return cleanOtp == '654321';
    }
    return cleanOtp.length == 6;
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    final otp = _lastResetOtp ?? '123456';
    await _authRepository.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
