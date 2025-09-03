import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/permissions/data/datasources/permission_datasource.dart';
import 'package:cat_aloge/features/permissions/data/repositories/permission_repository_impl.dart';
import 'package:cat_aloge/features/permissions/domain/entities/permission_state.dart';
import 'package:cat_aloge/features/permissions/domain/repositories/permission_repository.dart';
import 'package:cat_aloge/features/permissions/domain/usecases/check_photo_permission.dart';
import 'package:cat_aloge/features/permissions/domain/usecases/open_app_settings.dart';
import 'package:cat_aloge/features/permissions/domain/usecases/request_photo_permission.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data Source Provider
final permissionDataSourceProvider = Provider<PermissionDataSource>((ref) {
  return PermissionDataSourceImpl();
});

// Repository Provider
final permissionRepositoryProvider = Provider<PermissionRepository>((ref) {
  return PermissionRepositoryImpl(ref.read(permissionDataSourceProvider));
});

// Use Case Providers
final checkPhotoPermissionUseCaseProvider =
    Provider<CheckPhotoPermissionUseCase>((ref) {
  return CheckPhotoPermissionUseCase(ref.read(permissionRepositoryProvider));
});

final requestPhotoPermissionUseCaseProvider =
    Provider<RequestPhotoPermissionUseCase>((ref) {
  return RequestPhotoPermissionUseCase(ref.read(permissionRepositoryProvider));
});

final openAppSettingsUseCaseProvider = Provider<OpenAppSettingsUseCase>((ref) {
  return OpenAppSettingsUseCase(ref.read(permissionRepositoryProvider));
});

// Main Permission State Provider
final photoPermissionProvider =
    StateNotifierProvider<PhotoPermissionNotifier, AsyncValue<PermissionState>>(
  (ref) {
    return PhotoPermissionNotifier(
      ref.read(checkPhotoPermissionUseCaseProvider),
      ref.read(requestPhotoPermissionUseCaseProvider),
      ref.read(openAppSettingsUseCaseProvider),
    );
  },
);

class PhotoPermissionNotifier
    extends StateNotifier<AsyncValue<PermissionState>> {
  final CheckPhotoPermissionUseCase _checkPermissionUseCase;
  final RequestPhotoPermissionUseCase _requestPermissionUseCase;
  final OpenAppSettingsUseCase _openSettingsUseCase;

  PhotoPermissionNotifier(
    this._checkPermissionUseCase,
    this._requestPermissionUseCase,
    this._openSettingsUseCase,
  ) : super(const AsyncValue.loading()) {
    _checkInitialPermission();
  }

  Future<void> _checkInitialPermission() async {
    try {
      AppLogger.info('Checking initial photo permission status');
      final permissionState = await _checkPermissionUseCase.call();
      state = AsyncValue.data(permissionState);
      AppLogger.info('Initial permission status: ${permissionState.status}');
    } catch (e, stackTrace) {
      AppLogger.error('Error checking initial permission', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> requestPermission() async {
    AppLogger.info('User requesting photo permission');

    // Don't set loading if we already have a granted permission
    final currentState = state.asData?.value;
    if (currentState?.isGranted == true) return;

    state = const AsyncValue.loading();

    try {
      final permissionState = await _requestPermissionUseCase.call();
      state = AsyncValue.data(permissionState);

      if (permissionState.isGranted) {
        AppLogger.info('Photo permission granted successfully');
      } else {
        AppLogger.warning(
          'Photo permission denied: ${permissionState.status} - ${permissionState.message}',
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
      await _openSettingsUseCase.call();

      // Recheck permission after a short delay (user might return from settings)
      await Future.delayed(const Duration(milliseconds: 500));
      await recheckPermission();
    } catch (e, stackTrace) {
      AppLogger.error('Error opening settings', e, stackTrace);
    }
  }

  Future<void> recheckPermission() async {
    try {
      AppLogger.info('Rechecking photo permission status');
      final permissionState = await _checkPermissionUseCase.call();
      state = AsyncValue.data(permissionState);
      AppLogger.info('Rechecked permission status: ${permissionState.status}');
    } catch (e, stackTrace) {
      AppLogger.error('Error rechecking permission', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Helper method to check if we need to show permission screen
  bool get shouldShowPermissionScreen {
    return state.asData?.value.isGranted != true;
  }

  // Helper method to get current permission status
  PhotoPermissionStatus? get currentStatus {
    return state.asData?.value.status;
  }
}
