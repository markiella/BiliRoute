enum UserRole {
  tourist,
  admin;

  static UserRole fromString(String role) {
    if (role.toLowerCase() == 'admin') return UserRole.admin;
    return UserRole.tourist;
  }

  String get value => this == UserRole.admin ? 'admin' : 'tourist';
}

/// AuthSession
/// State model representing the current user's authenticated session in Flutter.
class AuthSession {
  final bool isLoggedIn;
  final String? accessToken;
  final String? userId;
  final String? fullName;
  final String? email;
  final UserRole role;
  final bool isEmailVerified;
  final List<String> savedDestinations;
  final String preferenceProfile;
  final String? profilePic;
  final String? coverPic;
  final String? phoneNumber;
  final String? bio;
  final String? location;
  final String? emergencyContact;

  const AuthSession({
    this.isLoggedIn = false,
    this.accessToken,
    this.userId,
    this.fullName,
    this.email,
    this.role = UserRole.tourist,
    this.isEmailVerified = false,
    this.savedDestinations = const [],
    this.preferenceProfile = 'recommended',
    this.profilePic,
    this.coverPic,
    this.phoneNumber,
    this.bio,
    this.location,
    this.emergencyContact,
  });

  /// Factory for an unauthenticated (logged out) state
  factory AuthSession.loggedOut() {
    return const AuthSession(isLoggedIn: false);
  }

  /// Convenience getters
  bool get isAdmin => isLoggedIn && role == UserRole.admin;
  bool get isTourist => isLoggedIn && role == UserRole.tourist;
  bool get needsEmailVerification => isLoggedIn && !isEmailVerified;

  AuthSession copyWith({
    bool? isLoggedIn,
    String? accessToken,
    String? userId,
    String? fullName,
    String? email,
    UserRole? role,
    bool? isEmailVerified,
    List<String>? savedDestinations,
    String? preferenceProfile,
    String? profilePic,
    String? coverPic,
    String? phoneNumber,
    String? bio,
    String? location,
    String? emergencyContact,
  }) {
    return AuthSession(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      savedDestinations: savedDestinations ?? this.savedDestinations,
      preferenceProfile: preferenceProfile ?? this.preferenceProfile,
      profilePic: profilePic ?? this.profilePic,
      coverPic: coverPic ?? this.coverPic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }
}
