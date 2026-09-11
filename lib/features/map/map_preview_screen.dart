import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/transitions/transition_data.dart';
import '../../../data/models/destination_model.dart';
import '../../../widgets/ambient/ambient_glow.dart';
import '../destinations/repositories/destination_repository.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

enum _SpotCategory {
  beach,
  waterfall,
  island,
  mountain,
  culture;

  String get label {
    switch (this) {
      case _SpotCategory.beach:     return 'Beach';
      case _SpotCategory.waterfall: return 'Waterfall';
      case _SpotCategory.island:    return 'Island';
      case _SpotCategory.mountain:  return 'Mountain';
      case _SpotCategory.culture:   return 'Culture';
    }
  }

  Color get color {
    switch (this) {
      case _SpotCategory.beach:     return const Color(0xFF3B82F6); // ocean blue
      case _SpotCategory.waterfall: return const Color(0xFF06B6D4); // cyan
      case _SpotCategory.island:    return const Color(0xFF0D9488); // teal
      case _SpotCategory.mountain:  return const Color(0xFF10B981); // green
      case _SpotCategory.culture:   return const Color(0xFFF97316); // orange
    }
  }

  IconData get icon {
    switch (this) {
      case _SpotCategory.beach:     return Icons.beach_access_rounded;
      case _SpotCategory.waterfall: return Icons.water_rounded;
      case _SpotCategory.island:    return Icons.holiday_village_rounded;
      case _SpotCategory.mountain:  return Icons.terrain_rounded;
      case _SpotCategory.culture:   return Icons.museum_rounded;
    }
  }

  double get markerHue {
    switch (this) {
      case _SpotCategory.beach:     return BitmapDescriptor.hueBlue;
      case _SpotCategory.waterfall: return BitmapDescriptor.hueCyan;
      case _SpotCategory.island:    return BitmapDescriptor.hueGreen;
      case _SpotCategory.mountain:  return BitmapDescriptor.hueGreen;
      case _SpotCategory.culture:   return BitmapDescriptor.hueOrange;
    }
  }
}

/// A Biliran tourist destination with full metadata for the map UI.
class _Destination {
  const _Destination({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.position,
    required this.category,
    required this.fare,
    required this.duration,
    required this.providers,
    required this.advisoryLevel, // 0=none 1=info 2=moderate 3=high
    this.isHiddenGem = false,
    this.imageAsset,
  });

  final String         id;
  final String         name;
  final String         tagline;
  final String         description;
  final LatLng         position;
  final _SpotCategory  category;
  final String         fare;
  final String         duration;
  final int            providers;
  final int            advisoryLevel;
  final bool           isHiddenGem;
  final String?        imageAsset;
}

/// A single leg in the route summary panel.
class _RouteLeg {
  const _RouteLeg({
    required this.from,
    required this.to,
    required this.transport,
    required this.duration,
    required this.fare,
    required this.icon,
    this.isSea = false,
  });
  final String   from;
  final String   to;
  final String   transport;
  final String   duration;
  final String   fare;
  final IconData icon;
  final bool     isSea;
}

// Destination dataset is loaded dynamically from TouristDestinationRepository (MongoDB REST API)

// Route waypoints, legs, and metadata are calculated dynamically from active API destinations and live device GPS coordinates

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Premium interactive tourism exploration map for BiliRoute.
///
/// Features:
///   • Google Maps base tiles (real satellite/terrain view)
///   • Custom animated destination markers with category color-coding
///   • Tappable destination preview cards with glassmorphism design
///   • Animated polyline drawing (land = solid glow, sea = dashed)
///   • Floating quick-action buttons (Locate Me, Routes, Advisory, Explore)
///   • Static map advisory overlays (rain, waves, landslide)
///   • Smart system status chip (simulated AI feedback)
///   • Expandable route summary panel with full leg breakdown
///   • Hidden Gem badges for discoverable spots
///
/// PROTOTYPE: All data is static mock. No live APIs required.
class MapPreviewScreen extends StatefulWidget {
  const MapPreviewScreen({super.key, this.navClearance = 0});
  final double navClearance;

  @override
  State<MapPreviewScreen> createState() => _MapPreviewScreenState();
}

