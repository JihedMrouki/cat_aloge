import 'package:cat_aloge/core/constants/hive_boxes.dart';
import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart';
import 'package:cat_aloge/features/settings/domain/entities/detection_stats.dart';
import 'package:hive/hive.dart';

abstract class LocalSettingsDataSource {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<DetectionStats> loadDetectionStats();
  Future<void> saveDetectionStats(DetectionStats stats);
  Future<void> clearAllSettings();
}

class LocalSettingsDataSourceImpl implements LocalSettingsDataSource {
  static const String _settingsKey = 'app_settings';
  static const String _statsKey = 'detection_stats';

  Box? _settingsBox;
  Box? _statsBox;

  Future<void> _ensureBoxesOpen() async {
    _settingsBox ??= await Hive.openBox(HiveBoxes.settings);
    _statsBox ??= await Hive.openBox(HiveBoxes.detectionStats);
  }

  @override
  Future<AppSettings> loadSettings() async {
    await _ensureBoxesOpen();

    final settingsMap =
        _settingsBox?.get(_settingsKey) as Map<dynamic, dynamic>?;

    if (settingsMap != null) {
      // Convert dynamic map to string map for AppSettings.fromMap
      final stringMap = Map<String, dynamic>.from(settingsMap);
      return AppSettings.fromMap(stringMap);
    }

    return AppSettings.defaults();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _ensureBoxesOpen();
    await _settingsBox?.put(_settingsKey, settings.toMap());
  }

  @override
  Future<DetectionStats> loadDetectionStats() async {
    await _ensureBoxesOpen();

    final statsMap = _statsBox?.get(_statsKey) as Map<dynamic, dynamic>?;

    if (statsMap != null) {
      try {
        return DetectionStats(
          totalPhotosScanned: statsMap['totalPhotosScanned'] ?? 0,
          catPhotosFound: statsMap['catPhotosFound'] ?? 0,
          lastScanTime: DateTime.parse(
              statsMap['lastScanTime'] ?? DateTime.now().toIso8601String()),
          averageConfidence: (statsMap['averageConfidence'] ?? 0.0).toDouble(),
          totalProcessingTime: Duration(
            milliseconds: statsMap['totalProcessingTimeMs'] ?? 0,
          ),
        );
      } catch (e) {
        // If parsing fails, return empty stats
        return DetectionStats.empty();
      }
    }

    return DetectionStats.empty();
  }

  @override
  Future<void> saveDetectionStats(DetectionStats stats) async {
    await _ensureBoxesOpen();

    final statsMap = {
      'totalPhotosScanned': stats.totalPhotosScanned,
      'catPhotosFound': stats.catPhotosFound,
      'lastScanTime': stats.lastScanTime.toIso8601String(),
      'averageConfidence': stats.averageConfidence,
      'totalProcessingTimeMs': stats.totalProcessingTime.inMilliseconds,
    };

    await _statsBox?.put(_statsKey, statsMap);
  }

  @override
  Future<void> clearAllSettings() async {
    await _ensureBoxesOpen();
    await _settingsBox?.clear();
    await _statsBox?.clear();
  }
}
