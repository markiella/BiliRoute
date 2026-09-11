import 'package:flutter/foundation.dart';
import 'auth_verification_service.dart';
import 'real_api_verification_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MockVerificationService
//
// Simulates email OTP verification and authentication without a real backend.
//
// Mock OTPs:
//   Email verification  → 123456
//   Password reset      → 654321
//
// All send methods succeed after artificial delays (simulates network).
// ─────────────────────────────────────────────────────────────────────────────

class MockVerificationService implements AuthVerificationService {
  static const _networkDelay = Duration(milliseconds: 1200);

  // ── Mock OTP values ────────────────────────────────────────────────────────
  static const _emailOtp         = '123456';
  static const _passwordResetOtp = '654321';

  // ── Reactive Verification Status ──────────────────────────────────────────
  @override
  final ValueNotifier<VerificationStatus> verificationStatusNotifier =
      ValueNotifier<VerificationStatus>(VerificationStatus.pending);

  @override
  Future<bool> login(String email, String password) async {
    await Future.delayed(_networkDelay);
    // Mock credential check
    if (email.toLowerCase().trim() == 'fail@biliroute.ph' || password == 'wrong') {
      return false;
    }
    return true;
  }

  @override
  Future<void> sendEmailVerificationOtp(String email) async {
    await Future.delayed(_networkDelay);
  }

  @override
  Future<bool> verifyEmailOtp(String email, String otp) async {
    await Future.delayed(_networkDelay);
    final isCorrect = otp.trim() == _emailOtp;
    if (isCorrect) {
      verificationStatusNotifier.value = VerificationStatus.verified;
    }
    return isCorrect;
  }

  @override
  Future<void> sendPasswordResetOtp(String email) async {
    await Future.delayed(_networkDelay);
  }

  @override
  Future<bool> verifyPasswordResetOtp(String email, String otp) async {
    await Future.delayed(_networkDelay);
    return otp.trim() == _passwordResetOtp;
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    await Future.delayed(_networkDelay);
  }
}

final AuthVerificationService authVerificationService =
    RealApiVerificationService();
