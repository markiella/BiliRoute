import 'package:flutter/foundation.dart';
import '../../../data/models/destination_model.dart';
import '../services/destination_api_service.dart';

/// TouristDestinationRepository
/// Manages tourist-facing destination data state for the Flutter application.
/// Uses API-first strategy (MongoDB backend) with graceful fallback to static data on network failure.
class TouristDestinationRepository extends ChangeNotifier {
  final DestinationApiService _apiService;

  List<DestinationItem> _destinations = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUsingFallback = false;

  TouristDestinationRepository({DestinationApiService? apiService})
      : _apiService = apiService ?? DestinationApiService() {
    fetchDestinations();
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  List<DestinationItem> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingFallback => _isUsingFallback;

  // ─── Actions ───────────────────────────────────────────────────────────────

  /// Fetch published destinations from REST API with fallback to static dataset
  Future<void> fetchDestinations({String? category, String? search}) async {
    _setLoading(true);
    _clearError();

    try {
      final remoteDestinations = await _apiService.getPublishedDestinations(
        category: category,
        search: search,
      );

      if (remoteDestinations.isNotEmpty) {
        _destinations = remoteDestinations;
        _isUsingFallback = false;
      } else {
        // Fallback to static list if API returned empty list during initial migration
        _destinations = allBiliranDestinations;
        _isUsingFallback = true;
      }
    } catch (e) {
      // API call failed (offline / backend down) — safe fallback to static list
      _destinations = allBiliranDestinations;
      _isUsingFallback = true;
      _errorMessage = 'Using cached offline data ($e)';
    } finally {
      _setLoading(false);
    }
  }

  /// Get single destination by slug
  Future<DestinationItem?> fetchDestinationBySlug(String slug) async {
    try {
      final remote = await _apiService.getDestinationBySlug(slug);
      if (remote != null) return remote;
    } catch (_) {}

    // Fallback lookup
    try {
      return allBiliranDestinations.firstWhere((d) => d.id == slug);
    } catch (_) {
      return null;
    }
  }

  /// Filter destinations by category
  Future<void> fetchDestinationsByCategory(String category) async {
    _setLoading(true);
    _clearError();

    try {
      final remote = await _apiService.getDestinationsByCategory(category);
      if (remote.isNotEmpty) {
        _destinations = remote;
        _isUsingFallback = false;
      } else {
        _destinations = allBiliranDestinations
            .where((d) => d.category.toLowerCase() == category.toLowerCase())
            .toList();
        _isUsingFallback = true;
      }
    } catch (e) {
      _destinations = allBiliranDestinations
          .where((d) => d.category.toLowerCase() == category.toLowerCase())
          .toList();
      _isUsingFallback = true;
      _errorMessage = 'Using cached offline data ($e)';
    } finally {
      _setLoading(false);
    }
  }

  /// Query nearby destinations by GeoJSON coordinates
  Future<void> fetchNearbyDestinations({
    required double latitude,
    required double longitude,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final remote = await _apiService.getNearbyDestinations(
        latitude: latitude,
        longitude: longitude,
      );
      if (remote.isNotEmpty) {
        _destinations = remote;
        _isUsingFallback = false;
      } else {
        _destinations = allBiliranDestinations;
        _isUsingFallback = true;
      }
    } catch (e) {
      _destinations = allBiliranDestinations;
      _isUsingFallback = true;
      _errorMessage = 'Using cached offline data ($e)';
    } finally {
      _setLoading(false);
    }
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
