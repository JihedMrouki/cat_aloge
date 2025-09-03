enum PhotoPermissionStatus {
  notRequested,
  denied,
  granted,
  permanentlyDenied,
  restricted,
}

class PermissionState {
  final PhotoPermissionStatus status;
  final String message;
  final bool canRequestAgain;

  const PermissionState({
    required this.status,
    required this.message,
    required this.canRequestAgain,
  });

  bool get isGranted => status == PhotoPermissionStatus.granted;
  bool get isDenied => status == PhotoPermissionStatus.denied;
  bool get isPermanentlyDenied =>
      status == PhotoPermissionStatus.permanentlyDenied;
  bool get isRestricted => status == PhotoPermissionStatus.restricted;

  factory PermissionState.granted() {
    return const PermissionState(
      status: PhotoPermissionStatus.granted,
      message: 'Photo access granted. You can now view your cat photos!',
      canRequestAgain: false,
    );
  }

  factory PermissionState.denied() {
    return const PermissionState(
      status: PhotoPermissionStatus.denied,
      message: 'Photo access is needed to find and organize your cat photos.',
      canRequestAgain: true,
    );
  }

  factory PermissionState.permanentlyDenied() {
    return const PermissionState(
      status: PhotoPermissionStatus.permanentlyDenied,
      message:
          'Photo access was permanently denied. Please enable it in Settings to use the app.',
      canRequestAgain: false,
    );
  }

  factory PermissionState.restricted() {
    return const PermissionState(
      status: PhotoPermissionStatus.restricted,
      message:
          'Photo access is restricted by device policy or parental controls.',
      canRequestAgain: false,
    );
  }

  factory PermissionState.notRequested() {
    return const PermissionState(
      status: PhotoPermissionStatus.notRequested,
      message:
          'Grant photo access to automatically find and organize your cat photos with AI detection.',
      canRequestAgain: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionState &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;

  @override
  String toString() {
    return 'PermissionState{status: $status, message: $message, canRequestAgain: $canRequestAgain}';
  }
}
