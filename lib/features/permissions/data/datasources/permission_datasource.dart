import 'package:permission_handler/permission_handler.dart';
import 'package:cat_aloge/features/permissions/domain/entities/permission_state.dart';

abstract class PermissionDataSource {
  Future<PermissionState> checkPhotoPermission();
  Future<PermissionState> requestPhotoPermission();
  Future<void> openAppSettings();
}

class PermissionDataSourceImpl implements PermissionDataSource {
  @override
  Future<PermissionState> checkPhotoPermission() async {
    final status = await Permission.photos.status;
    return _mapPermissionStatus(status);
  }

  @override
  Future<PermissionState> requestPhotoPermission() async {
    final status = await Permission.photos.request();
    return _mapPermissionStatus(status);
  }

  @override
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  PermissionState _mapPermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return PermissionState.granted();
      case PermissionStatus.denied:
        return PermissionState.denied();
      case PermissionStatus.permanentlyDenied:
        return PermissionState.permanentlyDenied();
      case PermissionStatus.restricted:
        return PermissionState.restricted();
      case PermissionStatus.provisional:
        return PermissionState.notRequested();
    }
  }
}
