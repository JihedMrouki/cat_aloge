// import 'package:cat_aloge/core/errors/exceptions.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// abstract class LocalPhotoDataSource {
//   Future<List<AssetEntity>> getLocalPhotos();
//   Future<bool> requestPermission();
// }

// class LocalPhotoDataSourceImpl implements LocalPhotoDataSource {
//   @override
//   Future<List<AssetEntity>> getLocalPhotos() async {
//     try {
//       final PermissionState permission =
//           await PhotoManager.requestPermissionExtend();
//       if (permission != PermissionState.authorized) {
//         throw const PermissionException('Photo permission denied');
//       }

//       final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
//         type: RequestType.image,
//         onlyAll: true,
//       );

//       if (paths.isEmpty) {
//         return [];
//       }

//       final List<AssetEntity> assets = await paths.first.getAssetListRange(
//         start: 0,
//         end: 1000, // Limit to avoid memory issues
//       );

//       return assets;
//     } catch (e) {
//       throw CacheException('Failed to load local photos: $e');
//     }
//   }

//   @override
//   Future<bool> requestPermission() async {
//     try {
//       final PermissionState permission =
//           await PhotoManager.requestPermissionExtend();
//       return permission == PermissionState.authorized;
//     } catch (e) {
//       throw PermissionException('Failed to request permission: $e');
//     }
//   }
// }

// final localPhotoDataSourceProvider = Provider<LocalPhotoDataSource>((ref) {
//   return LocalPhotoDataSourceImpl();
// });
