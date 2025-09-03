import 'package:cat_aloge/features/permissions/domain/entities/permission_state.dart';

abstract class PermissionRepository {
  Future<PermissionState> checkPhotoPermission();
  Future<PermissionState> requestPhotoPermission();
  Future<void> openAppSettings();
}
