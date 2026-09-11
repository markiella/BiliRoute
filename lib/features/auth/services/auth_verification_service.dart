import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VerificationStatus — Account Verification State
// Supports: pending, verified, suspended, unverified (future-ready)
// ─────────────────────────────────────────────────────────────────────────────

enum VerificationStatus {
  unverified,
  pending,
  verified,
  suspended;

  bool get isVerified => this == VerificationStatus.verified;
  bool get isPending => this == VerificationStatus.pending;
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthVerificationService — abstract interface
//
// All OTP / verification logic in BiliRoute flows through this interface so
// the UI layer is completely decoupled from the backend.
//
// FUTURE: Replace MockVerificationService with:
//   - FirebaseVerificationService (Firebase Auth + Cloud Functions)
//   - LaravelVerificationService  (custom REST API)
//   - SupabaseVerificationService
// ─────────────────────────────────────────────────────────────────────────────

abstract class AuthVerificationService {
  /// Reactive notifier for the current user's account verification status.
  ValueNotifier<VerificationStatus> get verificationStatusNotifier;

  /// Authenticate user credentials. Returns true on success, false on failure.
  Future<bool> login(String email, String password);

  /// Send a 6-digit OTP to [email] for email address verification.
  Future<void> sendEmailVerificationOtp(String email);

  /// Verify the OTP the user entered against the one sent to [email].
  /// Returns true if correct, false if wrong/expired.
  Future<bool> verifyEmailOtp(String email, String otp);

  /// Send a 6-digit password-reset OTP to [email].
  Future<void> sendPasswordResetOtp(String email);

  /// Verify the password-reset OTP.
  /// Returns true if correct, false if wrong/expired.
  Future<bool> verifyPasswordResetOtp(String email, String otp);

  /// Finalize a password reset for [email] with [newPassword].
  Future<void> resetPassword(String email, String newPassword);
}
