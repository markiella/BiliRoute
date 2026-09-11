import '../models/field_survey_record.dart';
import '../services/field_survey_api_service.dart';
import 'base_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FieldSurveyRepository — Primary GPS data collection records
//
// Sambawan Island is seeded as the first BiliRoute-validated entry,
// using GPS coordinates collected during the researchers' on-site visit.
// ─────────────────────────────────────────────────────────────────────────────

class FieldSurveyRepository extends BaseRepository<FieldSurveyRecord> {
  final FieldSurveyApiService _apiService;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isUsingFallback = false;

  FieldSurveyRepository({FieldSurveyApiService? apiService})
      : _apiService = apiService ?? FieldSurveyApiService() {
    _seedSurveys();
    fetchSurveys();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingFallback => _isUsingFallback;

  void _seedSurveys() {
    seed(_seedData);
  }

  @override
  String idOf(FieldSurveyRecord item) => item.id;

  @override
  FieldSurveyRecord? getById(String id) {
    try {
      return items.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<FieldSurveyRecord> forDestination(String destinationId) =>
      items.where((s) => s.destinationId == destinationId).toList();

  List<FieldSurveyRecord> getValidated() =>
      items.where((s) => s.status == SurveyStatus.validated ||
                         s.status == SurveyStatus.published).toList();

  List<FieldSurveyRecord> getPending() =>
      items.where((s) => s.status == SurveyStatus.pending).toList();

  Future<List<FieldSurveyRecord>> fetchSurveys() async {
    _isLoading = true;
    notifyListeners();

    try {
      final remoteSurveys = await _apiService.getFieldSurveys();
      if (remoteSurveys.isNotEmpty) {
        seed(remoteSurveys);
        _isUsingFallback = false;
      }
    } catch (e) {
      _isUsingFallback = true;
      _errorMessage = 'Using cached field survey records ($e)';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return items;
  }

  Future<bool> approveSurvey(String id, {String? reviewNotes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.approveFieldSurvey(id, reviewNotes: reviewNotes);
      if (res != null) {
        validateRecord(id, validatedBy: 'Admin Reviewer');
        await fetchSurveys();
        return true;
      }
    } catch (e) {
      validateRecord(id, validatedBy: 'Admin (Offline)');
      _errorMessage = 'Approved locally ($e)';
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> rejectSurvey(String id, {String? reviewNotes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.rejectFieldSurvey(id, reviewNotes: reviewNotes);
      if (res != null) {
        final idx = indexById(id);
        if (idx != -1) {
          updateAt(idx, items[idx].copyWith(
            status: SurveyStatus.rejected,
            notes: reviewNotes,
          ));
        }
        await fetchSurveys();
        return true;
      }
    } catch (e) {
      final idx = indexById(id);
      if (idx != -1) {
        updateAt(idx, items[idx].copyWith(
          status: SurveyStatus.rejected,
          notes: reviewNotes,
        ));
      }
      _errorMessage = 'Rejected locally ($e)';
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void validateRecord(String id, {required String validatedBy}) {
    final idx = indexById(id);
    if (idx == -1) return;
    updateAt(idx, items[idx].copyWith(
      status:      SurveyStatus.validated,
      validatedBy: validatedBy,
      validatedAt: DateTime.now(),
    ));
  }

  void publishRecord(String id) {
    final idx = indexById(id);
    if (idx == -1) return;
    updateAt(idx, items[idx].copyWith(status: SurveyStatus.published));
  }

  void updateRecord(FieldSurveyRecord updated) {
    final idx = indexById(updated.id);
    if (idx == -1) return;
    updateAt(idx, updated);
  }

  // ── Dashboard stats ─────────────────────────────────────────────────────────

  int get validatedCount => getValidated().length;
  int get pendingCount   => getPending().length;

  // ── Seed data ────────────────────────────────────────────────────────────────

  static final List<FieldSurveyRecord> _seedData = [
    // ── Sambawan Island — First field-verified GPS record ─────────────────────
    // Source: BiliRoute Research Team on-site GPS survey
    // Coordinates: Primary data collected at Sambawan Island landing area
    FieldSurveyRecord(
      id:                'survey-001',
      destinationId:     'sambawan_island',
      destinationName:   'Sambawan Island',
      gpsLatitude:       11.766384941701004,
      gpsLongitude:      124.26429026111757,
      gpsAccuracyMeters: 4.2,
      surveyorName:      'BiliRoute Research Team',
      surveyDate:        DateTime(2025, 3, 15),
      municipality:      'Maripipi',
      barangay:          'Sambawan',
      status:            SurveyStatus.published,
      device:            GpsDevice.smartphone,
      deviceModel:       'Samsung Galaxy A54',
      observations:
          'GPS coordinates captured at the main landing dock of Sambawan Island. '
          'Clear weather, calm seas. Sandbar visible at full extent. '
          'No signal coverage on island — coordinates recorded at docking area.',
      weatherCondition:  'Sunny, calm seas (wave height 0.3–0.5m)',
      accessCondition:   'Accessible by boat from Kawayan Port (30 min)',
      photoEvidence:     ['assets/images/sambawan.jpg'],
      validatedBy:       'BiliRoute Research Adviser',
      validatedAt:       DateTime(2025, 3, 22),
      notes:
          'First field-verified GPS data point in the BiliRoute primary dataset. '
          'Used as the reference coordinate for route recommendation mapping.',
    ),
    // ── Agta Beach — Pending validation ───────────────────────────────────────
    FieldSurveyRecord(
      id:                'survey-002',
      destinationId:     'agta_beach',
      destinationName:   'Agta Beach',
      gpsLatitude:       11.8122,
      gpsLongitude:      124.3893,
      gpsAccuracyMeters: 8.5,
      surveyorName:      'BiliRoute Research Team',
      surveyDate:        DateTime(2025, 4, 10),
      municipality:      'Almeria',
      barangay:          'Agta',
      status:            SurveyStatus.pending,
      device:            GpsDevice.smartphone,
      observations:      'Estimated coordinates — pending on-site validation visit.',
      weatherCondition:  'Not yet surveyed',
      accessCondition:   'Accessible by multicab from Naval (45 min)',
      notes:             'Coordinates are estimated. Field visit scheduled for Q3 2025.',
    ),
  ];
}
