class DetectionStats {
  final int totalPhotosScanned;
  final int catPhotosFound;
  final DateTime lastScanTime;
  final double averageConfidence;
  final Duration totalProcessingTime;

  const DetectionStats({
    required this.totalPhotosScanned,
    required this.catPhotosFound,
    required this.lastScanTime,
    required this.averageConfidence,
    required this.totalProcessingTime,
  });

  double get detectionRate =>
      totalPhotosScanned > 0 ? catPhotosFound / totalPhotosScanned : 0.0;

  factory DetectionStats.empty() {
    return DetectionStats(
      totalPhotosScanned: 0,
      catPhotosFound: 0,
      lastScanTime: DateTime.now(),
      averageConfidence: 0.0,
      totalProcessingTime: Duration.zero,
    );
  }

  DetectionStats copyWith({
    int? totalPhotosScanned,
    int? catPhotosFound,
    DateTime? lastScanTime,
    double? averageConfidence,
    Duration? totalProcessingTime,
  }) {
    return DetectionStats(
      totalPhotosScanned: totalPhotosScanned ?? this.totalPhotosScanned,
      catPhotosFound: catPhotosFound ?? this.catPhotosFound,
      lastScanTime: lastScanTime ?? this.lastScanTime,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      totalProcessingTime: totalProcessingTime ?? this.totalProcessingTime,
    );
  }

  @override
  String toString() {
    return 'DetectionStats(totalPhotosScanned: $totalPhotosScanned, '
        'catPhotosFound: $catPhotosFound, lastScanTime: $lastScanTime, '
        'averageConfidence: $averageConfidence, totalProcessingTime: $totalProcessingTime)';
  }
}
