import '../../../data/transport/transport_route.dart';
import '../models/admin_provider.dart';
import 'base_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProviderRepository — Seeded from BiliranProviders
// ─────────────────────────────────────────────────────────────────────────────

class ProviderRepository extends BaseRepository<AdminProvider> {
  ProviderRepository() {
    _seedProviders();
  }

  void _seedProviders() {
    seed(_verifiedProviders);
  }

  // ── BaseRepository ──────────────────────────────────────────────────────────

  @override
  String idOf(AdminProvider item) => item.id;

  @override
  AdminProvider? getById(String id) {
    try {
      return items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Queries ─────────────────────────────────────────────────────────────────

  List<AdminProvider> getVerified() =>
      items.where((p) => p.status == ProviderStatus.verified).toList();

  List<AdminProvider> byCategory(ProviderCategory cat) =>
      items.where((p) => p.providerType == cat).toList();

  List<AdminProvider> byMunicipality(String municipality) => items
      .where((p) => p.municipality.toLowerCase() == municipality.toLowerCase())
      .toList();

  List<AdminProvider> search(String query) {
    final q = query.toLowerCase();
    return items
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.serviceArea.toLowerCase().contains(q) ||
            p.municipality.toLowerCase().contains(q))
        .toList();
  }

  void updateProvider(AdminProvider updated) {
    final idx = indexById(updated.id);
    if (idx == -1) return;
    updateAt(idx, updated);
  }

  void verifyProvider(String id, {required String verifiedBy}) {
    final idx = indexById(id);
    if (idx == -1) return;
    updateAt(idx, items[idx].copyWith(
      status:     ProviderStatus.verified,
      verifiedBy: verifiedBy,
      verifiedAt: DateTime.now(),
    ));
  }

  // ── Dashboard stats ─────────────────────────────────────────────────────────

  int get verifiedCount =>
      items.where((p) => p.status == ProviderStatus.verified).length;
  int get pendingCount =>
      items.where((p) => p.status == ProviderStatus.pending).length;

  // ── Seed data ────────────────────────────────────────────────────────────────

  static final List<AdminProvider> _verifiedProviders = [
    // Naval ↔ Kawayan (Land)
    AdminProvider(
      id:                       'sp-001',
      name:                     'Juan dela Cruz Transport',
      providerType:             ProviderCategory.multicabOperator,
      contactNumber:            '09171234567',
      municipality:             'Naval',
      serviceArea:              'Naval → Kawayan Port',
      compatibleTransportTypes: [TransportType.multicab, TransportType.van],
      status:                   ProviderStatus.verified,
      registrationCode:         'BTO-DRV-0001',
      availability:             'Daily 5:00 AM – 8:00 PM',
      operatingHours:           '5:00 AM – 8:00 PM',
      rating:                   4.8,
      verifiedBy:               'Biliran Tourism Office',
      verifiedAt:               DateTime(2024, 6, 1),
      dateAdded:                DateTime(2024, 1, 15),
    ),
    AdminProvider(
      id:                       'sp-002',
      name:                     'Maria Santos Van Service',
      providerType:             ProviderCategory.vanOperator,
      contactNumber:            '09209876543',
      municipality:             'Naval',
      serviceArea:              'Naval → Kawayan Port',
      compatibleTransportTypes: [TransportType.van, TransportType.multicab],
      status:                   ProviderStatus.verified,
      registrationCode:         'BTO-DRV-0002',
      availability:             'Daily 6:00 AM – 7:00 PM',
      operatingHours:           '6:00 AM – 7:00 PM',
      rating:                   4.7,
      verifiedBy:               'Biliran Tourism Office',
      verifiedAt:               DateTime(2024, 6, 1),
      dateAdded:                DateTime(2024, 1, 15),
    ),
    AdminProvider(
      id:                       'sp-003',
      name:                     'Reyes Multicab Services',
      providerType:             ProviderCategory.multicabOperator,
      contactNumber:            '09351122334',
      municipality:             'Naval',
      serviceArea:              'Naval → Kawayan Port',
      compatibleTransportTypes: [TransportType.multicab],
      status:                   ProviderStatus.verified,
      registrationCode:         'BTO-DRV-0003',
      availability:             'Daily 5:30 AM – 6:00 PM',
      rating:                   4.6,
      verifiedBy:               'Biliran Tourism Office',
      verifiedAt:               DateTime(2024, 6, 1),
      dateAdded:                DateTime(2024, 2, 1),
    ),
    // Kawayan ↔ Sambawan (Boat)
    AdminProvider(
      id:                       'sp-004',
      name:                     'Pedro Boat Services',
      providerType:             ProviderCategory.boatOperator,
      contactNumber:            '09175556677',
      municipality:             'Kawayan',
      serviceArea:              'Kawayan Port → Sambawan Island',
      compatibleTransportTypes: [TransportType.boatCharter, TransportType.boat],
      status:                   ProviderStatus.verified,
      registrationCode:         'BTO-BOT-0001',
      availability:             'Daily 6:00 AM – 3:00 PM (weather permitting)',
      operatingHours:           '6:00 AM – 3:00 PM',
      maxCapacity:              12,
      serviceNotes:             'Book at least 1 day in advance',
      rating:                   4.9,
      verifiedBy:               'Biliran Tourism Office',
      verifiedAt:               DateTime(2024, 6, 1),
      dateAdded:                DateTime(2024, 1, 20),
    ),
    AdminProvider(
      id:                       'sp-005',
      name:                     'Lito\'s Sea Express',
      providerType:             ProviderCategory.boatOperator,
      contactNumber:            '09334445566',
      municipality:             'Kawayan',
      serviceArea:              'Kawayan Port → Sambawan Island',
      compatibleTransportTypes: [TransportType.boatCharter, TransportType.boat],
      status:                   ProviderStatus.verified,
      registrationCode:         'BTO-BOT-0002',
      availability:             'Mon–Sat 7:00 AM – 2:00 PM',
      operatingHours:           '7:00 AM – 2:00 PM',
      maxCapacity:              10,
      serviceNotes:             'Capacity: 8–12 passengers',
      rating:                   4.7,
      verifiedBy:               'Biliran Tourism Office',
      verifiedAt:               DateTime(2024, 6, 1),
      dateAdded:                DateTime(2024, 1, 20),
    ),
    // Tour Guides
    AdminProvider(
      id:                       'sp-007',
      name:                     'Maripipi Tourism Guides Cooperative',
      providerType:             ProviderCategory.tourGuide,
      contactNumber:            '09181234567',
      municipality:             'Maripipi',
      serviceArea:              'Sambawan Island / Maripipi',
      compatibleTransportTypes: [],
      status:                   ProviderStatus.verified,
      registrationCode:         'BTO-GDE-0001',
      availability:             'Daily (advance booking required)',
      serviceNotes:             'Certified local tourism guides, 5+ years experience',
      rating:                   4.9,
      verifiedBy:               'Biliran Tourism Office',
      verifiedAt:               DateTime(2024, 3, 1),
      dateAdded:                DateTime(2024, 2, 10),
    ),
    // Habal-habal
    AdminProvider(
      id:                       'sp-009',
      name:                     'Almeria Habal-habal Association',
      providerType:             ProviderCategory.habalHabal,
      contactNumber:            '09197778899',
      municipality:             'Almeria',
      serviceArea:              'Almeria → Agta Beach / Ulan-Ulan Falls',
      compatibleTransportTypes: [TransportType.habalHabal],
      status:                   ProviderStatus.verified,
      registrationCode:         'BTO-HAB-0001',
      availability:             'Daily 6:00 AM – 5:00 PM',
      operatingHours:           '6:00 AM – 5:00 PM',
      serviceNotes:             'LTFRB-registered; helmet provided',
      rating:                   4.5,
      verifiedBy:               'Biliran Tourism Office',
      verifiedAt:               DateTime(2024, 4, 15),
      dateAdded:                DateTime(2024, 3, 1),
    ),
    // Pending (for admin demonstration)
    AdminProvider(
      id:                       'sp-010',
      name:                     'Caibiran Tricycle Operators',
      providerType:             ProviderCategory.tricycleDriver,
      contactNumber:            '09221112233',
      municipality:             'Caibiran',
      serviceArea:              'Caibiran → Mainit Hot Spring',
      compatibleTransportTypes: [TransportType.tricycle],
      status:                   ProviderStatus.pending,
      availability:             'Daily 7:00 AM – 6:00 PM',
      dateAdded:                DateTime(2025, 1, 10),
    ),
  ];
}
