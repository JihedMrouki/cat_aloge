class AppConstants {
  static const String appName = 'Cat Gallery';
  static const String appVersion = '1.0.0';

  // ML Model Constants
  static const String catDetectionModelPath =
      'assets/models/cat_detection.tflite';
  static const String catClassificationModelPath =
      'assets/models/cat_classification.tflite';
  static const double detectionThreshold = 0.7;

  // Grid Configuration
  static const int galleryGridColumns = 3;
  static const double gridSpacing = 10.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 250);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 750);
}
