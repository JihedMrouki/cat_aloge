class AppConstants {
  // App Info
  static const String appName = 'Cat Gallery';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered cat photo organizer';

  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Grid Settings
  static const int gridCrossAxisCount = 2;
  static const double gridAspectRatio = 1.0;
  static const double gridSpacing = 8.0;

  // Image Settings
  static const double catImageSize = 200.0;
  static const double thumbnailSize = 100.0;
  static const int imageQuality = 85;

  // ML Model Settings
  static const double confidenceThreshold = 0.7;
  static const int maxDetections = 10;

  // Storage Keys
  static const String favoritesBoxKey = 'favorites';
  static const String settingsBoxKey = 'settings';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'No internet connection. Please check your network.';
  static const String permissionDenied =
      'Permission denied. Please grant access to photos.';
  static const String noPhotosFound = 'No photos found on your device.';
  static const String noCatsDetected = 'No cats detected in your photos.';

  // Success Messages
  static const String photoSaved = 'Photo saved to favorites!';
  static const String photoRemoved = 'Photo removed from favorites.';
  static const String photoShared = 'Photo shared successfully!';

  // Loading Messages
  static const String loadingPhotos = 'Loading your photos...';
  static const String detectingCats = 'Detecting cats...';
  static const String processingImage = 'Processing image...';
}
