class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
}

class MLModelException implements Exception {
  final String message;
  const MLModelException(this.message);
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
}
