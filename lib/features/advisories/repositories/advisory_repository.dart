import 'package:flutter/foundation.dart';
import '../../home/widgets/travel_advisory_section.dart';
import '../services/advisory_api_service.dart';

/// TouristAdvisoryRepository
/// Central state manager for travel advisories in the tourist application.
/// Implements API-first fetching from MongoDB REST API with static fallback to fallbackAdvisories.
class TouristAdvisoryRepository extends ChangeNotifier {
  final AdvisoryApiService _apiService;

  List<TravelAdvisory> _advisories = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUsingFallback = false;

  TouristAdvisoryRepository({AdvisoryApiService? apiService})
      : _apiService = apiService ?? AdvisoryApiService() {
    fetchActiveAdvisories();
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  /// Active & non-expired travel advisories
  List<TravelAdvisory> get advisories {
    final now = DateTime.now();
    final valid = _advisories.where((a) {
      if (!a.isActive) return false;
      if (a.expiresAt != null && a.expiresAt!.isBefore(now)) return false;
      return true;
    }).toList();

    return valid.isNotEmpty ? valid : fallbackAdvisories;
  }

  List<TravelAdvisory> get rawAdvisories => _advisories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingFallback => _isUsingFallback;

  // ─── Operations ────────────────────────────────────────────────────────────

  /// Fetch active advisories from REST API with static fallback
  Future<List<TravelAdvisory>> fetchActiveAdvisories({
    String? category,
    String? severity,
    String? destinationId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final remoteAdvisories = await _apiService.getActiveAdvisories(
        category: category,
        severity: severity,
        destinationId: destinationId,
      );

      if (remoteAdvisories.isNotEmpty) {
        _advisories = remoteAdvisories;
        _isUsingFallback = false;
      } else {
        _advisories = fallbackAdvisories;
        _isUsingFallback = true;
      }
    } catch (e) {
      _advisories = fallbackAdvisories;
      _isUsingFallback = true;
      _errorMessage = 'Using cached static travel advisories ($e)';
    } finally {
      _setLoading(false);
    }

    return advisories;
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
