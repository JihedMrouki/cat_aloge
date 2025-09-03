import 'package:cat_aloge/features/permissions/data/datasources/permission_datasource.dart';
import 'package:cat_aloge/features/permissions/domain/entities/permission_state.dart';
import 'package:cat_aloge/features/permissions/domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionDataSource _dataSource;

  PermissionRepositoryImpl(this._dataSource);

  @override
  Future<PermissionState> checkPhotoPermission() async {
    return await _dataSource.checkPhotoPermission();
  }

  @override
  Future<PermissionState> requestPhotoPermission() async {
    return await _dataSource.requestPhotoPermission();
  }

  @override
  Future<void> openAppSettings() async {
    return await _dataSource.openAppSettings();
  }
}
