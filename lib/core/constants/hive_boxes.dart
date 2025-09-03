class HiveBoxes {
  // Settings related boxes
  static const String settings = 'settings_box';
  static const String detectionStats = 'detection_stats_box';

  // Gallery related boxes (for future use)
  static const String catPhotos = 'cat_photos_box';
  static const String favorites = 'favorites_box';
  static const String detectionCache = 'detection_cache_box';

  static const String cache = 'cache_box';

  // User preferences
  static const String userPreferences = 'user_preferences_box';

  // Prevent instantiation
  HiveBoxes._();
}

/// Type IDs for Hive type adapters (if needed for custom objects)
class HiveTypeIds {
  static const int appSettings = 0;
  static const int detectionStats = 1;
  static const int catPhoto = 2;
  static const int favoriteCat = 3;
  static const int detectionResult = 4;

  // Prevent instantiation
  HiveTypeIds._();
}
