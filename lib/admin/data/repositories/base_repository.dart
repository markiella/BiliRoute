import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Base Repository — BiliRoute Admin CMS
//
// All admin repositories extend this class.
// Swapping to Firebase only requires replacing the method bodies —
// the interface contract stays identical.
// ─────────────────────────────────────────────────────────────────────────────

abstract class BaseRepository<T> extends ChangeNotifier {
  // ── In-memory store ────────────────────────────────────────────────────────
  final List<T> _items = [];

  /// Read-only view of all items.
  List<T> get items => List.unmodifiable(_items);

  // ── CRUD operations ────────────────────────────────────────────────────────

  /// Returns all items in the repository.
  List<T> getAll() => List.unmodifiable(_items);

  /// Returns the item matching [id], or null if not found.
  T? getById(String id);

  /// Adds a new item and notifies listeners.
  void create(T item) {
    _items.add(item);
    notifyListeners();
  }

  /// Replaces the item at [index] and notifies listeners.
  void updateAt(int index, T item) {
    _items[index] = item;
    notifyListeners();
  }

  /// Removes an item by its [id] and notifies listeners.
  void delete(String id) {
    _items.removeWhere((item) => idOf(item) == id);
    notifyListeners();
  }

  /// Returns the count of all items.
  int get count => _items.length;

  // ── Seeding ────────────────────────────────────────────────────────────────

  /// Seeds the repository with an initial dataset.
  /// Called once on startup from main.dart.
  void seed(List<T> initialData) {
    _items
      ..clear()
      ..addAll(initialData);
    // No notifyListeners here — called before UI is mounted.
  }

  // ── Abstract helpers ───────────────────────────────────────────────────────

  /// Subclasses must provide the string ID extractor.
  String idOf(T item);

  /// Finds the index of an item by its ID.
  int indexById(String id) => _items.indexWhere((i) => idOf(i) == id);
}
