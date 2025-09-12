import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static const String _prefix = '🐱 CatGallery';

  // Debug logs (only in debug mode)
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  // Info logs
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  // Warning logs
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  // Error logs
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  static void _log(
    LogLevel level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    // Only show debug logs in debug mode
    if (level == LogLevel.debug && !kDebugMode) return;

    final emoji = _getEmoji(level);
    final timestamp = DateTime.now().toString().substring(11, 23);
    final levelStr = level.name.toUpperCase().padRight(7);

    final logMessage = '[$_prefix] $emoji $timestamp [$levelStr] $message';

    // Use different print methods based on level
    switch (level) {
      case LogLevel.debug:
        debugPrint(logMessage);
        break;
      case LogLevel.info:
        debugPrint(logMessage);
        break;
      case LogLevel.warning:
        debugPrint('⚠️  $logMessage');
        break;
      case LogLevel.error:
        debugPrint('❌ $logMessage');
        break;
    }

    // Print error details if provided
    if (error != null) {
      debugPrint('   └── Error: $error');
    }

    // Print stack trace for errors in debug mode
    if (stackTrace != null && kDebugMode && level == LogLevel.error) {
      debugPrint('   └── Stack trace:\n$stackTrace');
    }
  }

  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}

// Convenience methods for common use cases
extension AppLoggerExtensions on Object {
  void logDebug(String message) => AppLogger.debug('$runtimeType: $message');
  void logInfo(String message) => AppLogger.info('$runtimeType: $message');
  void logWarning(String message) =>
      AppLogger.warning('$runtimeType: $message');
  void logError(String message, [dynamic error, StackTrace? stackTrace]) =>
      AppLogger.error('$runtimeType: $message', error, stackTrace);
}
