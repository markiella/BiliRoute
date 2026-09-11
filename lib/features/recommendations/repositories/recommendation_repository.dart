import 'package:flutter/foundation.dart';
import '../../../data/models/destination_model.dart';
import '../../../data/transport/biliran_route_options.dart';
import '../../../data/transport/route_option.dart';
import '../services/recommendation_api_service.dart';

/// TouristRecommendationRepository
/// Central state manager for route recommendation queries.
/// Implements API-first recommendation fetching from backend recommendation engine
/// with safe fallback to BiliranRouteOptions on network failure or offline mode.
class TouristRecommendationRepository extends ChangeNotifier {
  final RecommendationApiService _apiService;

  List<RouteOption> _recommendedRoutes = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUsingFallback = false;
  String _activePreferenceProfile = 'recommended';

  TouristRecommendationRepository({RecommendationApiService? apiService})
      : _apiService = apiService ?? RecommendationApiService();

  // ─── Getters ───────────────────────────────────────────────────────────────

  List<RouteOption> get recommendedRoutes => _recommendedRoutes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingFallback => _isUsingFallback;
  String get activePreferenceProfile => _activePreferenceProfile;

  // ─── Operations ────────────────────────────────────────────────────────────

  /// Query route recommendations from backend recommendation engine
  Future<List<RouteOption>> fetchRecommendations({
    required DestinationItem destination,
    String originName = 'Naval',
    String preferenceProfile = 'recommended',
  }) async {
    _setLoading(true);
    _clearError();
    _activePreferenceProfile = preferenceProfile;

    try {
      final remoteRoutes = await _apiService.queryRecommendations(
        originName: originName,
        destinationId: destination.id,
        preferenceProfile: preferenceProfile,
      );

      if (remoteRoutes.isNotEmpty) {
        _recommendedRoutes = remoteRoutes;
        _isUsingFallback = false;
      } else {
        // Fallback to static route options if API returns empty
        _recommendedRoutes = BiliranRouteOptions.forDestination(destination.title);
        _isUsingFallback = true;
      }
    } catch (e) {
      // API call failed (offline / backend down) — safe fallback to static options
      _recommendedRoutes = BiliranRouteOptions.forDestination(destination.title);
      _isUsingFallback = true;
      _errorMessage = 'Using cached offline route recommendations ($e)';
    } finally {
      _setLoading(false);
    }

    return _recommendedRoutes;
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
