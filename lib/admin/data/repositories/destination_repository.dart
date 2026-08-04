import 'package:flutter/material.dart';

import '../../../data/models/destination_model.dart';
import '../models/admin_destination.dart';
import 'base_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DestinationRepository — Seeded from allBiliranDestinations
//
// Single source of truth for all destination data in both the admin portal
// and the tourist-facing mobile app. No UI component reads static lists
// directly — all reads go through this repository.
// ─────────────────────────────────────────────────────────────────────────────

class DestinationRepository extends BaseRepository<AdminDestination> {
  DestinationRepository() {
    _seedFromStaticData();
  }

  // ── Seed from existing static dataset ──────────────────────────────────────

  void _seedFromStaticData() {
    final seeded = allBiliranDestinations.map(_fromDestinationItem).toList();
    seed(seeded);
  }

  /// Converts a static [DestinationItem] into a mutable [AdminDestination].
  static AdminDestination _fromDestinationItem(DestinationItem d) {
    return AdminDestination(
      id:              d.id,
      name:            d.title,
      category:        _mapCategory(d.category),
      municipality:    d.municipality,
      barangay:        '',                    // not in original model
      province:        d.province,
      description:     d.description,
      latitude:        d.lat,
      longitude:       d.lng,
      entranceFee:     d.entranceFee,
      envFee:          d.envFee,
      cottageFee:      d.cottageFee,
      estimatedFare:   d.estimatedFare,
      travelTime:      d.travelTime,
      bestSeason:      d.bestSeason,
      difficulty:      d.difficulty,
      signalStrength:  _mapSignal(d.signal),
      thingsToDo:      List<String>.from(d.thingsToDo),
      whatToBring:     List<String>.from(d.whatToBring),
      safetyReminders: List<String>.from(d.safetyReminders),
      galleryAssets:   List<String>.from(d.galleryAssets),
      coverImageAsset: d.imageAsset,
      rating:          d.rating,
      isFieldVerified: d.isFieldVerified,
      status:          d.isFieldVerified
                         ? DestinationStatus.published
                         : DestinationStatus.verified,
      verifiedBy:      d.isFieldVerified ? 'BiliRoute Research Team' : null,
      verifiedAt:      d.isFieldVerified ? DateTime(2025, 3, 15) : null,
      dateAdded:       DateTime(2025, 1, 1),
      dateUpdated:     DateTime(2025, 3, 15),
    );
  }

  static DestinationCategory _mapCategory(String raw) {
    switch (raw.toLowerCase()) {
      case 'island':        return DestinationCategory.island;
      case 'beach':         return DestinationCategory.beach;
      case 'waterfall':     return DestinationCategory.waterfall;
      case 'resort':        return DestinationCategory.resort;
      case 'mountain':      return DestinationCategory.mountain;
      case 'cave':          return DestinationCategory.cave;
      case 'cultural site': return DestinationCategory.culturalSite;
      case 'park':          return DestinationCategory.park;
      case 'spring':        return DestinationCategory.spring;
      default:              return DestinationCategory.island;
    }
  }

  static SignalStrength _mapSignal(String raw) {
    switch (raw.toLowerCase()) {
      case 'strong':   return SignalStrength.strong;
      case 'moderate': return SignalStrength.moderate;
      case 'weak':     return SignalStrength.weak;
      default:         return SignalStrength.none;
    }
  }

  // ── BaseRepository implementation ───────────────────────────────────────────

  @override
  String idOf(AdminDestination item) => item.id;

