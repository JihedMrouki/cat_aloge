import 'package:cat_aloge/features/sharing/data/datasources/share_datasource.dart';
import 'package:cat_aloge/features/sharing/data/repository/share_repository_impl.dart';
import 'package:cat_aloge/features/sharing/domain/repositories/share_repository.dart';
import 'package:cat_aloge/features/sharing/domain/usecases/share_cat_photo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shareDataSourceProvider = Provider<ShareDataSource>((ref) {
  return SharePlusDataSource();
});

final shareRepositoryProvider = Provider<ShareRepository>((ref) {
  return ShareRepositoryImpl(ref.watch(shareDataSourceProvider));
});

final shareCatPhotoProvider = Provider<ShareCatPhoto>((ref) {
  return ShareCatPhoto(ref.watch(shareRepositoryProvider) as ShareRepositoryImpl); // Cast needed because ShareCatPhoto expects impl
});
