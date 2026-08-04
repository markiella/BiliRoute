import '../models/admin_advisory.dart';
import 'base_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdvisoryRepository — Travel advisory management
// ─────────────────────────────────────────────────────────────────────────────

class AdvisoryRepository extends BaseRepository<AdminAdvisory> {
  AdvisoryRepository() {
    _seedAdvisories();
  }

  void _seedAdvisories() {
    seed(_seedData);
  }

  @override
  String idOf(AdminAdvisory item) => item.id;

  @override
  AdminAdvisory? getById(String id) {
    try {
      return items.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Active published advisories (used by mobile app banner).
  List<AdminAdvisory> getActive() =>
      items.where((a) => a.isActive).toList();

  List<AdminAdvisory> getPublished() =>
      items.where((a) => a.status == AdvisoryStatus.published).toList();

  List<AdminAdvisory> getDrafts() =>
      items.where((a) => a.status == AdvisoryStatus.draft).toList();

  List<AdminAdvisory> bySeverity(AdvisorySeverity sev) =>
      items.where((a) => a.severity == sev).toList();

  void updateAdvisory(AdminAdvisory updated) {
    final idx = indexById(updated.id);
    if (idx == -1) return;
    updateAt(idx, updated);
  }

  void publishAdvisory(String id, {String? publishedBy}) {
    final idx = indexById(id);
    if (idx == -1) return;
    updateAt(idx, items[idx].copyWith(
      status:      AdvisoryStatus.published,
      publishedBy: publishedBy,
    ));
  }

  // ── Dashboard stats ─────────────────────────────────────────────────────────

  int get activeCount => items.where((a) => a.isActive).length;

  static final List<AdminAdvisory> _seedData = [
    AdminAdvisory(
      id:          'adv-001',
      title:       'Sea Travel Advisory — Sambawan Island',
      description: 'Expect moderate waves (1.0–1.5m) in the Biliran Strait '
                   'during afternoon hours. Morning departures (6–9 AM) are '
                   'strongly recommended. All passengers must wear life vests '
                   'during the crossing.',
      category:    AdvisoryCategory.seaTravel,
      severity:    AdvisorySeverity.moderate,
      status:      AdvisoryStatus.published,
      startDate:   DateTime(2025, 6, 1),
      endDate:     DateTime(2025, 12, 31),
      affectedDestinationIds:   ['sambawan_island', 'higatangan_island'],
      affectedDestinationNames: ['Sambawan Island', 'Higatangan Island'],
      publishedBy: 'Biliran Tourism Office',
      dateAdded:   DateTime(2025, 6, 1),
    ),
    AdminAdvisory(
      id:          'adv-002',
      title:       'Biliran Tourism Week — June 2025',
      description: 'Biliran Province celebrates Tourism Week from June 15–21, 2025. '
                   'Expect increased tourist volume at major sites. '
                   'Advanced booking for boat charters and tour packages is strongly advised.',
      category:    AdvisoryCategory.festivalAdvisory,
      severity:    AdvisorySeverity.info,
      status:      AdvisoryStatus.published,
      startDate:   DateTime(2025, 6, 15),
      endDate:     DateTime(2025, 6, 21),
      publishedBy: 'Biliran Tourism Office',
      dateAdded:   DateTime(2025, 6, 10),
    ),
    AdminAdvisory(
      id:          'adv-003',
      title:       'Road Advisory — Caibiran Mountain Route',
      description: 'Road maintenance works along the Caibiran–Capoocan stretch. '
                   'Expect 30–45 minute delays from 8 AM – 4 PM on weekdays. '
                   'Alternative route via Naval–Biliran loop road recommended.',
      category:    AdvisoryCategory.roadConditions,
      severity:    AdvisorySeverity.moderate,
      status:      AdvisoryStatus.draft,
      startDate:   DateTime(2025, 7, 1),
      endDate:     DateTime(2025, 7, 31),
      affectedDestinationIds:   ['tinago_falls'],
      affectedDestinationNames: ['Tinago Falls'],
      dateAdded:   DateTime(2025, 6, 20),
    ),
  ];
}
