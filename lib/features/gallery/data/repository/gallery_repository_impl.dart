// import 'package:cat_aloge/features/gallery/domain/repository/gallery_repository.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uuid/uuid.dart';
// import 'package:path/path.dart' as path;

// import '../../domain/entities/cat_photo.dart';
// import '../../domain/entities/detection_result.dart';

// import '../datasources/local_photo_datasource.dart';
// import '../datasources/ml_detection_datasource.dart';
// import '../../../../core/errors/exceptions.dart';

// class GalleryRepositoryImpl implements GalleryRepository {
//   final LocalPhotoDataSource _localDataSource;
//   final MlDetectionDataSource _mlDataSource;
//   final Uuid _uuid = const Uuid();

//   GalleryRepositoryImpl(this._localDataSource, this._mlDataSource);

//   @override
//   Future<List<CatPhoto>> getCatPhotos() async {
//     try {
//       final assets = await _localDataSource.getLocalPhotos();
//       final catPhotos = <CatPhoto>[];

//       for (final asset in assets) {
//         final file = await asset.file;
//         if (file == null) continue;

//         final detectionResult = await _mlDataSource.detectCats(file.path);

//         if (detectionResult.hasCat) {
//           final catPhoto = CatPhoto(
//             id: _uuid.v4(),
//             path: file.path,
//             name: _generateCatName(file.path),
//             dateAdded: asset.createDateTime,
//             detectionResult: detectionResult,
//             metadata: PhotoMetadata(
//               width: asset.width,
//               height: asset.height,
//               fileSize: await asset.size,
//               dateTaken: asset.createDateTime,
//             ),
//           );
//           catPhotos.add(catPhoto);
//         }
//       }

//       return catPhotos;
//     } catch (e) {
//       throw CacheException('Failed to get cat photos: $e');
//     }
//   }

//   @override
//   Future<List<CatPhoto>> refreshCatPhotos() async {
//     return await getCatPhotos();
//   }

//   @override
//   Future<DetectionResult> detectCatsInPhoto(String imagePath) async {
//     try {
//       return await _mlDataSource.detectCats(imagePath);
//     } catch (e) {
//       throw MLModelException('Failed to detect cats: $e');
//     }
//   }

//   @override
//   Future<void> clearCache() async {
//     // Implement cache clearing logic if needed
//   }

//   String _generateCatName(String filePath) {
//     final fileName = path.basenameWithoutExtension(filePath);
//     return 'Cat from $fileName';
//   }
// }

// final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
//   final localDataSource = ref.read(localPhotoDataSourceProvider);
//   final mlDataSource = ref.read(mlDetectionDataSourceProvider);
//   return GalleryRepositoryImpl(localDataSource, mlDataSource);
// });
