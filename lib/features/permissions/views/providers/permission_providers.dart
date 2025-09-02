import 'package:cat_aloge/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final permissionDataSourceProvider = Provider<PermissionDataSource>((ref) {
  return PermissionDataSourceImpl();
});

final photoPermissionProvider =
    StateNotifierProvider<PhotoPermissionNotifier, AsyncValue<PermissionState>>(
      (ref) {
        return PhotoPermissionNotifier(ref.read(permissionDataSourceProvider));
      },
    );

class PhotoPermissionNotifier
    extends StateNotifier<AsyncValue<PermissionState>> {
  final PermissionDataSource _dataSource;

  PhotoPermissionNotifier(this._dataSource)
    : super(const AsyncValue.loading()) {
    _checkInitialPermission();
  }

  Future<void> _checkInitialPermission() async {
    try {
      AppLogger.info('Checking initial photo permission status');
      final permissionState = await _dataSource.checkPhotoPermission();
      state = AsyncValue.data(permissionState);
    } catch (e, stackTrace) {
      AppLogger.error('Error checking initial permission', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> requestPermission() async {
    AppLogger.info('User requesting photo permission');
    state = const AsyncValue.loading();

    try {
      final permissionState = await _dataSource.requestPhotoPermission();
      state = AsyncValue.data(permissionState);

      if (permissionState.isGranted) {
        AppLogger.info('Photo permission granted successfully');
      } else {
        AppLogger.warning(
          'Photo permission denied: ${permissionState.message}',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting permission', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> openSettings() async {
    try {
      AppLogger.info('Opening app settings for photo permission');
      await _dataSource.openAppSettings();

      // Recheck permission after user returns from settings
      await Future.delayed(const Duration(seconds: 1));
      await _checkInitialPermission();
    } catch (e, stackTrace) {
      AppLogger.error('Error opening settings', e, stackTrace);
    }
  }

  Future<void> recheckPermission() async {
    await _checkInitialPermission();
  }
}
