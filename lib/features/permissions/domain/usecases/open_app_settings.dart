import 'package:cat_aloge/features/permissions/domain/repositories/permission_repository.dart';

class OpenAppSettingsUseCase {
  final PermissionRepository _repository;

  OpenAppSettingsUseCase(this._repository);

  Future<void> call() async {
    return await _repository.openAppSettings();
  }
}
