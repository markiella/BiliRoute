import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminAuthRepository — Local admin session management
//
// Phase 2A: In-memory credential check (no Firebase yet).
// Phase 2B: Swap _verifyCredentials() to call Firebase Auth.
// ─────────────────────────────────────────────────────────────────────────────

enum AdminRole {
  superAdmin,
  tourismOfficer,
  contentManager,
  viewer;

  String get label {
    switch (this) {
      case AdminRole.superAdmin:      return 'Super Admin';
      case AdminRole.tourismOfficer:  return 'Tourism Officer';
      case AdminRole.contentManager:  return 'Content Manager';
      case AdminRole.viewer:          return 'Viewer';
    }
  }

  bool get canManageDestinations =>
      this == AdminRole.superAdmin || this == AdminRole.tourismOfficer;
  bool get canManageRoutes =>
      this == AdminRole.superAdmin || this == AdminRole.tourismOfficer;
  bool get canManageProviders =>
      this == AdminRole.superAdmin || this == AdminRole.tourismOfficer;
  bool get canManageGallery =>
      this != AdminRole.viewer;
  bool get canManageAdvisories =>
      this != AdminRole.viewer;
  bool get canManageUsers =>
      this == AdminRole.superAdmin;
  bool get canViewReports =>
      this != AdminRole.viewer;
  bool get canEditSettings =>
      this == AdminRole.superAdmin;
}

class AdminSession {
  const AdminSession({
    required this.adminId,
    required this.name,
    required this.email,
    required this.role,
    required this.loginAt,
  });

  final String    adminId;
  final String    name;
  final String    email;
  final AdminRole role;
  final DateTime  loginAt;
}

class AdminAuthRepository extends ChangeNotifier {
  AdminSession? _session;
  String?       _error;
  bool          _isLoading = false;

  AdminSession? get session    => _session;
  String?       get error      => _error;
  bool          get isLoading  => _isLoading;
  bool          get isLoggedIn => _session != null;

  AdminRole get currentRole => _session?.role ?? AdminRole.viewer;

  // ── Credentials store (Phase 2A — local only) ──────────────────────────────

  static const _credentials = <String, _AdminCredential>{
    'admin@biliroute.ph': _AdminCredential(
      adminId:  'admin-001',
      name:     'BiliRoute Admin',
      email:    'admin@biliroute.ph',
      password: 'biliroute2025',
      role:     AdminRole.superAdmin,
    ),
    'officer@biliroute.ph': _AdminCredential(
      adminId:  'admin-002',
      name:     'Tourism Officer',
      email:    'officer@biliroute.ph',
      password: 'officer2025',
      role:     AdminRole.tourismOfficer,
    ),
    'content@biliroute.ph': _AdminCredential(
      adminId:  'admin-003',
      name:     'Content Manager',
      email:    'content@biliroute.ph',
      password: 'content2025',
      role:     AdminRole.contentManager,
    ),
  };

  // ── Login ───────────────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate async network call (replace with Firebase Auth in Phase 2B)
    await Future.delayed(const Duration(milliseconds: 800));

    final credential = _credentials[email.toLowerCase().trim()];

    if (credential == null || credential.password != password) {
      _error = 'Invalid email or password.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _session = AdminSession(
      adminId: credential.adminId,
      name:    credential.name,
      email:   credential.email,
      role:    credential.role,
      loginAt: DateTime.now(),
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ── Logout ──────────────────────────────────────────────────────────────────

  void logout() {
    _session = null;
    _error   = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// ── Internal credential record (not exposed publicly) ─────────────────────────

class _AdminCredential {
  const _AdminCredential({
    required this.adminId,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
  final String    adminId;
  final String    name;
  final String    email;
  final String    password;
  final AdminRole role;
}
