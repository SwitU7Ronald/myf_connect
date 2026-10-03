import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Standardized logger for the application.
abstract class LoggerService {
  void debug(String message, [Object? error, StackTrace? stackTrace]);
  void info(String message);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

class LoggerServiceImpl implements LoggerService {
  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stack: $stackTrace');
    }
  }

  @override
  void info(String message) {
    debugPrint('ℹ️ INFO: $message');
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('⚠️ WARNING: $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('Stack: $stackTrace');
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('🛑 ERROR: $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('Stack: $stackTrace');

    // Send to Crashlytics
    try {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: false,
      );
    } catch (e) {
      debugPrint('Failed to send error to Crashlytics: $e');
    }
  }
}
