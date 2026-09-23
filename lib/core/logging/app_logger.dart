import 'package:logger/logger.dart';

/// Centralized application logger.
///
/// Do not create Logger instances randomly throughout the app.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: false,
      printEmojis: false,
    ),
  );

  static void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.d(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.i(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }
}