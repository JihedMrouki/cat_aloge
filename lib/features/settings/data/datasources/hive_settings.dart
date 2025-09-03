// import 'package:cat_aloge/core/constants/hive_boxes.dart';
// import 'package:cat_aloge/core/utils/logger.dart';
// import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart';
// import 'package:hive/hive.dart';

// abstract class SettingsDataSource {
//   Future<AppSettings> getSettings();
//   Future<void> saveSettings(AppSettings settings);
//   Future<void> resetToDefaults();
// }

// class HiveSettingsDataSource implements SettingsDataSource {
//   static const String _settingsKey = 'app_settings';

//   Box<Map>? _box;

//   Future<void> _ensureBoxOpen() async {
//     if (_box?.isOpen == true) return;

//     try {
//       _box = await Hive.openBox<Map>(HiveBoxes.settings);
//       AppLogger.info('Settings box opened successfully');
//     } catch (e, stackTrace) {
//       AppLogger.error('Failed to open settings box', e, stackTrace);
//       rethrow;
//     }
//   }

//   @override
//   Future<AppSettings> getSettings() async {
//     await _ensureBoxOpen();

//     try {
//       final settingsMap = _box!.get(_settingsKey);

//       if (settingsMap == null) {
//         AppLogger.info('No saved settings found, returning defaults');
//         return const AppSettings();
//       }

//       return _mapToSettings(Map<String, dynamic>.from(settingsMap));
//     } catch (e, stackTrace) {
//       AppLogger.error('Error loading settings', e, stackTrace);
//       return const AppSettings(); // Return defaults on error
//     }
//   }

//   @override
//   Future<void> saveSettings(AppSettings settings) async {
//     await _ensureBoxOpen();

//     try {
//       final settingsMap = _settingsToMap(settings);
//       await _box!.put(_settingsKey, settingsMap);

//       AppLogger.info('Settings saved successfully');
//     } catch (e, stackTrace) {
//       AppLogger.error('Error saving settings', e, stackTrace);
//       rethrow;
//     }
//   }

//   @override
//   Future<void> resetToDefaults() async {
//     await _ensureBoxOpen();

//     try {
//       await _box!.delete(_settingsKey);
//       AppLogger.info('Settings reset to defaults');
//     } catch (e, stackTrace) {
//       AppLogger.error('Error resetting settings', e, stackTrace);
//       rethrow;
//     }
//   }

//   Map<String, dynamic> _settingsToMap(AppSettings settings) {
//     return {
//       'detectionSensitivity': settings.detectionSensitivity,
//       'enableBackgroundScanning': settings.enableBackgroundScanning,
//       'showConfidenceScores': settings.showConfidenceScores,
//       'enableHapticFeedback': settings.enableHapticFeedback,
//       'themeMode': settings.themeMode.name,
//       'detectionMode': settings.detectionMode.name,
//       'maxPhotosToProcess': settings.maxPhotosToProcess,
//       'autoRefreshGallery': settings.autoRefreshGallery,
//       'refreshIntervalHours': settings.refreshInterval.inHours,
//     };
//   }

//   AppSettings _mapToSettings(Map<String, dynamic> map) {
//     return AppSettings(
//       detectionSensitivity:
//           (map['detectionSensitivity'] as num?)?.toDouble() ?? 0.7,
//       enableBackgroundScanning:
//           map['enableBackgroundScanning'] as bool? ?? false,
//       showConfidenceScores: map['showConfidenceScores'] as bool? ?? true,
//       enableHapticFeedback: map['enableHapticFeedback'] as bool? ?? true,
//       themeMode: _parseThemeMode(map['themeMode'] as String?),
//       detectionMode: _parseDetectionMode(map['detectionMode'] as String?),
//       maxPhotosToProcess: map['maxPhotosToProcess'] as int? ?? 1000,
//       autoRefreshGallery: map['autoRefreshGallery'] as bool? ?? false,
//       refreshInterval: Duration(
//         hours: map['refreshIntervalHours'] as int? ?? 6,
//       ),
//     );
//   }

//   ThemeMode _parseThemeMode(String? value) {
//     switch (value) {
//       case 'light':
//         return ThemeMode.light;
//       case 'dark':
//         return ThemeMode.dark;
//       case 'system':
//       default:
//         return ThemeMode.system;
//     }
//   }

//   DetectionMode _parseDetectionMode(String? value) {
//     switch (value) {
//       case 'fast':
//         return DetectionMode.fast;
//       case 'balanced':
//         return DetectionMode.balanced;
//       case 'accurate':
//         return DetectionMode.accurate;
//       default:
//         return DetectionMode.balanced;
//     }
//   }
// }
