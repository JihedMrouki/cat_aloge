import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/settings/data/datasources/hive_settings.dart';
import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsDataSourceProvider = Provider<SettingsDataSource>((ref) {
  return HiveSettingsDataSource();
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
      return SettingsNotifier(ref.read(settingsDataSourceProvider));
    });

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsDataSource _dataSource;

  SettingsNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _dataSource.getSettings();
      state = AsyncValue.data(settings);
      AppLogger.info('Settings loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error loading settings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateDetectionSensitivity(double sensitivity) async {
    await _updateSetting(
      (settings) => settings.copyWith(detectionSensitivity: sensitivity),
    );
  }

  Future<void> updateBackgroundScanning(bool enabled) async {
    await _updateSetting(
      (settings) => settings.copyWith(enableBackgroundScanning: enabled),
    );
  }

  Future<void> updateShowConfidenceScores(bool show) async {
    await _updateSetting(
      (settings) => settings.copyWith(showConfidenceScores: show),
    );
  }

  Future<void> updateHapticFeedback(bool enabled) async {
    await _updateSetting(
      (settings) => settings.copyWith(enableHapticFeedback: enabled),
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _updateSetting((settings) => settings.copyWith(themeMode: mode));
  }

  Future<void> updateDetectionMode(DetectionMode mode) async {
    await _updateSetting((settings) => settings.copyWith(detectionMode: mode));
  }

  Future<void> updateMaxPhotosToProcess(int maxPhotos) async {
    await _updateSetting(
      (settings) => settings.copyWith(maxPhotosToProcess: maxPhotos),
    );
  }

  Future<void> updateAutoRefresh(bool enabled) async {
    await _updateSetting(
      (settings) => settings.copyWith(autoRefreshGallery: enabled),
    );
  }

  Future<void> resetToDefaults() async {
    try {
      AppLogger.info('Resetting settings to defaults');
      await _dataSource.resetToDefaults();
      state = const AsyncValue.data(AppSettings());
      AppLogger.info('Settings reset successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error resetting settings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> _updateSetting(AppSettings Function(AppSettings) updater) async {
    final currentState = state;
    if (currentState is! AsyncData<AppSettings>) return;

    try {
      final currentSettings = currentState.value;
      final newSettings = updater(currentSettings);

      // Optimistically update UI
      state = AsyncValue.data(newSettings);

      // Save to storage
      await _dataSource.saveSettings(newSettings);

      AppLogger.debug('Setting updated successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating setting', e, stackTrace);

      // Revert on error
      state = currentState;
      rethrow;
    }
  }
}
