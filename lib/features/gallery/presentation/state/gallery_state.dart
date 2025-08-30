// Simple data models for our state
class CatPhoto {
  final String id;
  final String path;
  final String name;
  final DateTime dateAdded;
  final bool isFavorite;
  final double? confidence;

  const CatPhoto({
    required this.id,
    required this.path,
    required this.name,
    required this.dateAdded,
    this.isFavorite = false,
    this.confidence,
  });

  CatPhoto copyWith({
    String? id,
    String? path,
    String? name,
    DateTime? dateAdded,
    bool? isFavorite,
    double? confidence,
  }) {
    return CatPhoto(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavorite: isFavorite ?? this.isFavorite,
      confidence: confidence ?? this.confidence,
    );
  }
}

enum GalleryStatus { initial, loading, loaded, error }

class GalleryState {
  final GalleryStatus status;
  final List<CatPhoto> photos;
  final String? errorMessage;
  final bool isRefreshing;

  const GalleryState({
    this.status = GalleryStatus.initial,
    this.photos = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  GalleryState copyWith({
    GalleryStatus? status,
    List<CatPhoto>? photos,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return GalleryState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  // Convenience getters
  bool get isLoading => status == GalleryStatus.loading;
  bool get hasError => status == GalleryStatus.error;
  bool get hasPhotos => photos.isNotEmpty;
  List<CatPhoto> get favoritePhotos =>
      photos.where((p) => p.isFavorite).toList();
}
