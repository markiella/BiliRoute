// ─────────────────────────────────────────────────────────────────────────────
// AdminGallery — Gallery photo linked to a destination
// ─────────────────────────────────────────────────────────────────────────────

enum GalleryStatus { draft, published, archived }

class AdminGallery {
  AdminGallery({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.imageAsset,
    required this.status,
    this.caption,
    this.uploadedBy,
    this.isCoverPhoto = false,
    this.isPrimaryFieldPhoto = false,
    this.researchAttribution,
    this.dateUploaded,
  });

  final String    id;
  String          destinationId;
  String          destinationName;
  String          imageAsset;
  GalleryStatus   status;
  String?         caption;
  String?         uploadedBy;
  bool            isCoverPhoto;
  bool            isPrimaryFieldPhoto;
  String?         researchAttribution;
  DateTime?       dateUploaded;

  String get statusLabel {
    switch (status) {
      case GalleryStatus.draft:     return 'Draft';
      case GalleryStatus.published: return 'Published';
      case GalleryStatus.archived:  return 'Archived';
    }
  }

  AdminGallery copyWith({
    String?       destinationId,
    String?       destinationName,
    String?       imageAsset,
    GalleryStatus? status,
    String?       caption,
    String?       uploadedBy,
    bool?         isCoverPhoto,
    bool?         isPrimaryFieldPhoto,
    String?       researchAttribution,
  }) => AdminGallery(
    id:                   id,
    destinationId:        destinationId        ?? this.destinationId,
    destinationName:      destinationName      ?? this.destinationName,
    imageAsset:           imageAsset           ?? this.imageAsset,
    status:               status               ?? this.status,
    caption:              caption              ?? this.caption,
    uploadedBy:           uploadedBy           ?? this.uploadedBy,
    isCoverPhoto:         isCoverPhoto         ?? this.isCoverPhoto,
    isPrimaryFieldPhoto:  isPrimaryFieldPhoto  ?? this.isPrimaryFieldPhoto,
    researchAttribution:  researchAttribution  ?? this.researchAttribution,
    dateUploaded:         dateUploaded,
  );
}
