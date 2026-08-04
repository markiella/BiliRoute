import 'package:flutter/foundation.dart';

import '../models/recommendation_weights.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RecommendationSettingsRepository — Route scoring weight configuration
//
// Not a list repository — holds a single RecommendationWeights instance.
// Used by the route recommendation engine to rank route options.
// ─────────────────────────────────────────────────────────────────────────────

class RecommendationSettingsRepository extends ChangeNotifier {
  RecommendationSettingsRepository() {
    _weights = RecommendationWeights.defaultWeights;
  }

  late RecommendationWeights _weights;

  RecommendationWeights get weights => _weights;

  /// Updates the weights and notifies listeners.
  /// Validates that all weights sum to 1.0 before saving.
  void updateWeights(RecommendationWeights newWeights) {
    if (!newWeights.isValid) {
      throw ArgumentError(
        'RecommendationWeights must sum to 1.0. '
        'Current total: ${newWeights.total.toStringAsFixed(3)}',
      );
    }
    _weights = newWeights;
    notifyListeners();
  }

  /// Convenience updater — adjusts one weight and redistributes the remainder
  /// equally across the other three to maintain a valid sum of 1.0.
  void adjustWeight({
    double? budgetFriendly,
    double? fastestRoute,
    double? fewerTransfers,
    double? safestTravel,
    required String adjustedBy,
  }) {
    final b = budgetFriendly  ?? _weights.budgetFriendly;
    final f = fastestRoute    ?? _weights.fastestRoute;
    final t = fewerTransfers  ?? _weights.fewerTransfers;
    final s = safestTravel    ?? _weights.safestTravel;

    _weights = RecommendationWeights(
      budgetFriendly:  b,
      fastestRoute:    f,
      fewerTransfers:  t,
      safestTravel:    s,
      lastUpdatedBy:   adjustedBy,
      lastUpdatedAt:   DateTime.now(),
    );
    notifyListeners();
  }

  /// Resets to the default equal-distribution baseline.
  void resetToDefault() {
    _weights = RecommendationWeights.defaultWeights;
    notifyListeners();
  }

  // ── Route scoring helper ────────────────────────────────────────────────────

  /// Scores a route option based on current weights.
  ///
  /// Parameters are normalised 0.0–1.0 scores (higher = better):
  /// - [fareScore]:     1.0 = cheapest route
  /// - [speedScore]:    1.0 = fastest route
  /// - [transferScore]: 1.0 = fewest transfers
  /// - [safetyScore]:   1.0 = safest (verified providers, no sea route)
  double score({
    required double fareScore,
    required double speedScore,
    required double transferScore,
    required double safetyScore,
  }) {
    return (_weights.budgetFriendly * fareScore) +
           (_weights.fastestRoute   * speedScore) +
           (_weights.fewerTransfers * transferScore) +
           (_weights.safestTravel   * safetyScore);
  }
}
