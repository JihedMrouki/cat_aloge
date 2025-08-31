import 'dart:math';

import 'package:cat_aloge/features/gallery/data/models/detection_result_model.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo_model.dart';

abstract class PhotoDataSource {
  Future<List<CatPhotoModel>> getPhotos();
  Future<List<CatPhotoModel>> refreshPhotos();
  Future<DetectionResultModel> detectCat(String photoPath);
}

class MockPhotoDataSource implements PhotoDataSource {
  static final List<CatPhotoModel> _cachedPhotos = [];
  final Random _random = Random();

  // Mock cat photo URLs from various sources
  static const List<String> _mockCatUrls = [
    'https://cataas.com/cat/says/Hello?fontSize=50&fontColor=white',
    'https://cataas.com/cat/cute?width=400&height=300',
    'https://cataas.com/cat/orange?width=400&height=300',
    'https://cataas.com/cat/fluffy?width=400&height=300',
    'https://cataas.com/cat/sleepy?width=400&height=300',
    'https://cataas.com/cat/playful?width=400&height=300',
    'https://cataas.com/cat/striped?width=400&height=300',
    'https://cataas.com/cat/white?width=400&height=300',
    'https://cataas.com/cat/black?width=400&height=300',
    'https://cataas.com/cat/gray?width=400&height=300',
    'https://cataas.com/cat/kitten?width=400&height=300',
    'https://cataas.com/cat/maine-coon?width=400&height=300',
  ];

  @override
  Future<List<CatPhotoModel>> getPhotos() async {
    if (_cachedPhotos.isNotEmpty) {
      return List.from(_cachedPhotos);
    }

    return await refreshPhotos();
  }

  @override
  Future<List<CatPhotoModel>> refreshPhotos() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    _cachedPhotos.clear();

    // Generate 12 random cat photos
    for (int i = 0; i < 12; i++) {
      final photoId = 'cat_${DateTime.now().millisecondsSinceEpoch}_$i';
      final url =
          _mockCatUrls[i % _mockCatUrls.length] +
          '&timestamp=${DateTime.now().millisecondsSinceEpoch + i}';

      final photo = CatPhotoModel(
        id: photoId,
        url: url,
        path: '/mock/path/$photoId.jpg',
        confidence: 0.75 + (_random.nextDouble() * 0.25), // 75-100% confidence
        isFavorite: _random.nextBool() && i % 4 == 0, // Some random favorites
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      );

      _cachedPhotos.add(photo);
    }

    return List.from(_cachedPhotos);
  }

  @override
  Future<DetectionResultModel> detectCat(String photoPath) async {
    // Simulate ML processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate random detection result
    final confidence = 0.7 + (_random.nextDouble() * 0.3); // 70-100%

    return DetectionResultModel(
      confidence: confidence,
      hasCat: confidence > 0.6,
      boundingBoxes: [
        BoundingBoxModel(
          x: _random.nextDouble() * 0.3, // 0-30% of image width
          y: _random.nextDouble() * 0.3, // 0-30% of image height
          width: 0.4 + (_random.nextDouble() * 0.3), // 40-70% of image
          height: 0.4 + (_random.nextDouble() * 0.3), // 40-70% of image
        ),
      ],
    );
  }
}
