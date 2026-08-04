// ─────────────────────────────────────────────────────────────────────────────
// RecommendationWeights — Route recommendation scoring configuration
//
// Controls how the route ranking engine weights the 4 preference criteria.
// All 4 weights must sum to 1.0 (100%).
// Default: equal distribution (0.25 each).
//
// Used by the mobile route recommendation engine to rank route options:
//   score = (budgetFriendly × fareScore)
//         + (fastestRoute   × speedScore)
//         + (fewerTransfers × transferScore)
//         + (safestTravel   × safetyScore)
// ─────────────────────────────────────────────────────────────────────────────

class RecommendationWeights {
  const RecommendationWeights({
    required this.budgetFriendly,
    required this.fastestRoute,
    required this.fewerTransfers,
    required this.safestTravel,
    this.lastUpdatedBy,
    this.lastUpdatedAt,
  });

  /// Weight for minimising total fare (₱). Range: 0.0 – 1.0.
  final double  budgetFriendly;

  /// Weight for minimising total travel time. Range: 0.0 – 1.0.
  final double  fastestRoute;

  /// Weight for minimising number of transport transfers. Range: 0.0 – 1.0.
  final double  fewerTransfers;

  /// Weight for safer/verified routes and sea-crossing risk reduction.
  /// Range: 0.0 – 1.0.
  final double  safestTravel;

  final String?   lastUpdatedBy;
  final DateTime? lastUpdatedAt;

  /// Default equal-distribution weights (thesis baseline).
  static const RecommendationWeights defaultWeights = RecommendationWeights(
    budgetFriendly: 0.25,
    fastestRoute:   0.25,
    fewerTransfers: 0.25,
    safestTravel:   0.25,
  );

  /// Validation: all weights must sum to 1.0 (within floating-point tolerance).
  bool get isValid => (total - 1.0).abs() < 0.001;

  double get total =>
      budgetFriendly + fastestRoute + fewerTransfers + safestTravel;

  /// Returns weights as percentages (0–100) for UI sliders.
  int get budgetPercent    => (budgetFriendly  * 100).round();
  int get fastestPercent   => (fastestRoute    * 100).round();
  int get transfersPercent => (fewerTransfers  * 100).round();
  int get safetyPercent    => (safestTravel    * 100).round();

  RecommendationWeights copyWith({
    double?   budgetFriendly,
    double?   fastestRoute,
    double?   fewerTransfers,
    double?   safestTravel,
    String?   lastUpdatedBy,
    DateTime? lastUpdatedAt,
  }) => RecommendationWeights(
    budgetFriendly:  budgetFriendly  ?? this.budgetFriendly,
    fastestRoute:    fastestRoute    ?? this.fastestRoute,
    fewerTransfers:  fewerTransfers  ?? this.fewerTransfers,
    safestTravel:    safestTravel    ?? this.safestTravel,
    lastUpdatedBy:   lastUpdatedBy   ?? this.lastUpdatedBy,
    lastUpdatedAt:   lastUpdatedAt   ?? this.lastUpdatedAt,
  );

  @override
  String toString() =>
      'Budget:$budgetPercent% Fastest:$fastestPercent% '
      'Transfers:$transfersPercent% Safety:$safetyPercent%';
}
