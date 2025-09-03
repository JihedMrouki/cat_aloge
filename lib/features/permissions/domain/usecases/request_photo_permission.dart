import 'package:cat_aloge/features/permissions/domain/entities/permission_state.dart';
import 'package:cat_aloge/features/permissions/domain/repositories/permission_repository.dart';

class RequestPhotoPermissionUseCase {
  final PermissionRepository _repository;

  RequestPhotoPermissionUseCase(this._repository);

  Future<PermissionState> call() async {
    return await _repository.requestPhotoPermission();
  }
}
