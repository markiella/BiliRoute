import '../models/admin_schedule.dart';
import 'base_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScheduleRepository — Transport departure schedule management
// ─────────────────────────────────────────────────────────────────────────────

import '../services/schedule_admin_api_service.dart';

class ScheduleRepository extends BaseRepository<AdminSchedule> {
  final ScheduleAdminApiService _apiService;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isUsingFallback = false;

  ScheduleRepository({ScheduleAdminApiService? apiService})
      : _apiService = apiService ?? ScheduleAdminApiService() {
    _seedSchedules();
    fetchSchedules();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingFallback => _isUsingFallback;

  void _seedSchedules() {
    seed(_seedData);
  }

  @override
  String idOf(AdminSchedule item) => item.id;

  @override
  AdminSchedule? getById(String id) {
    try {
      return items.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<AdminSchedule>> fetchSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawList = await _apiService.getSchedules();
      if (rawList.isNotEmpty) {
        final remoteSchedules = rawList.map((j) => AdminSchedule.fromBackendJson(j)).toList();
        seed(remoteSchedules);
        _isUsingFallback = false;
      }
    } catch (e) {
      _isUsingFallback = true;
      _errorMessage = 'Using cached static schedules ($e)';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return items;
  }

  Future<bool> createSchedule(AdminSchedule schedule) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.createSchedule(schedule.toBackendJson());
      if (res != null) {
        await fetchSchedules();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Failed to create schedule: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateScheduleApi(AdminSchedule schedule) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.updateSchedule(schedule.id, schedule.toBackendJson());
      if (res != null) {
        await fetchSchedules();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Failed to update schedule: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteSchedule(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ok = await _apiService.deleteSchedule(id);
      if (ok) {
        delete(id);
        await fetchSchedules();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete schedule: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  List<AdminSchedule> getActive() =>
      items.where((s) => s.status == ScheduleStatus.active).toList();

  List<AdminSchedule> forProvider(String providerId) =>
      items.where((s) => s.providerId == providerId).toList();

  List<AdminSchedule> forRoute(String routeId) =>
      items.where((s) => s.routeId == routeId).toList();

  void updateSchedule(AdminSchedule updated) {
    final idx = indexById(updated.id);
    if (idx == -1) return;
    updateAt(idx, updated);
  }

  static final List<AdminSchedule> _seedData = [
    AdminSchedule(
      id:           'sched-001',
      providerId:   'sp-004',
      providerName: 'Pedro Boat Services',
      routeId:      'route-sambawan-recommended',
      routeLabel:   'Kawayan Port → Sambawan Island',
      departureTimes: ['06:00', '08:00', '10:00'],
      operatingDays:  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      status:         ScheduleStatus.active,
      arrivalTime:    '~30 min after departure',
      lastTripNote:   'Last trip at 10:00 AM. Return by 3:00 PM.',
      isLastTripIndicator: true,
      notes:          'Subject to weather conditions. Book 1 day in advance.',
      dateAdded:      DateTime(2024, 6, 1),
    ),
    AdminSchedule(
      id:           'sched-002',
      providerId:   'sp-005',
      providerName: 'Lito\'s Sea Express',
      routeId:      'route-sambawan-recommended',
      routeLabel:   'Kawayan Port → Sambawan Island',
      departureTimes: ['07:00', '09:00'],
      operatingDays:  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      status:         ScheduleStatus.active,
      arrivalTime:    '~30 min after departure',
      lastTripNote:   'Last trip 9:00 AM. Not operating Sundays.',
      isLastTripIndicator: true,
      dateAdded:      DateTime(2024, 6, 1),
    ),
    AdminSchedule(
      id:           'sched-003',
      providerId:   'sp-001',
      providerName: 'Juan dela Cruz Transport',
      routeId:      'route-sambawan-recommended',
      routeLabel:   'Naval → Kawayan Port',
      departureTimes: ['05:00', '06:00', '07:00', '08:00', '10:00', '12:00', '14:00'],
      operatingDays:  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      status:         ScheduleStatus.active,
      arrivalTime:    '~45 min after departure',
      lastTripNote:   'Last multicab at 2:00 PM from Naval terminal.',
      isLastTripIndicator: true,
      dateAdded:      DateTime(2024, 6, 1),
    ),
    AdminSchedule(
      id:           'sched-004',
      providerId:   'sp-007',
      providerName: 'Maripipi Tourism Guides Cooperative',
      routeId:      'route-sambawan-recommended',
      routeLabel:   'Sambawan Island — Guided Tour',
      departureTimes: ['07:00'],
      operatingDays:  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      status:         ScheduleStatus.active,
      notes:          'Advance booking required. Contact at least 2 days before.',
      dateAdded:      DateTime(2024, 6, 1),
    ),
  ];
}
