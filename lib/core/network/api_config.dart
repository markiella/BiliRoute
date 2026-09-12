import 'dart:io';
import 'package:flutter/foundation.dart';

/// ApiConfig
/// Manages environment configuration and API base URL resolution.
/// Supports Localhost (Desktop/Web), Android Emulator (10.0.2.2), and Custom LAN IP.
class ApiConfig {
  ApiConfig._();

  // Port configured in Node.js server.js (.env)
  static const int port = 5000;
  static const String apiVersion = 'v1';

  // Override this string if testing on a physical mobile device over local Wi-Fi LAN
  // e.g., '192.168.1.18'
  static String? customLanIp = '192.168.1.18';

  /// Dynamically computes the appropriate API base URL based on execution platform
  static String get baseUrl {
    if (customLanIp != null && customLanIp!.isNotEmpty) {
      return 'http://$customLanIp:$port/api/$apiVersion';
    }

    if (kIsWeb) {
      return 'http://localhost:$port/api/$apiVersion';
    }

    if (Platform.isAndroid) {
      // Android Emulator loopback alias
      return 'http://10.0.2.2:$port/api/$apiVersion';
    }

    // Windows Desktop, macOS, iOS simulator
    return 'http://localhost:$port/api/$apiVersion';
  }

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