  @override
  AdminDestination? getById(String id) {
    try {
      return items.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Extended queries used by mobile app ─────────────────────────────────────

  /// Returns only published destinations (shown to tourists).
  List<AdminDestination> getPublished() =>
      items.where((d) => d.status == DestinationStatus.published).toList();

  /// Returns destinations pending field survey or verification.
  List<AdminDestination> getPending() => items
      .where((d) =>
          d.status == DestinationStatus.pending ||
          d.status == DestinationStatus.fieldSurveyed)
      .toList();

  /// Filters by category.
  List<AdminDestination> byCategory(DestinationCategory cat) =>
      items.where((d) => d.category == cat).toList();

  /// Filters by municipality.
  List<AdminDestination> byMunicipality(String municipality) => items
      .where((d) =>
          d.municipality.toLowerCase() == municipality.toLowerCase())
      .toList();

  /// Search by name or municipality.
  List<AdminDestination> search(String query) {
    final q = query.toLowerCase();
    return items
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.municipality.toLowerCase().contains(q))
        .toList();
  }

  // ── Verification workflow ───────────────────────────────────────────────────

  /// Advances a destination to the next verification status.
  void advanceStatus(String id, {String? officerName}) {
    final idx = indexById(id);
    if (idx == -1) return;
    final dest = items[idx];
    final next = dest.status.next;
    if (next == null) return;
    updateAt(
      idx,
      dest.copyWith(
        status:     next,
        verifiedBy: officerName ?? dest.verifiedBy,
        verifiedAt: next == DestinationStatus.verified ? DateTime.now() : dest.verifiedAt,
        dateUpdated: DateTime.now(),
      ),
    );
  }

  // ── Admin CRUD ──────────────────────────────────────────────────────────────

  void updateDestination(AdminDestination updated) {
    final idx = indexById(updated.id);
    if (idx == -1) return;
    updateAt(idx, updated.copyWith(dateUpdated: DateTime.now()));
  }

  // ── Dashboard statistics ────────────────────────────────────────────────────

  int get publishedCount =>
      items.where((d) => d.status == DestinationStatus.published).length;
  int get pendingCount =>
      items.where((d) => d.status == DestinationStatus.pending).length;
  int get verifiedCount =>
      items.where((d) => d.status == DestinationStatus.verified).length;

  /// Converts an [AdminDestination] back to a [DestinationItem] for mobile app
  /// compatibility until full migration is complete.
  DestinationItem toDestinationItem(AdminDestination d) {
    return DestinationItem(
      id:              d.id,
      title:           d.name,
      location:        d.locationDisplay,
      municipality:    d.municipality,
      province:        d.province,
      category:        d.category.label,
      rating:          d.rating,
      imageAsset:      d.coverImageAsset ?? 'assets/images/sambawan.jpg',
      description:     d.description,
      categoryColor:   _categoryColor(d.category),
      lat:             d.latitude,
      lng:             d.longitude,
      isFieldVerified: d.isFieldVerified,
      entranceFee:     d.entranceFee,
      cottageFee:      d.cottageFee,
      envFee:          d.envFee,
      bestSeason:      d.bestSeason,
      difficulty:      d.difficulty,
      difficultyColor: d.difficulty.toLowerCase() == 'easy'
                         ? const Color(0xFF10B981)
                         : d.difficulty.toLowerCase() == 'moderate'
                             ? const Color(0xFFF59E0B)
                             : const Color(0xFFEF4444),
      travelTime:      d.travelTime,
      estimatedFare:   d.estimatedFare,
      signal:          d.signalLabel,
      thingsToDo:      d.thingsToDo,
      whatToBring:     d.whatToBring,
      safetyReminders: d.safetyReminders,
      galleryAssets:   d.galleryAssets,
      packages:        const [],
      recommendedRoutes: const [],
    );
  }

  Color _categoryColor(DestinationCategory cat) {
    switch (cat) {
      case DestinationCategory.island:  return const Color(0xFF14B8A6);
      case DestinationCategory.beach:   return const Color(0xFF3B82F6);
      case DestinationCategory.waterfall:return const Color(0xFF06B6D4);
      case DestinationCategory.resort:  return const Color(0xFF8B5CF6);
      case DestinationCategory.mountain:return const Color(0xFF10B981);
      case DestinationCategory.cave:    return const Color(0xFF78716C);
      case DestinationCategory.culturalSite: return const Color(0xFFD97706);
      default:                          return const Color(0xFF64748B);
    }
  }
}
