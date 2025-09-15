import 'package:cat_aloge/features/permissions/data/datasources/permission_datasource.dart';
import 'package:cat_aloge/features/permissions/data/repositories/permission_repository_impl.dart';
import 'package:cat_aloge/features/permissions/domain/repositories/permission_repository.dart';
import 'package:cat_aloge/features/permissions/domain/usecases/check_photo_permission.dart';
import 'package:cat_aloge/features/permissions/domain/usecases/request_photo_permission.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final permissionDataSourceProvider = Provider<PermissionDataSource>((ref) {
  return PermissionDataSourceImpl();
});

final permissionRepositoryProvider = Provider<PermissionRepository>((ref) {
  return PermissionRepositoryImpl(ref.watch(permissionDataSourceProvider));
});

final checkPhotoPermissionUseCaseProvider = Provider<CheckPhotoPermissionUseCase>((ref) {
  return CheckPhotoPermissionUseCase(ref.watch(permissionRepositoryProvider));
});

final requestPhotoPermissionUseCaseProvider = Provider<RequestPhotoPermissionUseCase>((ref) {
  return RequestPhotoPermissionUseCase(ref.watch(permissionRepositoryProvider));
});
