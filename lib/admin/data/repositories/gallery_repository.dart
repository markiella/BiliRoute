import '../models/admin_gallery.dart';
import 'base_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GalleryRepository — Seeded from destination galleryAssets
// ─────────────────────────────────────────────────────────────────────────────

class GalleryRepository extends BaseRepository<AdminGallery> {
  GalleryRepository() {
    _seedGallery();
  }

  void _seedGallery() {
    seed(_seedData);
  }

  @override
  String idOf(AdminGallery item) => item.id;

  @override
  AdminGallery? getById(String id) {
    try {
      return items.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AdminGallery> forDestination(String destinationId) =>
      items.where((g) => g.destinationId == destinationId).toList();

  List<AdminGallery> getPublished() =>
      items.where((g) => g.status == GalleryStatus.published).toList();

  AdminGallery? getCoverPhoto(String destinationId) {
    try {
      return items.firstWhere(
        (g) => g.destinationId == destinationId && g.isCoverPhoto,
      );
    } catch (_) {
      return null;
    }
  }

  /// Sets the given photo as cover for its destination (clears others).
  void setCoverPhoto(String galleryId) {
    final photo = getById(galleryId);
    if (photo == null) return;
    // Clear existing cover for this destination
    for (int i = 0; i < items.length; i++) {
      if (items[i].destinationId == photo.destinationId && items[i].isCoverPhoto) {
        updateAt(i, items[i].copyWith(isCoverPhoto: false));
      }
    }
    // Set new cover
    final idx = indexById(galleryId);
    if (idx != -1) updateAt(idx, photo.copyWith(isCoverPhoto: true));
  }

  void updateGallery(AdminGallery updated) {
    final idx = indexById(updated.id);
    if (idx == -1) return;
    updateAt(idx, updated);
  }

  static final List<AdminGallery> _seedData = [
    // Sambawan Island
    AdminGallery(
      id:                  'gal-001',
      destinationId:       'sambawan_island',
      destinationName:     'Sambawan Island',
      imageAsset:          'assets/images/sambawan.jpg',
      status:              GalleryStatus.published,
      isCoverPhoto:        true,
      isPrimaryFieldPhoto: true,
      caption:             'Sambawan Island sandbar at low tide',
      uploadedBy:          'BiliRoute Research Team',
      researchAttribution: 'Field Survey — March 2025',
      dateUploaded:        DateTime(2025, 3, 15),
    ),
    AdminGallery(
      id:              'gal-002',
      destinationId:   'sambawan_island',
      destinationName: 'Sambawan Island',
      imageAsset:      'assets/images/higatangan.jpg',
      status:          GalleryStatus.published,
      caption:         'Aerial view of surrounding waters',
      uploadedBy:      'BiliRoute Research Team',
      dateUploaded:    DateTime(2025, 3, 15),
    ),
    AdminGallery(
      id:              'gal-003',
      destinationId:   'sambawan_island',
      destinationName: 'Sambawan Island',
      imageAsset:      'assets/images/maripipi.jpg',
      status:          GalleryStatus.published,
      caption:         'Maripipi Island view from Sambawan',
      uploadedBy:      'BiliRoute Research Team',
      dateUploaded:    DateTime(2025, 3, 15),
    ),
    // Agta Beach
    AdminGallery(
      id:              'gal-004',
      destinationId:   'agta_beach',
      destinationName: 'Agta Beach',
      imageAsset:      'assets/images/agta.JPG',
      status:          GalleryStatus.published,
      isCoverPhoto:    true,
      caption:         'Agta Beach — white sand shoreline',
      uploadedBy:      'BiliRoute Research Team',
      dateUploaded:    DateTime(2025, 1, 20),
    ),
    // Higatangan Island
    AdminGallery(
      id:              'gal-005',
      destinationId:   'higatangan_island',
      destinationName: 'Higatangan Island',
      imageAsset:      'assets/images/higatangan.jpg',
      status:          GalleryStatus.published,
      isCoverPhoto:    true,
      caption:         'Higatangan Island sandbar',
      uploadedBy:      'BiliRoute Research Team',
      dateUploaded:    DateTime(2025, 1, 20),
    ),
    // Dalutan Island
    AdminGallery(
      id:              'gal-006',
      destinationId:   'dalutan_island',
      destinationName: 'Dalutan Island',
      imageAsset:      'assets/images/dalutan.jpg',
      status:          GalleryStatus.published,
      isCoverPhoto:    true,
      caption:         'Dalutan Island coastal view',
      uploadedBy:      'BiliRoute Research Team',
      dateUploaded:    DateTime(2025, 1, 20),
    ),
  ];
}
