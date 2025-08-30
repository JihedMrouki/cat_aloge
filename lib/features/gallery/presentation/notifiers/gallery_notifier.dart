import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/gallery_state.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/app_constants.dart';

class GalleryNotifier extends StateNotifier<GalleryState> {
  GalleryNotifier() : super(const GalleryState()) {
    AppLogger.info('GalleryNotifier initialized');
  }

  // Load photos (with mock data for now)
  Future<void> loadPhotos() async {
    AppLogger.info('Loading photos...');

    state = state.copyWith(status: GalleryStatus.loading, errorMessage: null);

    try {
      // Simulate network/file system delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock data - replace with real photo loading later
      final mockPhotos = _generateMockPhotos();

      state = state.copyWith(status: GalleryStatus.loaded, photos: mockPhotos);

      AppLogger.info('Loaded ${mockPhotos.length} photos');
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load photos', error, stackTrace);

      state = state.copyWith(
        status: GalleryStatus.error,
        errorMessage: AppConstants.genericError,
      );
    }
  }

  // Refresh photos
  Future<void> refreshPhotos() async {
    AppLogger.info('Refreshing photos...');

    state = state.copyWith(isRefreshing: true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Generate new mock data (simulate getting updated photos)
      final refreshedPhotos = _generateMockPhotos();

      state = state.copyWith(
        status: GalleryStatus.loaded,
        photos: refreshedPhotos,
        isRefreshing: false,
      );

      AppLogger.info('Refreshed with ${refreshedPhotos.length} photos');
    } catch (error, stackTrace) {
      AppLogger.error('Failed to refresh photos', error, stackTrace);

      state = state.copyWith(
        status: GalleryStatus.error,
        errorMessage: AppConstants.networkError,
        isRefreshing: false,
      );
    }
  }

  // Toggle favorite status
  void toggleFavorite(String photoId) {
    AppLogger.info('Toggling favorite for photo: $photoId');

    final updatedPhotos = state.photos.map((photo) {
      if (photo.id == photoId) {
        final newFavoriteStatus = !photo.isFavorite;
        AppLogger.info('Photo $photoId favorite: $newFavoriteStatus');
        return photo.copyWith(isFavorite: newFavoriteStatus);
      }
      return photo;
    }).toList();

    state = state.copyWith(photos: updatedPhotos);
  }

  // Simulate error
  void simulateError() {
    AppLogger.warning('Simulating error state');

    state = state.copyWith(
      status: GalleryStatus.error,
      errorMessage: 'Simulated error for testing',
    );
  }

  // Clear error and reset to initial state
  void clearError() {
    AppLogger.info('Clearing error state');

    state = state.copyWith(status: GalleryStatus.initial, errorMessage: null);
  }

  // Generate mock data for testing
  List<CatPhoto> _generateMockPhotos() {
    return List.generate(12, (index) {
      return CatPhoto(
        id: 'cat_$index',
        path: 'assets/mock_cat_$index.jpg',
        name: 'Cute Cat ${index + 1}',
        dateAdded: DateTime.now().subtract(Duration(days: index)),
        isFavorite: index % 4 == 0, // Every 4th photo is a favorite
        confidence: 0.8 + (index * 0.01), // Mock confidence scores
      );
    });
  }
}
