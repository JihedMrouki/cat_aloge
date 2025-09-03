import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart';
import 'package:cat_aloge/features/settings/domain/entities/detection_stats.dart';

abstract class SettingsRepository {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<DetectionStats> loadDetectionStats();
  Future<void> saveDetectionStats(DetectionStats stats);
  Future<void> resetToDefaults();
  Future<void> clearCache();
}
