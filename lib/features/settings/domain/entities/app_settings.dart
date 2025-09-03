enum DetectionMode {
  fast,
  balanced,
  accurate,
}

enum ThemeMode {
  system,
  light,
  dark,
}

class AppSettings {
  final double detectionSensitivity;
  final DetectionMode detectionMode;
  final int maxPhotosToProcess;
  final ThemeMode themeMode;
  final bool showConfidenceScores;
  final bool enableHapticFeedback;
  final bool enableBackgroundScanning;
  final bool autoRefreshGallery;

  const AppSettings({
    required this.detectionSensitivity,
    required this.detectionMode,
    required this.maxPhotosToProcess,
    required this.themeMode,
    required this.showConfidenceScores,
    required this.enableHapticFeedback,
    required this.enableBackgroundScanning,
    required this.autoRefreshGallery,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      detectionSensitivity: 0.7,
      detectionMode: DetectionMode.balanced,
      maxPhotosToProcess: 1000,
      themeMode: ThemeMode.system,
      showConfidenceScores: false,
      enableHapticFeedback: true,
      enableBackgroundScanning: false,
      autoRefreshGallery: true,
    );
  }

  AppSettings copyWith({
    double? detectionSensitivity,
    DetectionMode? detectionMode,
    int? maxPhotosToProcess,
    ThemeMode? themeMode,
    bool? showConfidenceScores,
    bool? enableHapticFeedback,
    bool? enableBackgroundScanning,
    bool? autoRefreshGallery,
  }) {
    return AppSettings(
      detectionSensitivity: detectionSensitivity ?? this.detectionSensitivity,
      detectionMode: detectionMode ?? this.detectionMode,
      maxPhotosToProcess: maxPhotosToProcess ?? this.maxPhotosToProcess,
      themeMode: themeMode ?? this.themeMode,
      showConfidenceScores: showConfidenceScores ?? this.showConfidenceScores,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableBackgroundScanning:
          enableBackgroundScanning ?? this.enableBackgroundScanning,
      autoRefreshGallery: autoRefreshGallery ?? this.autoRefreshGallery,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'detectionSensitivity': detectionSensitivity,
      'detectionMode': detectionMode.index,
      'maxPhotosToProcess': maxPhotosToProcess,
      'themeMode': themeMode.index,
      'showConfidenceScores': showConfidenceScores,
      'enableHapticFeedback': enableHapticFeedback,
      'enableBackgroundScanning': enableBackgroundScanning,
      'autoRefreshGallery': autoRefreshGallery,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      detectionSensitivity: map['detectionSensitivity']?.toDouble() ?? 0.7,
      detectionMode: DetectionMode
          .values[map['detectionMode'] ?? DetectionMode.balanced.index],
      maxPhotosToProcess: map['maxPhotosToProcess']?.toInt() ?? 1000,
      themeMode: ThemeMode.values[map['themeMode'] ?? ThemeMode.system.index],
      showConfidenceScores: map['showConfidenceScores'] ?? false,
      enableHapticFeedback: map['enableHapticFeedback'] ?? true,
      enableBackgroundScanning: map['enableBackgroundScanning'] ?? false,
      autoRefreshGallery: map['autoRefreshGallery'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          detectionSensitivity == other.detectionSensitivity &&
          detectionMode == other.detectionMode &&
          maxPhotosToProcess == other.maxPhotosToProcess &&
          themeMode == other.themeMode &&
          showConfidenceScores == other.showConfidenceScores &&
          enableHapticFeedback == other.enableHapticFeedback &&
          enableBackgroundScanning == other.enableBackgroundScanning &&
          autoRefreshGallery == other.autoRefreshGallery;

  @override
  int get hashCode => Object.hash(
        detectionSensitivity,
        detectionMode,
        maxPhotosToProcess,
        themeMode,
        showConfidenceScores,
        enableHapticFeedback,
        enableBackgroundScanning,
        autoRefreshGallery,
      );

  @override
  String toString() {
    return 'AppSettings(detectionSensitivity: $detectionSensitivity, '
        'detectionMode: $detectionMode, maxPhotosToProcess: $maxPhotosToProcess, '
        'themeMode: $themeMode, showConfidenceScores: $showConfidenceScores, '
        'enableHapticFeedback: $enableHapticFeedback, '
        'enableBackgroundScanning: $enableBackgroundScanning, '
        'autoRefreshGallery: $autoRefreshGallery)';
  }
}
