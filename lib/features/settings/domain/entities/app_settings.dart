class AppSettings {
  final double detectionSensitivity;
  final bool enableBackgroundScanning;
  final bool showConfidenceScores;
  final bool enableHapticFeedback;
  final ThemeMode themeMode;
  final DetectionMode detectionMode;
  final int maxPhotosToProcess;
  final bool autoRefreshGallery;
  final Duration refreshInterval;

  const AppSettings({
    this.detectionSensitivity = 0.7,
    this.enableBackgroundScanning = false,
    this.showConfidenceScores = true,
    this.enableHapticFeedback = true,
    this.themeMode = ThemeMode.system,
    this.detectionMode = DetectionMode.balanced,
    this.maxPhotosToProcess = 1000,
    this.autoRefreshGallery = false,
    this.refreshInterval = const Duration(hours: 6),
  });

  AppSettings copyWith({
    double? detectionSensitivity,
    bool? enableBackgroundScanning,
    bool? showConfidenceScores,
    bool? enableHapticFeedback,
    ThemeMode? themeMode,
    DetectionMode? detectionMode,
    int? maxPhotosToProcess,
    bool? autoRefreshGallery,
    Duration? refreshInterval,
  }) {
    return AppSettings(
      detectionSensitivity: detectionSensitivity ?? this.detectionSensitivity,
      enableBackgroundScanning:
          enableBackgroundScanning ?? this.enableBackgroundScanning,
      showConfidenceScores: showConfidenceScores ?? this.showConfidenceScores,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      themeMode: themeMode ?? this.themeMode,
      detectionMode: detectionMode ?? this.detectionMode,
      maxPhotosToProcess: maxPhotosToProcess ?? this.maxPhotosToProcess,
      autoRefreshGallery: autoRefreshGallery ?? this.autoRefreshGallery,
      refreshInterval: refreshInterval ?? this.refreshInterval,
    );
  }

  @override
  List<Object?> get props => [
    detectionSensitivity,
    enableBackgroundScanning,
    showConfidenceScores,
    enableHapticFeedback,
    themeMode,
    detectionMode,
    maxPhotosToProcess,
    autoRefreshGallery,
    refreshInterval,
  ];
}

enum ThemeMode { light, dark, system }

enum DetectionMode {
  fast, // Lower accuracy, faster processing
  balanced, // Good balance of speed and accuracy
  accurate, // Higher accuracy, slower processing
}