class _MapPreviewScreenState extends State<MapPreviewScreen>
    with TickerProviderStateMixin {

  GoogleMapController? _mapController;

  final Set<Marker>   _markers   = {};
  final Set<Polyline> _polylines = {};

  bool _mapReady      = false;
  bool _mapError      = false;
  bool _panelExpanded = false;
  bool _showRoutes    = true;

  // Real GPS Location Service & position state
  final LocationService _locationService = LocationService();
  Position? _userPosition;
  StreamSubscription<Position>? _positionStreamSub;
  BitmapDescriptor? _userLocationIcon;

  // Dynamic REST API destinations state (from TouristDestinationRepository / MongoDB)
  List<_Destination> _activeDestinations = [];

  // Selected destination (null = none)
  _Destination? _selectedDestination;

  // Current per-destination route points
  List<LatLng> _currentRoutePoints = [];
  bool         _showNavChip        = false;

  // Map style JSON
  String? _mapStyleJson;

  // Hybrid / satellite map mode
  MapType _mapType    = MapType.normal;
  bool    _hybridMode = false;

  // Sea glow alpha (driven by _pulseController for shimmer)
  double _seaGlowAlpha = 0.0;

  // Pre-built icon cache: id → (normalIcon, selectedIcon)
  final Map<String, BitmapDescriptor> _normalIcons   = {};
  final Map<String, BitmapDescriptor> _selectedIcons = {};

  // Quick action active states
  bool _locateActive  = false;
  bool _routesActive  = false;  // starts clean (no full overview route)

  // Smart status chip
  String _statusText = 'Exploring Biliran destinations...';
  int    _statusIndex = 0;

  // Animation controllers
  late final AnimationController _panelController;
  late final AnimationController _pulseController;     // marker pulse + sea glow
  late final AnimationController _waveController;      // sea wave shimmer
  late final AnimationController _statusController;    // status chip fade
  late final AnimationController _routeTravelCtrl;     // travel dot along route

  static const _statusMessages = [
    'Exploring Biliran destinations...',
    'Checking sea route availability...',
    'Analyzing nearby attractions...',
    'Verifying local providers...',
    'Computing optimal travel paths...',
  ];

  static const _initialCamera = CameraPosition(
    target:  LatLng(11.5900, 124.3400),
    zoom:    11.2,
    tilt:    40.0,
    bearing: 10.0,
  );

  @override
  void initState() {
    super.initState();

    _panelController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 380),
    );

    _pulseController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Drive sea glow alpha from pulse controller
    _pulseController.addListener(() {
      if (mounted && _currentRoutePoints.isNotEmpty) {
        setState(() => _seaGlowAlpha = _pulseController.value);
      }
    });

    _waveController = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _statusController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
      value:    1.0,
    );

    _routeTravelCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 8),
    );

    _startStatusCycle();
    _loadMapStyle();

    // Check & request phone location on init
    _initUserLocation();

    if (kIsWeb) {
      setState(() => _mapReady = true);
    } else {
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted && !_mapReady) setState(() => _mapError = true);
      });
    }
  }

  /// Initializes device location and requests GPS permissions
  Future<void> _initUserLocation({bool userInitiated = false}) async {
    _userLocationIcon ??= await _buildUserLocationMarker();

    final result = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (result.isSuccess && result.position != null) {
      final pos = result.position!;
      setState(() {
        _userPosition = pos;
        _updateUserMarker(pos);
      });

      // Center map on actual phone location if requested or initial launch
      final userLatLng = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: userLatLng,
            zoom: 14.5,
            tilt: 30.0,
          ),
        ),
      );

      _subscribeToPositionStream();
    } else {
      // Show user-facing feedback banner/snackbar (no mock fallback!)
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location unavailable: ${result.message}'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _initUserLocation(userInitiated: true),
            ),
          ),
        );
      }
    }
  }

  /// Subscribes to Geolocator position stream for live movement updates
  void _subscribeToPositionStream() {
    _positionStreamSub?.cancel();
    _positionStreamSub = _locationService.getPositionStream().listen(
      (Position position) {
        if (!mounted) return;
        setState(() {
          _userPosition = position;
          _updateUserMarker(position);
        });
      },
      onError: (_) {},
    );
  }

  /// Adds or updates the User Location marker on the map
  void _updateUserMarker(Position position) {
    if (_userLocationIcon == null) return;
    const userMarkerId = MarkerId('user_location');
    final userLatLng = LatLng(position.latitude, position.longitude);

    _markers.removeWhere((m) => m.markerId == userMarkerId);
    _markers.add(
      Marker(
        markerId: userMarkerId,
        position: userLatLng,
        icon: _userLocationIcon!,
        anchor: const Offset(0.5, 0.5),
        zIndexInt: 10,
        infoWindow: const InfoWindow(title: 'Your Current Location'),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDestinationsFromRepo();
  }

  void _syncDestinationsFromRepo() {
    final repo = context.watch<TouristDestinationRepository>();
    final items = repo.destinations.isNotEmpty
        ? repo.destinations
        : allBiliranDestinations;

    final mapped = items.map((item) => _destinationFromItem(item)).toList();

    if (mapped.length != _activeDestinations.length ||
        !_areDestinationsEqual(_activeDestinations, mapped)) {
      _activeDestinations = mapped;
      if (_mapReady) {
        _runMapAnimations();
      }
    }
  }

  static bool _areDestinationsEqual(List<_Destination> a, List<_Destination> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  static _Destination _destinationFromItem(DestinationItem item) {
    return _Destination(
      id: item.id,
      name: item.title,
      tagline: '${item.category} · ${item.municipality}',
      description: item.description,
      position: LatLng(item.lat, item.lng),
      category: _parseSpotCategory(item.category),
      fare: item.estimatedFare > 0 ? '₱ ${item.estimatedFare}' : '₱ Free',
      duration: item.travelTime.isNotEmpty ? item.travelTime : '—',
      providers: 3,
      advisoryLevel: 0,
      isHiddenGem: !item.isFieldVerified,
      imageAsset: item.imageAsset,
    );
  }

  static _SpotCategory _parseSpotCategory(String catStr) {
    switch (catStr.toLowerCase()) {
      case 'beach':
        return _SpotCategory.beach;
      case 'waterfall':
      case 'falls':
        return _SpotCategory.waterfall;
      case 'island':
        return _SpotCategory.island;
      case 'mountain':
      case 'forest':
        return _SpotCategory.mountain;
      case 'culture':
      case 'historical':
      default:
        return _SpotCategory.culture;
    }
  }

  Future<void> _loadMapStyle() async {
    if (kIsWeb) return;
    try {
      final json = await rootBundle.loadString('assets/map_style.json');
      if (mounted) setState(() => _mapStyleJson = json);
    } catch (_) { /* fail silently — use default style */ }
  }

  void _startStatusCycle() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      // Fade out
      await _statusController.animateTo(0,
          duration: const Duration(milliseconds: 300));
      if (!mounted) return false;
      setState(() {
        _statusIndex = (_statusIndex + 1) % _statusMessages.length;
        _statusText  = _statusMessages[_statusIndex];
      });
      // Fade in
      await _statusController.animateTo(1,
          duration: const Duration(milliseconds: 300));
      return mounted;
    });
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _mapController?.dispose();
    _panelController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _statusController.dispose();
    _routeTravelCtrl.dispose();
    super.dispose();
  }

  // ── Custom marker builder ────────────────────────────────────────────────────

  /// Draws a premium round marker.
  /// [isSelected] = true → larger circle + bold white glow ring.
  static Future<BitmapDescriptor> _buildCustomMarker(
    _SpotCategory cat, {
    bool isSelected = false,
  }) async {
    final r        = isSelected ? 36.0 : 30.0;  // circle radius
    final size     = isSelected ? 100.0 : 88.0; // canvas size
    const iconSize = 22.0;

    final recorder = ui.PictureRecorder();
    final canvas   = Canvas(recorder);

    // ── Drop shadow ──────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(size / 2, r + 4),
      r,
      Paint()
        ..color      = Colors.black.withValues(alpha: isSelected ? 0.32 : 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSelected ? 10 : 6),
    );

    // ── Outer glow ring (selected only) ─────────────────────────────────────
    if (isSelected) {
      canvas.drawCircle(
        Offset(size / 2, r),
        r + 7,
        Paint()
          ..color      = cat.color.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // ── Filled circle ────────────────────────────────────────────────────────
    final circleCenter = Offset(size / 2, r);
    canvas.drawCircle(
      circleCenter,
      r,
      Paint()..color = cat.color,
    );

    // ── White ring ───────────────────────────────────────────────────────────
    canvas.drawCircle(
      circleCenter,
      r,
      Paint()
        ..color       = Colors.white.withValues(alpha: isSelected ? 0.75 : 0.35)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3.5 : 2.5,
    );

    // ── Icon via TextPainter ─────────────────────────────────────────────────
    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text:  String.fromCharCode(cat.icon.codePoint),
      style: TextStyle(
        fontSize:   iconSize,
        fontFamily: cat.icon.fontFamily,
        package:    cat.icon.fontPackage,
        color:      Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - iconPainter.width / 2,
        circleCenter.dy - iconPainter.height / 2,
      ),
    );

    // ── Pin tail ─────────────────────────────────────────────────────────────
    final path = Path()
      ..moveTo(size / 2 - 6, r * 1.75)
      ..lineTo(size / 2 + 6, r * 1.75)
      ..lineTo(size / 2,     r * 2.05)
      ..close();
    canvas.drawPath(path, Paint()..color = cat.color);

    // ── White dot at pin tip ─────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(size / 2, r * 2.10),
      3.5,
      Paint()..color = Colors.white.withValues(alpha: 0.80),
    );

    final picture = recorder.endRecording();
    final image   = await picture.toImage(size.toInt(), (r * 2.2 + 8).toInt());
    final bytes   = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Draws a distinct blue pulsing dot marker for the User's Current GPS Location
  static Future<BitmapDescriptor> _buildUserLocationMarker() async {
    const size = 64.0;
    const center = Offset(size / 2, size / 2);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Outer soft blue glow
    canvas.drawCircle(
      center,
      26.0,
      Paint()
        ..color = const Color(0xFF2563EB).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // White outer ring
    canvas.drawCircle(
      center,
      18.0,
      Paint()..color = Colors.white,
    );

    // Core royal blue dot
    canvas.drawCircle(
      center,
      12.0,
      Paint()..color = const Color(0xFF2563EB),
    );

    // Center pulse dot
    canvas.drawCircle(
      center,
      4.0,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  // ── Map lifecycle ────────────────────────────────────────────────────────────

  void _onMapCreated(GoogleMapController c) {
    _mapController = c;
    setState(() => _mapReady = true);
    _runMapAnimations();
    if (_userPosition != null) {
      _updateUserMarker(_userPosition!);
    } else {
      _initUserLocation();
    }
  }

  // Compute bearing (degrees) from LatLng a → b
  static double _bearing(LatLng a, LatLng b) {
    final lat1 = a.latitude  * math.pi / 180;
    final lat2 = b.latitude  * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;
    final y    = math.sin(dLng) * math.cos(lat2);
    final x    = math.cos(lat1) * math.sin(lat2) -
                 math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  Future<void> _runMapAnimations() async {
    // Build both normal + selected icon variants for each category up-front
    final categoryIcons = <_SpotCategory, BitmapDescriptor>{};
    final categorySelectedIcons = <_SpotCategory, BitmapDescriptor>{};
    for (final cat in _SpotCategory.values) {
      categoryIcons[cat]         = await _buildCustomMarker(cat);
      categorySelectedIcons[cat] = await _buildCustomMarker(cat, isSelected: true);
    }

    _normalIcons.clear();
    _selectedIcons.clear();

    setState(() {
      _markers.removeWhere((m) => m.markerId.value != 'user_location');
    });

    // Stagger markers with custom icons
    for (int i = 0; i < _activeDestinations.length; i++) {
      if (!mounted) return;
      final dest = _activeDestinations[i];
      final icon = categoryIcons[dest.category]!;
      final selectedIcon = categorySelectedIcons[dest.category]!;
      _normalIcons[dest.id]   = icon;
      _selectedIcons[dest.id] = selectedIcon;
      if (!mounted) return;
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(dest.id),
          position: dest.position,
          icon:     icon,
          anchor:   const Offset(0.5, 0.92),
          onTap:    () => _selectDestination(dest),
        ));
      });
    }
    // Map starts clean — no full route on load
  }

  // ── Per-destination route drawing ────────────────────────────────────────────

  /// Animates route polyline from user position / origin → [dest], then flies camera to fit.
  Future<void> _drawRouteToDestination(_Destination dest) async {
    final List<LatLng> points = [];

    if (_userPosition != null) {
      points.add(LatLng(_userPosition!.latitude, _userPosition!.longitude));
      points.add(dest.position);
    } else {
      points.add(const LatLng(11.5602, 124.3973));
      points.add(dest.position);
    }

    if (points.length < 2) return;
    final seaStart = dest.category == _SpotCategory.island ? 1 : null;

    final List<LatLng> growing = [];
    setState(() {
      _polylines.clear();
      _currentRoutePoints = [];
      _showNavChip = false;
    });

    // Step 1 — cinematic zoom to destination / route midpoint
    final startPt = points.first;
    final bear = _bearing(startPt, dest.position);
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target:  LatLng(
          (startPt.latitude  + dest.position.latitude)  / 2,
          (startPt.longitude + dest.position.longitude) / 2,
        ),
        zoom:    11.5,
        tilt:    45.0,
        bearing: bear,
      )),
    );

    // Step 2 — animate route point by point
    for (int i = 0; i < points.length; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (!mounted) return;
      growing.add(points[i]);

      // Decide land vs sea based on seaStart index
      final isSea = seaStart != null && i >= seaStart;

      setState(() {
        _polylines.clear();
        // Land portion — glow (wide, low alpha) + solid line
        final landEnd = seaStart != null
            ? math.min(growing.length, seaStart + 1)
            : growing.length;
        if (landEnd > 1) {
          // Soft glow layer
          _polylines.add(Polyline(
            polylineId: const PolylineId('land_glow'),
            points:     growing.sublist(0, landEnd),
            color:      const Color(0xFF3B82F6).withValues(alpha: 0.22),
            width:      14,
            jointType:  JointType.round,
            startCap:   Cap.roundCap,
            endCap:     Cap.roundCap,
          ));
          // Core land line
          _polylines.add(Polyline(
            polylineId: const PolylineId('land'),
            points:     growing.sublist(0, landEnd),
            color:      const Color(0xFF1E40AF),
            width:      6,
            jointType:  JointType.round,
            startCap:   Cap.roundCap,
            endCap:     Cap.roundCap,
          ));
        }
        // Sea portion — glow + dashed cyan
        if (seaStart != null && growing.length > seaStart) {
          final seaPts = growing.sublist(seaStart);
          // Sea glow (wide, pulsing via _seaGlowAlpha)
          _polylines.add(Polyline(
            polylineId: const PolylineId('sea_glow'),
            points:     seaPts,
            color:      const Color(0xFF06B6D4)
                .withValues(alpha: 0.12 + _seaGlowAlpha * 0.22),
            width:      18,
            jointType:  JointType.round,
            startCap:   Cap.roundCap,
            endCap:     Cap.roundCap,
          ));
          // Dashed cyan sea line
          _polylines.add(Polyline(
            polylineId: const PolylineId('sea'),
            points:     seaPts,
            color:      const Color(0xFF06B6D4),
            width:      5,
            patterns:   [PatternItem.dash(20), PatternItem.gap(10)],
            startCap:   Cap.roundCap,
            endCap:     Cap.roundCap,
          ));
        }
        if (isSea) {} // suppress unused warning
      });
    }

    if (!mounted) return;

    // Step 3 — fit camera to route bounds
    final bounds = _boundsFromLatLngs(points);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );

    // Step 4 — tilt slightly for depth after fit
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final midLat = (bounds.northeast.latitude  + bounds.southwest.latitude)  / 2;
    final midLng = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target:  LatLng(midLat, midLng),
        zoom:    _hybridMode ? 12.5 : 12.0,
        tilt:    _hybridMode ? 48.0 : 38.0,
        bearing: bear * 0.4,
      )),
    );

    // Step 5 — show nav chip and start travel dot
    setState(() {
      _currentRoutePoints = List.from(points);
      _showNavChip        = true;
    });
    _routeTravelCtrl.repeat();
  }

  /// Computes a tight LatLngBounds from a list of points.
  static LatLngBounds _boundsFromLatLngs(List<LatLng> pts) {
    double minLat = pts[0].latitude,  maxLat = pts[0].latitude;
    double minLng = pts[0].longitude, maxLng = pts[0].longitude;
    for (final p in pts) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // ── Destination selection ────────────────────────────────────────────────────

  /// Rebuilds the marker set with [dest.id] shown in selected state.
  void _applySelectedMarkerState(String? selectedId) {
    if (_normalIcons.isEmpty) return;
    final hasSelection = selectedId != null;
    setState(() {
      _markers.removeWhere((m) => m.markerId.value != 'user_location');
      for (final dest in _activeDestinations) {
        final isSelected = dest.id == selectedId;
        // Dim non-selected markers when one is active
        final alpha = hasSelection && !isSelected ? 0.38 : 1.0;
        _markers.add(Marker(
          markerId:  MarkerId(dest.id),
          position:  dest.position,
          icon:      isSelected
              ? (_selectedIcons[dest.id] ?? _normalIcons[dest.id]!)
              : _normalIcons[dest.id]!,
          anchor:    const Offset(0.5, 0.92),
          alpha:     alpha,
          zIndexInt: isSelected ? 1 : 0,
          onTap:     () => _selectDestination(dest),
        ));
      }

      // Preserve User Location marker on map rebuild
      if (_userPosition != null) {
        _updateUserMarker(_userPosition!);
      }
    });
  }

  void _selectDestination(_Destination dest) {
    HapticFeedback.mediumImpact();
    _applySelectedMarkerState(dest.id);
    setState(() => _selectedDestination = dest);

    // Draw per-destination animated route
    _drawRouteToDestination(dest);

    // Build shared-transition payload for the hero image flow
    final payload = TransitionPayload.fromDestination(
      id:         dest.id,
      name:       dest.name,
      imageAsset: dest.imageAsset,
    );

    // Show the premium bottom sheet modal
    showModalBottomSheet<void>(
      context:          context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor:    Colors.black.withValues(alpha: 0.45),
      isDismissible:   true,
      enableDrag:      true,
      useSafeArea:     false,
      builder: (_) => _DestinationModal(
        destination:  dest,
        onViewRoutes: () {
          Navigator.of(context).pop();
          context.push(
            AppRouter.routeSelection,
            extra: payload,
          );
        },
      ),
    ).then((_) => _clearSelection());
  }

  void _clearSelection() {
    _applySelectedMarkerState(null);
    _routeTravelCtrl.stop();
    _routeTravelCtrl.reset();
    setState(() {
      _selectedDestination = null;
      _polylines.clear();
      _currentRoutePoints  = [];
      _showNavChip         = false;
    });
  }

  // ── Quick actions ────────────────────────────────────────────────────────────

  Future<void> _onLocateMe() async {
    HapticFeedback.mediumImpact();
    setState(() => _locateActive = true);

    if (_userPosition != null) {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
            zoom: 15.2,
            tilt: 30.0,
          ),
        ),
      );
    } else {
      await _initUserLocation(userInitiated: true);
    }

    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _locateActive = false) : null);
  }

  Future<void> _onToggleRoutes() async {
    HapticFeedback.selectionClick();
    if (_selectedDestination != null) {
      // Clear per-destination route
      _clearSelection();
    } else {
      setState(() {
        _showRoutes = !_showRoutes;
        _routesActive = _showRoutes;
      });
      if (_showRoutes) {
        await _animateRouteLines();
      } else {
        setState(() => _polylines.clear());
      }
    }
  }

  List<_RouteLeg> get _dynamicLegs {
    if (_activeDestinations.isEmpty) return const [];
    final List<_RouteLeg> legs = [];
    final startName = _userPosition != null ? 'Your Location' : _activeDestinations.first.name;

    for (int i = 0; i < _activeDestinations.length; i++) {
      final fromName = i == 0 ? startName : _activeDestinations[i - 1].name;
      final toDest = _activeDestinations[i];
      final isSea = toDest.category == _SpotCategory.island;
      legs.add(_RouteLeg(
        from: fromName,
        to: toDest.name,
        transport: isSea ? 'Boat / Charter' : 'Multicab / Habal-habal',
        duration: toDest.duration,
        fare: toDest.fare,
        icon: isSea ? Icons.sailing_rounded : Icons.airport_shuttle_rounded,
        isSea: isSea,
      ));
    }
    return legs;
  }

  List<LatLng> get _dynamicOverviewPoints {
    final List<LatLng> pts = [];
    if (_userPosition != null) {
      pts.add(LatLng(_userPosition!.latitude, _userPosition!.longitude));
    }
    pts.addAll(_activeDestinations.map((d) => d.position));
    return pts;
  }

  Future<void> _animateRouteLines() async {
    final pts = _dynamicOverviewPoints;
    if (pts.length < 2) return;

    final List<LatLng> growing = [];
    for (int i = 0; i < pts.length; i++) {
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      growing.add(pts[i]);
      setState(() {
        _polylines
          ..clear()
          ..add(Polyline(
            polylineId: const PolylineId('overview_route'),
            points:     List.from(growing),
            color:      const Color(0xFF1E40AF),
            width:      5,
            jointType:  JointType.round,
            endCap:     Cap.roundCap,
            startCap:   Cap.roundCap,
          ));
      });
    }
  }

  // ── Hybrid / Real View mode toggle ──────────────────────────────────────

  Future<void> _onToggleHybridMode() async {
    HapticFeedback.mediumImpact();

    final goingHybrid = !_hybridMode;
    setState(() {
      _hybridMode = goingHybrid;
      _mapType    = goingHybrid ? MapType.hybrid : MapType.normal;
    });

    if (goingHybrid) {
      // Cinematic fly-in: tilt up, zoom slightly toward selected or island center
      final focusTarget = _selectedDestination?.position
          ?? const LatLng(11.5900, 124.3400);
      final startPt = _userPosition != null
          ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
          : const LatLng(11.5900, 124.3400);
      final bear = _selectedDestination != null
          ? _bearing(startPt, focusTarget)
          : 15.0;

      // Step 1 — gentle zoom-to + tilt
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target:  focusTarget,
          zoom:    11.8,
          tilt:    50.0,
          bearing: bear * 0.35,
        )),
      );

      // Step 2 — after settling, slight pull-back for full island view
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target:  LatLng(
            focusTarget.latitude  - 0.02,
            focusTarget.longitude + 0.01,
          ),
          zoom:    11.5,
          tilt:    45.0,
          bearing: bear * 0.25,
        )),
      );
    } else {
      // Return to clean planning view
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(_initialCamera),
      );
    }
  }

  void _onExploreTap() {
    HapticFeedback.mediumImpact();
    // Zoom to fit all destinations with cinematic island sweep
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(const CameraPosition(
        target:  LatLng(11.6200, 124.3200),
        zoom:    10.8,
        tilt:    35.0,
        bearing: 8.0,
      )),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. Google Map ──────────────────────────────────────────────────
          AnimatedOpacity(
            opacity:  _mapReady ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              onMapCreated:          _onMapCreated,
              markers:               _markers,
              polylines:             _polylines,
              // Apply custom style only in planning mode (hybrid has satellite)
              style:                 _hybridMode ? null : _mapStyleJson,
              myLocationButtonEnabled: false,
              zoomControlsEnabled:     false,
              mapToolbarEnabled:       false,
              compassEnabled:          true,
              buildingsEnabled:        true,
              tiltGesturesEnabled:     true,
              rotateGesturesEnabled:   true,
              mapType:                 _mapType,
              onTap:                   (_) => _clearSelection(),
            ),
          ),

          // ── 2. Loading / error overlay ─────────────────────────────────────
          if (!_mapReady)
            _LoadingOverlay(hasError: _mapError),

          // ── 3. Top gradient fade + header ──────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _TopBar(
              canPop:        canPop,
              markerCount:   _markers.length,
              statusText:    _statusText,
              statusCtrl:    _statusController,
              hybridMode:    _hybridMode,
            ),
          ),

          // ── 5. Sea wave shimmer overlay (top-right area = sea zone) ────────
          Positioned(
            top: 0, left: 0, right: 0, bottom: 0,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (_, child) => CustomPaint(
                  painter: _SeaWavePainter(progress: _waveController.value),
                ),
              ),
            ),
          ),

          // ── 5b. Travel dot overlay (glowing dot follows route) ────────────
          if (_currentRoutePoints.length >= 2)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _routeTravelCtrl,
                  builder: (_, child) => CustomPaint(
                    painter: _TravelDotPainter(
                      routePoints: _currentRoutePoints,
                      progress:    _routeTravelCtrl.value,
                      hasSea:      _selectedDestination != null &&
                          _selectedDestination!.category == _SpotCategory.island,
                      seaStart:    _selectedDestination != null &&
                          _selectedDestination!.category == _SpotCategory.island
                          ? 1
                          : 999,
                    ),
                  ),
                ),
              ),
            ),

          // ── 6. Floating quick-action buttons (right side) ──────────────────
          Positioned(
            right:  12.w,
            top:    140.h,
            child: _QuickActions(
              locateActive: _locateActive,
              routesActive: _routesActive,
              hybridActive: _hybridMode,
              onLocate:     _onLocateMe,
              onRoutes:     _onToggleRoutes,
              onExplore:    _onExploreTap,
              onHybrid:     _onToggleHybridMode,
            ),
          ),

          // ── 8. Navigation chip (appears after route is drawn) ───────────────
          if (_showNavChip && _selectedDestination != null)
            Positioned(
              bottom: widget.navClearance + 180.h + 16.h,
              left:  14.w,
              right: 14.w,
              child: _NavigationChip(
                destination: _selectedDestination!,
                onClose:     _clearSelection,
              ),
            ),

          // ── 9. Bottom route summary panel ──────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomRoutePanel(
              legs:         _dynamicLegs,
              expanded:     _panelExpanded,
              navClearance: widget.navClearance,
              onToggle:     () => setState(() => _panelExpanded = !_panelExpanded),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading overlay
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.hasError});
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF0369A1)],
        ),
      ),
      child: Center(
        child: hasError
            ? _MapErrorCard()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width:  180.w,
                    height: 180.w,
                    child: Lottie.asset(
                      AppAssets.mapLottie,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('Loading Biliran Map…',
                      style: TextStyle(
                        color:      Colors.white,
                        fontSize:   16.sp,
                        fontWeight: FontWeight.w700,
                      )),
                  SizedBox(height: 6.h),
                  Text('Fetching destination data…',
                      style: TextStyle(
                        color:    Colors.white.withValues(alpha: 0.60),
                        fontSize: 12.sp,
                      )),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.canPop,
    required this.markerCount,
    required this.statusText,
    required this.statusCtrl,
    required this.hybridMode,
  });
  final bool                  canPop;
  final int                   markerCount;
  final String                statusText;
  final AnimationController   statusCtrl;
  final bool                  hybridMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 50.h, 14.w, 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.97),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.55, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Back button
              if (canPop)
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width:  38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color:      Colors.black.withValues(alpha: 0.10),
                          blurRadius: 12,
                          offset:     const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size:  15.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ).animate().fade(duration: 300.ms).slideX(begin: -0.1),

              if (canPop) SizedBox(width: 10.w),

              // Title pill
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color:        Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset:     const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width:  30.r,
                        height: 30.r,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.explore_rounded,
                          color: Colors.white,
                          size:  16.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Biliran Island Map',
                                style: TextStyle(
                                  fontSize:   13.sp,
                                  fontWeight: FontWeight.w800,
                                  color:      AppColors.textPrimary,
                                )),
                            Text('Tourism Exploration Mode',
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color:    AppColors.textSecondary,
                                )),
                          ],
                        ),
                      ),
                      if (markerCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 9.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '$markerCount spots',
                            style: TextStyle(
                              color:      Colors.white,
                              fontSize:   9.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      // Real View badge — inline inside title pill
                      if (hybridMode) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.satellite_alt_rounded,
                                  color: Colors.white, size: 9.sp),
                              SizedBox(width: 4.w),
                              Text('Real View',
                                  style: TextStyle(
                                    color:      Colors.white,
                                    fontSize:   9.sp,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ).animate().fade(duration: 300.ms),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Smart status chip
          AnimatedBuilder(
            animation: statusCtrl,
            builder: (_, child) => Opacity(
              opacity: statusCtrl.value,
              child: AmbientGlow(
                color:        AppColors.primary,
                blurRadius:   10,
                minOpacity:   0.04,
                maxOpacity:   0.22,
                duration:     const Duration(milliseconds: 1800),
                borderRadius: BorderRadius.circular(99),
                child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color:        Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(
                      color:      Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width:  10.r,
                      height: 10.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color:       AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize:   10.sp,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: -0.08, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sea wave shimmer painter
// ─────────────────────────────────────────────────────────────────────────────

/// Subtle animated wave shimmer over the sea area of the map (top-right).
/// PROTOTYPE: purely decorative, not geo-accurate.
class _SeaWavePainter extends CustomPainter {
  _SeaWavePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 3 slow-moving wave bands in the upper-right quadrant
    for (int i = 0; i < 3; i++) {
      final t     = (progress + i / 3.0) % 1.0;
      final y     = size.height * (0.10 + i * 0.06);
      final alpha = (math.sin(t * math.pi) * 0.025).abs();

      paint.color = const Color(0xFF0891B2).withValues(alpha: alpha);

      final path = Path();
      path.moveTo(size.width * 0.45, y);

      for (double x = size.width * 0.45; x <= size.width; x += 2) {
        final wave = math.sin((x / size.width * 4 * math.pi) +
                (t * math.pi * 2) + i * 0.8) *
            6.0;
        path.lineTo(x, y + wave);
      }

      path.lineTo(size.width, size.height * 0.0);
      path.lineTo(size.width * 0.45, size.height * 0.0);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SeaWavePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Travel Dot Painter — glowing dot that moves along the route polyline
// ─────────────────────────────────────────────────────────────────────────────

/// Paints a glowing dot that travels along the [routePoints] path.
/// Uses a simple screen-space approximation: maps LatLng range → screen rect.
/// This is a prototype approach \u2014 accurate for small geographic areas.
class _TravelDotPainter extends CustomPainter {
  _TravelDotPainter({
    required this.routePoints,
    required this.progress,
    required this.hasSea,
    required this.seaStart,
  });

  final List<LatLng> routePoints;
  final double       progress;
  final bool         hasSea;
  final int          seaStart;

  @override
  void paint(Canvas canvas, Size size) {
    if (routePoints.length < 2) return;

    // Map lat/lng range to screen pixels (prototype approximation)
    double minLat = routePoints[0].latitude,  maxLat = routePoints[0].latitude;
    double minLng = routePoints[0].longitude, maxLng = routePoints[0].longitude;
    for (final p in routePoints) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    if (latRange == 0 || lngRange == 0) return;

    Offset latlngToScreen(LatLng ll) => Offset(
      (ll.longitude - minLng) / lngRange * size.width,
      (1.0 - (ll.latitude - minLat) / latRange) * size.height,
    );

    // Build the screen-space polyline
    final pts = routePoints.map(latlngToScreen).toList();

    // Compute total length and find the dot position along it
    final lengths = <double>[0.0];
    for (int i = 1; i < pts.length; i++) {
      lengths.add(lengths.last + (pts[i] - pts[i - 1]).distance);
    }
    final totalLen = lengths.last;
    if (totalLen == 0) return;

    final target = progress * totalLen;
    Offset dotPos = pts.last;
    int segIdx = pts.length - 2;
    for (int i = 0; i < lengths.length - 1; i++) {
      if (target <= lengths[i + 1]) {
        final t  = (target - lengths[i]) / (lengths[i + 1] - lengths[i]);
        dotPos   = Offset.lerp(pts[i], pts[i + 1], t)!;
        segIdx   = i;
        break;
      }
    }

    // Determine color \u2014 sea dot = cyan, land dot = navy
    final isSea = segIdx >= seaStart && hasSea;
    final color = isSea ? const Color(0xFF06B6D4) : const Color(0xFF1E40AF);

    // Outer glow halo
    canvas.drawCircle(
      dotPos,
      16,
      Paint()
        ..color      = color.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Mid glow
    canvas.drawCircle(
      dotPos,
      9,
      Paint()
        ..color      = color.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Core dot
    canvas.drawCircle(dotPos, 6, Paint()..color = color);

    // White center
    canvas.drawCircle(dotPos, 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_TravelDotPainter old) =>
      old.progress != progress || old.routePoints != routePoints;
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Chip — floating summary after route is drawn
// ─────────────────────────────────────────────────────────────────────────────

class _NavigationChip extends StatelessWidget {
  const _NavigationChip({
    required this.destination,
    required this.onClose,
  });

  final _Destination destination;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final dur    = destination.duration;
    final fare   = destination.fare;
    final hasSea = destination.category == _SpotCategory.island;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset:     const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          // Route icon
          Container(
            width:  36.r,
            height: 36.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              hasSea ? Icons.sailing_rounded : Icons.navigation_rounded,
              color: Colors.white,
              size:  18.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // Route text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('Current Location',
                        style: TextStyle(
                          fontSize:   11.sp,
                          fontWeight: FontWeight.w700,
                          color:      AppColors.textPrimary,
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 10.sp, color: AppColors.textSecondary),
                    ),
                    Flexible(
                      child: Text(destination.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:   11.sp,
                            fontWeight: FontWeight.w800,
                            color:      AppColors.primary,
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 10.sp, color: AppColors.textSecondary),
                    SizedBox(width: 3.w),
                    Text(dur,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color:    AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(width: 10.w),
                    Icon(Icons.payments_rounded,
                        size: 10.sp, color: AppColors.accent),
                    SizedBox(width: 3.w),
                    Text(fare,
                        style: TextStyle(
                          fontSize:   9.5.sp,
                          color:      AppColors.accent,
                          fontWeight: FontWeight.w700,
                        )),
                    if (hasSea) ...[ 
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color:        const Color(0xFF06B6D4).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text('🌊 Sea',
                            style: TextStyle(
                              fontSize:   8.sp,
                              fontWeight: FontWeight.w700,
                              color:      const Color(0xFF0891B2),
                            )),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              width:  28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color:        AppColors.divider.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.close_rounded,
                  size: 14.sp, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 350.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick actions panel
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.locateActive,
    required this.routesActive,
    required this.hybridActive,
    required this.onLocate,
    required this.onRoutes,
    required this.onExplore,
    required this.onHybrid,
  });

  final bool         locateActive;
  final bool         routesActive;
  final bool         hybridActive;
  final VoidCallback onLocate;
  final VoidCallback onRoutes;
  final VoidCallback onExplore;
  final VoidCallback onHybrid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuickBtn(
          icon:    locateActive ? Icons.my_location_rounded : Icons.location_searching_rounded,
          label:   'Locate',
          active:  locateActive,
          onTap:   onLocate,
          color:   AppColors.primary,
          delay:   0,
        ),
        SizedBox(height: 8.h),
        _QuickBtn(
          icon:    Icons.route_rounded,
          label:   'Routes',
          active:  routesActive,
          onTap:   onRoutes,
          color:   const Color(0xFF0891B2),
          delay:   60,
        ),
        SizedBox(height: 8.h),
        _QuickBtn(
          icon:    Icons.travel_explore_rounded,
          label:   'Explore',
          active:  false,
          onTap:   onExplore,
          color:   AppColors.accentSoft,
          delay:   120,
        ),
        SizedBox(height: 8.h),
        // Hybrid / Real View toggle
        _QuickBtn(
          icon:    hybridActive ? Icons.satellite_alt_rounded : Icons.map_rounded,
          label:   hybridActive ? 'Planning' : 'Real View',
          active:  hybridActive,
          onTap:   onHybrid,
          color:   const Color(0xFF0D9488),
          delay:   180,
        ),
      ],
    );
  }
}

class _QuickBtn extends StatelessWidget {
  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.color,
    required this.delay,
  });

  final IconData     icon;
  final String       label;
  final bool         active;
  final VoidCallback onTap;
  final Color        color;
  final int          delay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width:  50.r,
        height: 50.r,
        decoration: BoxDecoration(
          color:        active ? color : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color:      active
                  ? color.withValues(alpha: 0.38)
                  : Colors.black.withValues(alpha: 0.10),
              blurRadius: active ? 16 : 10,
              offset:     const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: active ? color : Colors.white,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: active ? Colors.white : color,
                size:  18.sp),
            SizedBox(height: 2.h),
            Text(label,
                style: TextStyle(
                  color:      active ? Colors.white : AppColors.textSecondary,
                  fontSize:   7.5.sp,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    )
        .animate(delay: (500 + delay).ms)
        .fade(duration: 350.ms)
        .slideX(begin: 0.2, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Destination Modal (bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

/// Full-featured premium destination modal shown when a map marker is tapped.
///
/// Features:
///   • DraggableScrollableSheet for snap-expand behaviour
///   • Real destination photo header with gradient overlay
///   • Category badge + Hidden Gem badge + advisory chip
///   • Tourism highlights row (icons)
///   • Travel info grid (fare / duration / providers / transport)
///   • Advisory details section
///   • Save / heart animation button
///   • "View Routes" primary CTA
class _DestinationModal extends StatefulWidget {
  const _DestinationModal({
    required this.destination,
    required this.onViewRoutes,
  });
  final _Destination destination;
  final VoidCallback  onViewRoutes;

  @override
  State<_DestinationModal> createState() => _DestinationModalState();
}

class _DestinationModalState extends State<_DestinationModal>
    with SingleTickerProviderStateMixin {

  bool _saved = false;
  late final AnimationController _heartCtrl;
  late final Animation<double>   _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 380),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.90), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0),  weight: 30),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleSave() {
    HapticFeedback.selectionClick();
    setState(() => _saved = !_saved);
    _heartCtrl.forward(from: 0);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  _Destination get _dest => widget.destination;
  _SpotCategory get _cat => _dest.category;

  Color get _advisoryColor {
    switch (_dest.advisoryLevel) {
      case 3: return const Color(0xFFEF4444);
      case 2: return const Color(0xFFF59E0B);
      case 1: return const Color(0xFF0EA5E9);
      default: return AppColors.success;
    }
  }

  String get _advisoryLabel {
    switch (_dest.advisoryLevel) {
      case 3: return 'High Risk';
      case 2: return 'Moderate Risk';
      case 1: return 'Advisory';
      default: return 'All Clear';
    }
  }

  String get _advisoryDescription {
    switch (_dest.advisoryLevel) {
      case 3: return 'Exercise extreme caution. Check advisories before travel.';
      case 2: return 'Use caution. Conditions may affect travel plans.';
      case 1: return 'Minor advisories in effect. Travel is generally safe.';
      default: return 'Conditions are favorable. Enjoy your trip!';
    }
  }

  IconData get _advisoryIcon {
    switch (_dest.advisoryLevel) {
      case 3: return Icons.warning_rounded;
      case 2: return Icons.report_problem_rounded;
      case 1: return Icons.info_rounded;
      default: return Icons.check_circle_rounded;
    }
  }

  // ── Highlights data ───────────────────────────────────────────────────────────
  List<(IconData, String, Color)> get _highlights {
    final list = <(IconData, String, Color)>[];
    if (_dest.isHiddenGem) {
      list.add((Icons.auto_awesome_rounded, 'Hidden Gem', const Color(0xFFF59E0B)));
    }
    if (_dest.advisoryLevel == 0) {
      list.add((Icons.family_restroom_rounded, 'Family Friendly', AppColors.success));
    }
    if (_dest.category == _SpotCategory.beach || _dest.category == _SpotCategory.island) {
      list.add((Icons.scuba_diving_rounded, 'Snorkeling', const Color(0xFF0891B2)));
    }
    if (_dest.category == _SpotCategory.island) {
      list.add((Icons.wb_sunny_rounded, 'Sunset Spot', const Color(0xFFFB923C)));
    }
    if (_dest.category == _SpotCategory.waterfall) {
      list.add((Icons.water_rounded, 'Swimming', const Color(0xFF06B6D4)));
    }
    if (_dest.category == _SpotCategory.mountain) {
      list.add((Icons.hiking_rounded, 'Trekking', AppColors.success));
    }
    if (_dest.providers >= 4) {
      list.add((Icons.verified_rounded, 'Popular', AppColors.primary));
    }
    return list;
  }

  // ── Transport types ───────────────────────────────────────────────────────────
  List<(IconData, String)> get _transports {
    final list = <(IconData, String)>[];
    if (_dest.category == _SpotCategory.island ||
        (_dest.id == 'sambawan' || _dest.id == 'maripipi')) {
      list.add((Icons.directions_boat_rounded, 'Sea Transfer'));
    }
    if (_dest.category != _SpotCategory.island) {
      list.add((Icons.airport_shuttle_rounded, 'Land Travel'));
    }
    list.add((Icons.two_wheeler_rounded, 'Habal-habal'));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize:     0.42,
      maxChildSize:     0.92,
      snap:             true,
      snapSizes:        const [0.58, 0.92],
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withValues(alpha: 0.28),
                blurRadius: 48,
                offset:     const Offset(0, -8),
              ),
            ],
          ),
          child: ListView(
            controller:  scrollCtrl,
            padding:     EdgeInsets.zero,
            physics:     const BouncingScrollPhysics(),
            children: [

              // ── Drag handle ────────────────────────────────────────────────
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                  child: Container(
                    width:  40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color:        Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),

              // ── Hero image ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: SizedBox(
                    height: 200.h,
                    width:  double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_dest.imageAsset != null)
                          Hero(
                            tag: 'dest_image_${_dest.id}',
                            child: Image.asset(
                              _dest.imageAsset!,
                              fit:       BoxFit.cover,
                              alignment: Alignment.center,
                              errorBuilder: (_, _, _) => Container(
                                color: _cat.color.withValues(alpha: 0.15),
                                child: Icon(_cat.icon,
                                    size: 64.sp,
                                    color: _cat.color.withValues(alpha: 0.25)),
                              ),
                            ),
                          )
                        else
                          Container(
                            color: _cat.color.withValues(alpha: 0.15),
                            child: Icon(_cat.icon,
                                size: 64.sp,
                                color: _cat.color.withValues(alpha: 0.25)),
                          ),

                        // Gradient overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin:  Alignment.topCenter,
                                end:    Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                                stops: const [0.45, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Category badge (top-left)
                        Positioned(
                          top: 12.h, left: 12.w,
                          child: _CategoryBadge(cat: _cat),
                        ),

                        // Hidden gem badge (top-right area)
                        if (_dest.isHiddenGem)
                          Positioned(
                            top:   12.h,
                            right: 12.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFB923C), Color(0xFFF59E0B)],
                                ),
                                borderRadius: BorderRadius.circular(99),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('✨', style: TextStyle(fontSize: 11.sp)),
                                  SizedBox(width: 4.w),
                                  Text('Hidden Gem',
                                      style: TextStyle(
                                        color:      Colors.white,
                                        fontSize:   10.sp,
                                        fontWeight: FontWeight.w800,
                                      )),
                                ],
                              ),
                            ),
                          ),

                        // Name + tagline at bottom of image
                        Positioned(
                          bottom: 12.h, left: 14.w, right: 60.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_dest.name,
                                  style: TextStyle(
                                    color:      Colors.white,
                                    fontSize:   20.sp,
                                    fontWeight: FontWeight.w900,
                                    height:     1.1,
                                    shadows:    const [Shadow(
                                        color:      Colors.black54,
                                        blurRadius: 6)],
                                  )),
                              SizedBox(height: 3.h),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_rounded,
                                      color: Colors.white70, size: 11.sp),
                                  SizedBox(width: 3.w),
                                  Flexible(
                                    child: Text(_dest.tagline,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:    Colors.white70,
                                          fontSize: 10.sp,
                                          shadows:  const [Shadow(
                                              color:      Colors.black54,
                                              blurRadius: 4)],
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Heart / save button (bottom-right of image)
                        Positioned(
                          bottom: 10.h, right: 12.w,
                          child: GestureDetector(
                            onTap: _toggleSave,
                            child: AnimatedBuilder(
                              animation: _heartScale,
                              builder: (_, child) => Transform.scale(
                                scale: _heartScale.value,
                                child: child,
                              ),
                              child: Container(
                                width:  44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  color:        _saved
                                      ? const Color(0xFFEF4444)
                                      : Colors.white.withValues(alpha: 0.90),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:      Colors.black.withValues(alpha: 0.18),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _saved
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: _saved
                                      ? Colors.white
                                      : const Color(0xFFEF4444),
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fade(duration: 300.ms).slideY(begin: 0.06, end: 0),

              SizedBox(height: 16.h),

              // ── Tourism Highlights ─────────────────────────────────────────
              if (_highlights.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _highlights.asMap().entries.map((e) {
                        final h = e.value;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 11.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color:        h.$3.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                  color: h.$3.withValues(alpha: 0.30)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(h.$1, color: h.$3, size: 12.sp),
                                SizedBox(width: 5.w),
                                Text(h.$2,
                                    style: TextStyle(
                                      color:      h.$3,
                                      fontSize:   10.sp,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ],
                            ),
                          ).animate(delay: (e.key * 60).ms)
                              .fade(duration: 300.ms)
                              .slideX(begin: 0.1, end: 0),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // ── Description ────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(_dest.description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color:    AppColors.textSecondary,
                      height:   1.65,
                    )),
              ),

              SizedBox(height: 16.h),

              // ── Travel info grid ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(child: _InfoTile(
                      icon:  Icons.payments_rounded,
                      label: 'Est. Fare',
                      value: _dest.fare,
                      color: AppColors.accent,
                    )),
                    SizedBox(width: 10.w),
                    Expanded(child: _InfoTile(
                      icon:  Icons.access_time_rounded,
                      label: 'Travel Time',
                      value: _dest.duration,
                      color: AppColors.primary,
                    )),
                    SizedBox(width: 10.w),
                    Expanded(child: _InfoTile(
                      icon:  Icons.verified_rounded,
                      label: 'Providers',
                      value: '${_dest.providers} verified',
                      color: AppColors.success,
                    )),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // ── Transport types ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Getting There',
                        style: TextStyle(
                          fontSize:   12.sp,
                          fontWeight: FontWeight.w800,
                          color:      AppColors.textPrimary,
                        )),
                    SizedBox(height: 8.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _transports.map((t) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 7.h),
                            decoration: BoxDecoration(
                              color:        AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(t.$1, color: AppColors.primary, size: 14.sp),
                                SizedBox(width: 6.w),
                                Text(t.$2,
                                    style: TextStyle(
                                      color:      AppColors.textPrimary,
                                      fontSize:   10.5.sp,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ],
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // ── Advisory section ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color:        _advisoryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: _advisoryColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width:  36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color:        _advisoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(_advisoryIcon,
                            color: _advisoryColor, size: 18.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color:        _advisoryColor,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(_advisoryLabel,
                                  style: TextStyle(
                                    color:      Colors.white,
                                    fontSize:   9.sp,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ),
                            SizedBox(height: 5.h),
                            Text(_advisoryDescription,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color:    AppColors.textSecondary,
                                  height:   1.5,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 22.h),

              // ── Action buttons ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottomPad + 20.h),
                child: Column(
                  children: [
                    // Primary: View Routes
                    GestureDetector(
                      onTap: widget.onViewRoutes,
                      child: Container(
                        width:  double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin:  Alignment.centerLeft,
                            end:    Alignment.centerRight,
                            colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color:      const Color(0xFF1E3A8A)
                                  .withValues(alpha: 0.32),
                              blurRadius: 18,
                              offset:     const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.route_rounded,
                                color: Colors.white, size: 18.sp),
                            SizedBox(width: 10.w),
                            Text('View Routes',
                                style: TextStyle(
                                  color:         Colors.white,
                                  fontSize:      15.sp,
                                  fontWeight:    FontWeight.w800,
                                  letterSpacing: 0.3,
                                )),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Secondary: Save Destination
                    GestureDetector(
                      onTap: _toggleSave,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        width:  double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color:        _saved
                              ? const Color(0xFFEF4444).withValues(alpha: 0.10)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: _saved
                                ? const Color(0xFFEF4444).withValues(alpha: 0.40)
                                : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _heartScale,
                              builder: (_, child) => Transform.scale(
                                scale: _heartScale.value,
                                child: child,
                              ),
                              child: Icon(
                                _saved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _saved
                                    ? const Color(0xFFEF4444)
                                    : AppColors.textSecondary,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _saved
                                  ? 'Saved to Favorites'
                                  : 'Save Destination',
                              style: TextStyle(
                                color:      _saved
                                    ? const Color(0xFFEF4444)
                                    : AppColors.textSecondary,
                                fontSize:   13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).animate().slideY(begin: 0.1, end: 0, duration: 380.ms,
        curve: Curves.easeOutCubic).fade(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable modal sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.cat});
  final _SpotCategory cat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color:        cat.color.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(color: cat.color.withValues(alpha: 0.40), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cat.icon, color: Colors.white, size: 11.sp),
          SizedBox(width: 5.w),
          Text(cat.label,
              style: TextStyle(
                color:      Colors.white,
                fontSize:   10.sp,
                fontWeight: FontWeight.w800,
              )),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(height: 6.h),
          Text(label,
              style: TextStyle(
                fontSize: 8.5.sp,
                color:    AppColors.textSecondary,
              )),
          SizedBox(height: 2.h),
          Text(value,
              style: TextStyle(
                fontSize:   11.sp,
                fontWeight: FontWeight.w800,
                color:      color,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom route summary panel
// ─────────────────────────────────────────────────────────────────────────────

class _BottomRoutePanel extends StatelessWidget {
  const _BottomRoutePanel({
    required this.legs,
    required this.expanded,
    required this.navClearance,
    required this.onToggle,
  });
  final List<_RouteLeg> legs;
  final bool            expanded;
  final double          navClearance;
  final VoidCallback    onToggle;

  @override
  Widget build(BuildContext context) {
    final bottomPad = navClearance + 12.h;
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve:    Curves.easeOutCubic,
      decoration: BoxDecoration(
        color:        isDark ? DarkColors.card : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 28,
            offset:     const Offset(0, -6),
          ),
        ],
        border: isDark ? Border.all(color: DarkColors.border, width: 1) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle + header
          GestureDetector(
            onTap:     onToggle,
            behavior:  HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width:  40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color:        isDark ? DarkColors.divider : AppColors.divider,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      // Transport icons
                      Row(
                        children: [
                          _TransportIcon(
                            icon:  Icons.airport_shuttle_rounded,
                            color: isDark ? AppColors.oceanCyan : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          _TransportIcon(
                            icon:  Icons.two_wheeler_rounded,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          _TransportIcon(
                            icon:  Icons.sailing_rounded,
                            color: const Color(0xFF0891B2),
                          ),
                        ],
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text('Route Summary',
                            style: TextStyle(
                              fontSize:   13.sp,
                              fontWeight: FontWeight.w800,
                              color:      isDark ? DarkColors.text : AppColors.textPrimary,
                            )),
                      ),
                      // Total fare
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color:        AppColors.accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text('₱ 1,330–2,060',
                            style: TextStyle(
                              color:      AppColors.accent,
                              fontSize:   10.sp,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                        color: isDark ? DarkColors.subtext : AppColors.textSecondary,
                        size:  18.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Route legs list
          AnimatedSize(
            duration: const Duration(milliseconds: 380),
            curve:    Curves.easeOutCubic,
            child: SizedBox(
              height: expanded ? 235.h : 88.h,
              child: ListView.separated(
                physics:          const BouncingScrollPhysics(),
                padding:          EdgeInsets.fromLTRB(14.w, 0, 14.w, bottomPad),
                itemCount:        legs.length,
                separatorBuilder: (_, _) => SizedBox(height: 7.h),
                itemBuilder: (_, i) => _LegTile(leg: legs[i], index: i),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.25, end: 0, delay: 400.ms, duration: 500.ms,
        curve: Curves.easeOutCubic).fade(delay: 400.ms);
  }
}

class _TransportIcon extends StatelessWidget {
  const _TransportIcon({required this.icon, required this.color});
  final IconData icon;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  22.r,
      height: 22.r,
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, color: color, size: 12.sp),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route leg tile
// ─────────────────────────────────────────────────────────────────────────────

class _LegTile extends StatelessWidget {
  const _LegTile({required this.leg, required this.index});
  final _RouteLeg leg;
  final int       index;

  Color get _color {
    if (leg.isSea)                         return const Color(0xFF0891B2);
    if (leg.transport.contains('Habal'))   return AppColors.warning;
    if (leg.transport.contains('Multicab')) return AppColors.primary;
    return AppColors.accentSoft;
  }

  @override
  Widget build(BuildContext context) {
    final color  = _color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: leg.isSea
            ? (isDark ? const Color(0xFF0C2434) : const Color(0xFFF0F9FF))
            : (isDark ? DarkColors.elevated : Colors.white),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: leg.isSea
              ? (isDark ? const Color(0xFF164E63) : const Color(0xFFBAE6FD))
              : (isDark ? DarkColors.border : AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Container(
            width:  34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(leg.icon, color: color, size: 16.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(leg.from,
                          overflow:  TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:   11.sp,
                            fontWeight: FontWeight.w700,
                            color:      isDark ? DarkColors.text : AppColors.textPrimary,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 11.sp, color: AppColors.textSecondary),
                    ),
                    Flexible(
                      child: Text(leg.to,
                          overflow:  TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:   11.sp,
                            fontWeight: FontWeight.w700,
                            color:      color,
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Text(leg.transport,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color:    AppColors.textSecondary,
                        )),
                    Text('  ·  ',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color:    AppColors.divider,
                        )),
                    Text(leg.duration,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color:    AppColors.textSecondary,
                        )),
                    if (leg.isSea) ...[
                      SizedBox(width: 5.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color:        const Color(0xFF0891B2).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text('🌊 Sea',
                            style: TextStyle(
                              fontSize:   8.sp,
                              fontWeight: FontWeight.w700,
                              color:      const Color(0xFF0891B2),
                            )),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(leg.fare,
              style: TextStyle(
                color:      AppColors.accent,
                fontSize:   10.sp,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    )
        .animate(delay: (500 + index * 65).ms)
        .fade(duration: 350.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error card
// ─────────────────────────────────────────────────────────────────────────────

class _MapErrorCard extends StatelessWidget {
  const _MapErrorCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.15),
              blurRadius: 32,
              offset:     const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, color: AppColors.warning, size: 48.sp),
            SizedBox(height: 12.h),
            Text('Map could not load',
                style: TextStyle(
                  fontSize:   15.sp,
                  fontWeight: FontWeight.w800,
                  color:      AppColors.textPrimary,
                )),
            SizedBox(height: 10.h),
            Text(
              'Enable Maps SDK in Google Cloud Console\n'
              'or check your API key configuration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color:    AppColors.textSecondary,
                height:   1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
