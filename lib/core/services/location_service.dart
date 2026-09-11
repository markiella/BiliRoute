import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Status enum representing location check / retrieval outcome
enum LocationResultStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

/// Result object holding location retrieval status and position data
class LocationResult {
  final LocationResultStatus status;
  final Position? position;
  final String message;

  const LocationResult({
    required this.status,
    this.position,
    required this.message,
  });

  bool get isSuccess => status == LocationResultStatus.success && position != null;
}

/// LocationService
/// Dedicated helper service for BiliRoute location & GPS permissions management.
class LocationService {
  /// Checks whether location service is enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks current location permission state
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Requests foreground location permission from the user
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Requests permission (if needed) and fetches the current device position.
  Future<LocationResult> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    try {
      // 1. Check if device location services (GPS) are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          status: LocationResultStatus.serviceDisabled,
          message: 'Location services are disabled on your device. Please enable GPS.',
        );
      }

      // 2. Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            status: LocationResultStatus.permissionDenied,
            message: 'Location permission denied. Enable location permission to show your current position.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          status: LocationResultStatus.permissionDeniedForever,
          message: 'Location permissions are permanently denied. Enable them in device settings.',
        );
      }

      // 3. Obtain current high-accuracy position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        ),
      );

      return LocationResult(
        status: LocationResultStatus.success,
        position: position,
        message: 'Position retrieved successfully.',
      );
    } catch (e) {
      return LocationResult(
        status: LocationResultStatus.error,
        message: 'Could not obtain location: ${e.toString()}',
      );
    }
  }

  /// Exposes live location updates via Geolocator position stream.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
