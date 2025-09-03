import 'package:cat_aloge/features/permissions/domain/entities/permission_state.dart';
import 'package:cat_aloge/features/permissions/domain/repositories/permission_repository.dart';

class CheckPhotoPermissionUseCase {
  final PermissionRepository _repository;

  CheckPhotoPermissionUseCase(this._repository);

  Future<PermissionState> call() async {
    return await _repository.checkPhotoPermission();
  }
}
