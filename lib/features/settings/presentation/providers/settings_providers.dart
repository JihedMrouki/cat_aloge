import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/features/settings/data/datasources/hive_settings.dart';
import 'package:cat_aloge/features/settings/data/datasources/local_settings_datasource.dart';
import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the concrete implementation of the LocalSettingsDataSource.
final settingsDataSourceProvider = Provider<LocalSettingsDataSource>((ref) {
  // Returns the actual Hive-based implementation of your data source.
  return LocalSettingsDataSourceImpl();
});

/// The main provider for settings, managing the async state and business logic.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  // The notifier is created with a reference to the data source implementation.
  return SettingsNotifier(ref.read(settingsDataSourceProvider));
});

// =========================================================================
// STATE NOTIFIER
// =========================================================================

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final LocalSettingsDataSource _dataSource;

  SettingsNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  /// Loads the initial settings from the data source.
  Future<void> _loadSettings() async {
    try {
      final settings = await _dataSource.loadSettings();
      state = AsyncValue.data(settings);
      AppLogger.info('Settings loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error loading settings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // --- Methods to update individual settings ---

  Future<void> updateDetectionSensitivity(double sensitivity) async {
    await _updateSetting(
        (settings) => settings.copyWith(detectionSensitivity: sensitivity));
  }

  Future<void> updateBackgroundScanning(bool enabled) async {
    await _updateSetting(
        (settings) => settings.copyWith(enableBackgroundScanning: enabled));
  }

  Future<void> updateShowConfidenceScores(bool show) async {
    await _updateSetting(
        (settings) => settings.copyWith(showConfidenceScores: show));
  }

  Future<void> updateHapticFeedback(bool enabled) async {
    await _updateSetting(
        (settings) => settings.copyWith(enableHapticFeedback: enabled));
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _updateSetting((settings) => settings.copyWith(themeMode: mode));
  }

  Future<void> updateDetectionMode(DetectionMode mode) async {
    await _updateSetting((settings) => settings.copyWith(detectionMode: mode));
  }

  Future<void> updateMaxPhotosToProcess(int maxPhotos) async {
    await _updateSetting(
        (settings) => settings.copyWith(maxPhotosToProcess: maxPhotos));
  }

  Future<void> updateAutoRefresh(bool enabled) async {
    await _updateSetting(
        (settings) => settings.copyWith(autoRefreshGallery: enabled));
  }

  // --- Action Methods ---

  /// Resets all settings to their default values by clearing them from storage
  /// and updating the state to the default object.
  Future<void> resetToDefaults() async {
    try {
      AppLogger.info('Resetting settings to defaults');
      // Your data source clears the box.
      await _dataSource.clearAllSettings();
      // Update the UI state to reflect the new default settings.
      state = AsyncValue.data(AppSettings.defaults()); // [FIXED]
      AppLogger.info('Settings reset successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error resetting settings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// **[FIXED]** Clears the settings and stats cache by calling the data source.
  Future<void> clearCache() async {
    try {
      AppLogger.info('Clearing all settings and stats cache');
      // This maps to your data source method that clears both settings and stats boxes.
      await _dataSource.clearAllSettings();
      AppLogger.info('Cache cleared successfully');
      // Note: We don't change the settings state here, as the user might want
      // to continue seeing their current settings until the next app restart.
      // If you wanted to also reset settings, you would call resetToDefaults() here.
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing cache', e, stackTrace);
      rethrow; // Rethrow to let the UI show an error.
    }
  }

  /// Generic helper function to update a setting optimistically.
  Future<void> _updateSetting(AppSettings Function(AppSettings) updater) async {
    final currentState = state;
    // Only update if we have data to begin with.
    if (currentState is! AsyncData<AppSettings>) return;

    try {
      final currentSettings = currentState.value;
      final newSettings = updater(currentSettings);

      // Optimistically update the UI state immediately.
      state = AsyncValue.data(newSettings);

      // Persist the change to the data source.
      await _dataSource.saveSettings(newSettings);

      AppLogger.debug('Setting updated successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating setting', e, stackTrace);
      // If saving fails, revert the state to what it was before.
      state = currentState;
      rethrow;
    }
  }
}
