import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SavedDestinationsNotifier — persists saved destination IDs locally
// ─────────────────────────────────────────────────────────────────────────────

const _kSavedKey = 'biliroute_saved_destinations';

class SavedDestinationsNotifier extends ChangeNotifier {
  final Set<String> _savedIds = {};

  /// Unmodifiable view of all currently saved destination IDs.
  Set<String> get savedIds => Set.unmodifiable(_savedIds);

  bool isSaved(String id) => _savedIds.contains(id);

  /// Toggle saved state. Returns true if the destination is now saved.
  Future<bool> toggle(String id) async {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    notifyListeners();
    await _persist();
    return _savedIds.contains(id);
  }

  /// Load from SharedPreferences. Call once in main() before runApp().
  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_kSavedKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _savedIds.addAll(decoded.cast<String>());
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSavedKey, jsonEncode(_savedIds.toList()));
  }
}
