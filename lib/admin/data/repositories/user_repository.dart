import '../models/admin_user.dart';
import 'base_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserRepository — Tourist and researcher account management
// ─────────────────────────────────────────────────────────────────────────────

class UserRepository extends BaseRepository<AdminUser> {
  UserRepository() {
    _seedUsers();
  }

  void _seedUsers() {
    seed(_seedData);
  }

  @override
  String idOf(AdminUser item) => item.id;

  @override
  AdminUser? getById(String id) {
    try {
      return items.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  AdminUser? getByEmail(String email) {
    try {
      return items.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  List<AdminUser> getActive() =>
      items.where((u) => u.status == UserStatus.active).toList();

  List<AdminUser> search(String query) {
    final q = query.toLowerCase();
    return items
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            (u.municipality?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void updateUser(AdminUser updated) {
    final idx = indexById(updated.id);
    if (idx == -1) return;
    updateAt(idx, updated);
  }

  void disableUser(String id) {
    final idx = indexById(id);
    if (idx == -1) return;
    updateAt(idx, items[idx].copyWith(status: UserStatus.disabled));
  }

  void enableUser(String id) {
    final idx = indexById(id);
    if (idx == -1) return;
    updateAt(idx, items[idx].copyWith(status: UserStatus.active));
  }

  // ── Dashboard stats ─────────────────────────────────────────────────────────

  int get activeCount =>
      items.where((u) => u.status == UserStatus.active).length;
  int get totalCount => items.length;

  static final List<AdminUser> _seedData = [
    AdminUser(
      id:             'usr-001',
      name:           'Ana Maria Santos',
      email:          'ana.santos@email.com',
      status:         UserStatus.active,
      role:           UserRole.tourist,
      dateRegistered: DateTime(2025, 1, 10),
      municipality:   'Naval',
      savedDestinationIds: ['sambawan_island', 'agta_beach'],
    ),
    AdminUser(
      id:             'usr-002',
      name:           'Jose Dela Cruz',
      email:          'jose.delacruz@email.com',
      status:         UserStatus.active,
      role:           UserRole.tourist,
      dateRegistered: DateTime(2025, 2, 5),
      municipality:   'Tacloban City',
      savedDestinationIds: ['sambawan_island'],
      savedRouteIds: ['route-sambawan-recommended'],
    ),
    AdminUser(
      id:             'usr-003',
      name:           'Maria Reyes',
      email:          'maria.reyes@researcher.edu.ph',
      status:         UserStatus.active,
      role:           UserRole.researcher,
      dateRegistered: DateTime(2025, 1, 5),
      municipality:   'Naval',
      notes:          'BiliRoute thesis research team member',
    ),
    AdminUser(
      id:             'usr-004',
      name:           'Pedro Bautista',
      email:          'pedro.b@email.com',
      status:         UserStatus.active,
      role:           UserRole.tourist,
      dateRegistered: DateTime(2025, 3, 12),
      municipality:   'Cebu City',
      savedDestinationIds: ['sambawan_island', 'higatangan_island', 'dalutan_island'],
    ),
    AdminUser(
      id:             'usr-005',
      name:           'Gloria Fernandez',
      email:          'gloria.f@email.com',
      status:         UserStatus.disabled,
      role:           UserRole.tourist,
      dateRegistered: DateTime(2025, 2, 28),
      municipality:   'Ormoc City',
    ),
  ];
}
