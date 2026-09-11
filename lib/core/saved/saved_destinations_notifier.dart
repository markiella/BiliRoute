import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SavedDestinationsNotifier — persists saved destination IDs with backend sync
// ─────────────────────────────────────────────────────────────────────────────

const _kSavedKey = 'biliroute_saved_destinations';

class SavedDestinationsNotifier extends ChangeNotifier {
  final Set<String> _savedIds = {};

  /// Unmodifiable view of all currently saved destination IDs.
  Set<String> get savedIds => Set.unmodifiable(_savedIds);

  bool isSaved(String id) => _savedIds.contains(id);

  /// Synchronize remote saved destinations from user session
  void syncWithSession(List<String> remoteSavedIds) {
    _savedIds.clear();
    _savedIds.addAll(remoteSavedIds);
    notifyListeners();
  }

  /// Toggle saved state optimistically. Returns true if the destination is now saved.
  Future<bool> toggle(String id) async {
    final wasSaved = _savedIds.contains(id);

    // 1. Optimistic local update
    if (wasSaved) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    notifyListeners();

    final isNowSaved = _savedIds.contains(id);
    final authRepo = AuthRepository.instance;

    if (authRepo.isLoggedIn) {
      // 2. Sync to MongoDB backend via REST API
      final success = await authRepo.updateSavedDestinations(_savedIds.toList());
      if (!success) {
        // Rollback optimistic update if backend call failed
        if (wasSaved) {
          _savedIds.add(id);
        } else {
          _savedIds.remove(id);
        }
        notifyListeners();
        throw Exception(authRepo.errorMessage ?? 'Failed to sync saved destination to backend.');
      }
    } else {
      // Fallback local storage persistence for unauthenticated state
      await _persist();
    }

    return isNowSaved;
  }

  /// Load saved destinations (from AuthSession if logged in, or SharedPreferences as fallback)
  Future<void> loadSaved() async {
    final authRepo = AuthRepository.instance;
    if (authRepo.isLoggedIn) {
      _savedIds.clear();
      _savedIds.addAll(authRepo.currentSession.savedDestinations);
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_kSavedKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _savedIds.clear();
      _savedIds.addAll(decoded.cast<String>());
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSavedKey, jsonEncode(_savedIds.toList()));
  }
}
