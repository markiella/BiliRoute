// ─────────────────────────────────────────────────────────────────────────────
// AdminUser — Tourist user account model
// ─────────────────────────────────────────────────────────────────────────────

enum UserStatus { active, disabled, banned }

enum UserRole { tourist, researcher, admin }

class AdminUser {
  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.role,
    required this.dateRegistered,
    this.avatarAsset,
    this.savedRouteIds = const [],
    this.savedDestinationIds = const [],
    this.lastActiveAt,
    this.municipality,
    this.notes,
  });

  final String     id;
  String           name;
  String           email;
  UserStatus       status;
  UserRole         role;
  DateTime         dateRegistered;
  String?          avatarAsset;
  List<String>     savedRouteIds;
  List<String>     savedDestinationIds;
  DateTime?        lastActiveAt;
  String?          municipality;
  String?          notes;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String get statusLabel {
    switch (status) {
      case UserStatus.active:   return 'Active';
      case UserStatus.disabled: return 'Disabled';
      case UserStatus.banned:   return 'Banned';
    }
  }

  String get roleLabel {
    switch (role) {
      case UserRole.tourist:    return 'Tourist';
      case UserRole.researcher: return 'Researcher';
      case UserRole.admin:      return 'Admin';
    }
  }

  String get registeredDisplay {
    return '${dateRegistered.day.toString().padLeft(2, '0')}/'
           '${dateRegistered.month.toString().padLeft(2, '0')}/'
           '${dateRegistered.year}';
  }

  AdminUser copyWith({
    String?    name,
    String?    email,
    UserStatus? status,
    UserRole?  role,
    String?    municipality,
    String?    notes,
  }) => AdminUser(
    id:                  id,
    name:                name          ?? this.name,
    email:               email         ?? this.email,
    status:              status        ?? this.status,
    role:                role          ?? this.role,
    dateRegistered:      dateRegistered,
    avatarAsset:         avatarAsset,
    savedRouteIds:       savedRouteIds,
    savedDestinationIds: savedDestinationIds,
    lastActiveAt:        lastActiveAt,
    municipality:        municipality  ?? this.municipality,
    notes:               notes         ?? this.notes,
  );
}
