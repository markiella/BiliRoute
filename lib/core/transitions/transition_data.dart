/// Carries shared transition metadata through the GoRouter `extra` parameter
/// across the full BiliRoute tourism flow:
///
///   Map Modal → Route Selection → Generating → Itinerary Result
///
/// Keeping a single `heroTag` ensures Flutter's Hero widget animates the
/// destination image seamlessly across all four screens.
class TransitionPayload {
  const TransitionPayload({
    required this.destinationName,
    required this.heroTag,
    this.imageAsset,
  });

  /// e.g. "Sambawan Island"
  final String  destinationName;

  /// Unique hero tag, e.g. "dest_image_sambawan"
  final String  heroTag;

  /// Path to the local asset, e.g. "assets/images/sambawan.jpg"
  final String? imageAsset;

  /// Convenience factory for map destination IDs.
  factory TransitionPayload.fromDestination({
    required String id,
    required String name,
    String? imageAsset,
  }) =>
      TransitionPayload(
        destinationName: name,
        heroTag:         'dest_image_$id',
        imageAsset:      imageAsset,
      );

  /// Creates a copy with optional field overrides.
  TransitionPayload copyWith({
    String? destinationName,
    String? heroTag,
    String? imageAsset,
  }) =>
      TransitionPayload(
        destinationName: destinationName ?? this.destinationName,
        heroTag:         heroTag         ?? this.heroTag,
        imageAsset:      imageAsset      ?? this.imageAsset,
      );

  @override
  String toString() =>
      'TransitionPayload(dest: $destinationName, tag: $heroTag)';
}
