import 'package:cat_aloge/features/settings/data/datasources/local_settings_datasource.dart';
import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart';
import 'package:cat_aloge/features/settings/domain/entities/detection_stats.dart';
import 'package:cat_aloge/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final LocalSettingsDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<AppSettings> loadSettings() async {
    return await _localDataSource.loadSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _localDataSource.saveSettings(settings);
  }

  @override
  Future<DetectionStats> loadDetectionStats() async {
    return await _localDataSource.loadDetectionStats();
  }

  @override
  Future<void> saveDetectionStats(DetectionStats stats) async {
    await _localDataSource.saveDetectionStats(stats);
  }

  @override
  Future<void> resetToDefaults() async {
    final defaultSettings = AppSettings.defaults();
    await saveSettings(defaultSettings);
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearAllSettings();
  }
}
