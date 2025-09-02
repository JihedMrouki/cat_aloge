// Data Sources
import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/gallery/data/datasources/device_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/data/datasources/local_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/data/datasources/ml_detection_datasource.dart';
import 'package:cat_aloge/features/gallery/data/repository/gallery_repository_impl.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/domain/entities/detection_result.dart';
import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';
import 'package:cat_aloge/features/gallery/domain/usecases/detect_cats_in_photo.dart';
import 'package:cat_aloge/features/gallery/domain/usecases/get_cat_photos.dart';
import 'package:cat_aloge/features/gallery/domain/usecases/refresh_gallery.dart';
import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart';
import 'package:cat_aloge/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mlDetectionDataSourceProvider = Provider<MlDetectionDataSource>((ref) {
  return MlDetectionDataSourceImpl();
});

final localPhotoDataSourceProvider = Provider<LocalPhotoDataSource>((ref) {
  final mlDataSource = ref.read(mlDetectionDataSourceProvider);
  return LocalPhotoDataSourceImpl(mlDataSource);
});

final devicePhotoDataSourceProvider = Provider<DevicePhotoDataSource>((ref) {
  return DevicePhotoDataSourceImpl();
});

// Repository
final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final localDataSource = ref.read(localPhotoDataSourceProvider);
  final mlDataSource = ref.read(mlDetectionDataSourceProvider);
  return GalleryRepositoryImpl(localDataSource, mlDataSource);
});

// Use Cases
final getCatPhotosUsecaseProvider = Provider<GetCatPhotos>((ref) {
  final repository = ref.read(galleryRepositoryProvider);
  return GetCatPhotos(repository);
});

final refreshGalleryUsecaseProvider = Provider<RefreshGallery>((ref) {
  final repository = ref.read(galleryRepositoryProvider);
  return RefreshGallery(repository);
});

final detectCatsUsecaseProvider = Provider<DetectCatsInPhoto>((ref) {
  final repository = ref.read(galleryRepositoryProvider);
  return DetectCatsInPhoto(repository);
});

// Main Gallery State Management
final galleryProvider =
    StateNotifierProvider<GalleryNotifier, AsyncValue<List<CatPhoto>>>((ref) {
      return GalleryNotifier(ref);
    });

class GalleryNotifier extends StateNotifier<AsyncValue<List<CatPhoto>>> {
  final Ref _ref;
  bool _isInitialized = false;

  GalleryNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.info('Initializing gallery notifier...');

      // Initialize ML detection
      final mlDataSource = _ref.read(mlDetectionDataSourceProvider);
      await mlDataSource.initialize();

      _isInitialized = true;

      // Load initial photos
      await loadPhotos();
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing gallery notifier', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadPhotos() async {
    if (!_isInitialized) {
      await _initialize();
      return;
    }

