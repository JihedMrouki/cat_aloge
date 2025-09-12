import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';

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
