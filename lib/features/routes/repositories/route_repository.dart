import 'package:flutter/foundation.dart';
import '../../../data/models/destination_model.dart';
import '../../../data/transport/biliran_route_options.dart';
import '../../../data/transport/route_option.dart';
import '../../../data/transport/transport_provider_model.dart';
import '../../../data/transport/transport_schedule_model.dart';
import '../services/route_api_service.dart';
import '../services/transport_provider_api_service.dart';
import '../services/transport_schedule_api_service.dart';

/// TouristRouteRepository
/// Central state manager for route recommendations, transport providers, and schedules.
/// Implements API-first fetching with safe fallback to BiliranRouteOptions on network failure.
class TouristRouteRepository extends ChangeNotifier {
  final RouteApiService _routeApiService;
  final TransportProviderApiService _providerApiService;
  final TransportScheduleApiService _scheduleApiService;

  List<RouteOption> _routeOptions = [];
  List<TransportProviderModel> _providers = [];
  List<TransportScheduleModel> _schedules = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _isUsingFallback = false;

  TouristRouteRepository({
    RouteApiService? routeApiService,
    TransportProviderApiService? providerApiService,
    TransportScheduleApiService? scheduleApiService,
  })  : _routeApiService = routeApiService ?? RouteApiService(),
        _providerApiService = providerApiService ?? TransportProviderApiService(),
        _scheduleApiService = scheduleApiService ?? TransportScheduleApiService();

  // ─── Getters ───────────────────────────────────────────────────────────────

  List<RouteOption> get routeOptions => _routeOptions;
  List<TransportProviderModel> get providers => _providers;
  List<TransportScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingFallback => _isUsingFallback;

  // ─── Route Operations ──────────────────────────────────────────────────────

  /// Fetch routes for a destination from API with static fallback
  Future<List<RouteOption>> fetchRoutesForDestination({
    required DestinationItem destination,
    String? originName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final remoteRoutes = await _routeApiService.getRoutesForDestination(
        destinationId: destination.id,
        originName: originName,
      );

      if (remoteRoutes.isNotEmpty) {
        _routeOptions = remoteRoutes;
        _isUsingFallback = false;
      } else {
        // Fallback to static route options if API returns empty during migration
        _routeOptions = BiliranRouteOptions.forDestination(destination.title);
        _isUsingFallback = true;
      }
    } catch (e) {
      // API call failed (offline / backend down) — safe fallback to static options
      _routeOptions = BiliranRouteOptions.forDestination(destination.title);
      _isUsingFallback = true;
      _errorMessage = 'Using cached offline route options ($e)';
    } finally {
      _setLoading(false);
    }

    return _routeOptions;
  }

  /// Get single route by ID
  Future<RouteOption?> fetchRoute(String routeId) async {
    try {
      final remote = await _routeApiService.getRouteById(routeId);
      if (remote != null) return remote;
    } catch (_) {}

    // Fallback lookup
    try {
      return _routeOptions.firstWhere((r) => r.id == routeId);
    } catch (_) {
      return null;
    }
  }

  // ─── Provider Operations ───────────────────────────────────────────────────

  /// Fetch verified transport providers
  Future<List<TransportProviderModel>> fetchProviders({String? type}) async {
    _setLoading(true);
    _clearError();

    try {
      final remoteProviders = await _providerApiService.getVerifiedProviders(type: type);
      _providers = remoteProviders;
      _isUsingFallback = false;
    } catch (e) {
      _errorMessage = 'Unable to fetch transport providers ($e)';
      _isUsingFallback = true;
    } finally {
      _setLoading(false);
    }

    return _providers;
  }

  /// Get single transport provider by ID
  Future<TransportProviderModel?> fetchProvider(String providerId) async {
    try {
      return await _providerApiService.getProviderById(providerId);
    } catch (e) {
      _errorMessage = 'Unable to fetch provider details ($e)';
      return null;
    }
  }

  // ─── Schedule Operations ───────────────────────────────────────────────────

  /// Fetch departure schedules for a route step
  Future<List<TransportScheduleModel>> fetchSchedulesForRoute({
    required String routeId,
    String? providerId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final remoteSchedules = await _scheduleApiService.getSchedulesForRoute(
        routeId: routeId,
        providerId: providerId,
      );
      _schedules = remoteSchedules;
      _isUsingFallback = false;
    } catch (e) {
      _errorMessage = 'Unable to fetch transport schedules ($e)';
      _isUsingFallback = true;
    } finally {
      _setLoading(false);
    }

    return _schedules;
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