    try {
      AppLogger.info('Loading cat photos...');
      state = const AsyncValue.loading();

      final usecase = _ref.read(getCatPhotosUsecaseProvider);
      final photos = await usecase.call();

      // Apply current settings filters
      final settings = await _ref.read(settingsProvider.future);
      final filteredPhotos = _applySettingsFilters(photos, settings);

      state = AsyncValue.data(filteredPhotos);
      AppLogger.info('Gallery loaded: ${filteredPhotos.length} cat photos');
    } catch (e, stackTrace) {
      AppLogger.error('Error loading photos', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshGallery() async {
    try {
      AppLogger.info('Refreshing gallery...');

      state = const AsyncValue.loading();

      final usecase = _ref.read(refreshGalleryUsecaseProvider);
      await usecase.call();

      // Reload photos after refresh
      await loadPhotos();
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing gallery', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> clearCache() async {
    try {
      AppLogger.info('Clearing gallery cache...');

      final repository = _ref.read(galleryRepositoryProvider);
      await repository.clearCache();

      // Reload photos
      await loadPhotos();
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing cache', e, stackTrace);
    }
  }

  List<CatPhoto> _applySettingsFilters(
    List<CatPhoto> photos,
    AppSettings settings,
  ) {
    // Filter by detection sensitivity
    final filtered = photos.where((photo) {
      final confidence = photo.detectionResult?.confidence ?? 0.0;
      return confidence >= settings.detectionSensitivity;
    }).toList();

    // Limit number of photos if needed
    if (filtered.length > settings.maxPhotosToProcess) {
      // Sort by confidence and take top results
      filtered.sort(
        (a, b) => (b.detectionResult?.confidence ?? 0.0).compareTo(
          a.detectionResult?.confidence ?? 0.0,
        ),
      );
      return filtered.take(settings.maxPhotosToProcess).toList();
    }

    return filtered;
  }
}

// Detection Progress Provider for real-time updates
final detectionProgressProvider =
    StateNotifierProvider<DetectionProgressNotifier, DetectionProgress>((ref) {
      return DetectionProgressNotifier();
    });

class DetectionProgress {
  final int totalPhotos;
  final int processedPhotos;
  final int catsFound;
  final bool isScanning;
  final String? currentPhotoName;
  final Duration? estimatedTimeRemaining;

  const DetectionProgress({
    this.totalPhotos = 0,
    this.processedPhotos = 0,
    this.catsFound = 0,
    this.isScanning = false,
    this.currentPhotoName,
    this.estimatedTimeRemaining,
  });

  double get progress => totalPhotos > 0 ? processedPhotos / totalPhotos : 0.0;
  String get progressText => '$processedPhotos / $totalPhotos';

  DetectionProgress copyWith({
    int? totalPhotos,
    int? processedPhotos,
    int? catsFound,
    bool? isScanning,
    String? currentPhotoName,
    Duration? estimatedTimeRemaining,
  }) {
    return DetectionProgress(
      totalPhotos: totalPhotos ?? this.totalPhotos,
      processedPhotos: processedPhotos ?? this.processedPhotos,
      catsFound: catsFound ?? this.catsFound,
      isScanning: isScanning ?? this.isScanning,
      currentPhotoName: currentPhotoName ?? this.currentPhotoName,
      estimatedTimeRemaining:
          estimatedTimeRemaining ?? this.estimatedTimeRemaining,
    );
  }
}

class DetectionProgressNotifier extends StateNotifier<DetectionProgress> {
  DetectionProgressNotifier() : super(const DetectionProgress());

  void startScanning(int totalPhotos) {
    state = DetectionProgress(
      totalPhotos: totalPhotos,
      isScanning: true,
      processedPhotos: 0,
      catsFound: 0,
    );
    AppLogger.info('Started scanning $totalPhotos photos');
  }

  void updateProgress({
    int? processedPhotos,
    int? catsFound,
    String? currentPhotoName,
  }) {
    if (!state.isScanning) return;

    state = state.copyWith(
      processedPhotos: processedPhotos ?? state.processedPhotos,
      catsFound: catsFound ?? state.catsFound,
      currentPhotoName: currentPhotoName,
      estimatedTimeRemaining: _calculateEstimatedTime(),
    );
  }

  void completedScanning() {
    AppLogger.info(
      'Scanning completed: ${state.catsFound} cats found in ${state.totalPhotos} photos',
    );
    state = state.copyWith(
      isScanning: false,
      currentPhotoName: null,
      estimatedTimeRemaining: null,
    );
  }

  void reset() {
    state = const DetectionProgress();
  }

  Duration? _calculateEstimatedTime() {
    if (state.processedPhotos <= 0) return null;

    final photosRemaining = state.totalPhotos - state.processedPhotos;
    if (photosRemaining <= 0) return Duration.zero;

    // Estimate based on average processing time (250ms per photo)
    const avgTimePerPhoto = Duration(milliseconds: 250);
    return avgTimePerPhoto * photosRemaining;
  }
}

// Gallery Statistics Provider
final galleryStatsProvider = Provider<GalleryStats>((ref) {
  final galleryAsync = ref.watch(galleryProvider);

  return galleryAsync.when(
    data: (photos) => GalleryStats.fromPhotos(photos),
    loading: () => const GalleryStats(),
    error: (_, __) => const GalleryStats(),
  );
});

class GalleryStats {
  final int totalCatPhotos;
  final int favoriteCount;
  final double averageConfidence;
  final Map<ConfidenceLevel, int> confidenceLevels;
  final DateTime? lastScanTime;
  final int totalProcessingTimeMs;

  const GalleryStats({
    this.totalCatPhotos = 0,
    this.favoriteCount = 0,
    this.averageConfidence = 0.0,
    this.confidenceLevels = const {},
    this.lastScanTime,
    this.totalProcessingTimeMs = 0,
  });

  factory GalleryStats.fromPhotos(List<CatPhoto> photos) {
    if (photos.isEmpty) return const GalleryStats();

    final favoriteCount = photos.where((p) => p.isFavorite).length;
    final confidences = photos
        .map((p) => p.detectionResult?.confidence ?? 0.0)
        .where((c) => c > 0.0)
        .toList();

    final averageConfidence = confidences.isNotEmpty
        ? confidences.reduce((a, b) => a + b) / confidences.length
        : 0.0;

    final confidenceLevels = <ConfidenceLevel, int>{};
    for (final photo in photos) {
      final level =
          photo.detectionResult?.confidenceLevel ?? ConfidenceLevel.veryLow;
      confidenceLevels[level] = (confidenceLevels[level] ?? 0) + 1;
    }

    final totalProcessingTime = photos
        .map((p) => p.detectionResult?.processingTimeMs ?? 0)
        .fold<int>(0, (sum, time) => sum + time);

    return GalleryStats(
      totalCatPhotos: photos.length,
      favoriteCount: favoriteCount,
      averageConfidence: averageConfidence,
      confidenceLevels: confidenceLevels,
      lastScanTime: DateTime.now(), // TODO: Get actual last scan time
      totalProcessingTimeMs: totalProcessingTime,
    );
  }

  String get averageConfidenceText =>
      '${(averageConfidence * 100).toStringAsFixed(1)}%';

  String get averageProcessingTimeText {
    if (totalCatPhotos == 0) return '0ms';
    final avgTime = totalProcessingTimeMs / totalCatPhotos;
    return '${avgTime.round()}ms';
  }
}
