/// Base application exception.
class AppException implements Exception {
  const AppException(
    this.message, {
    this.code,
    this.cause,
    this.stackTrace,
  });

  final String message;

  /// Stable machine-readable error code.
  final String? code;

  /// Original exception, when available.
  final Object? cause;

  final StackTrace? stackTrace;

  @override
  String toString() {
    if (code == null) {
      return message;
    }

    return '[$code] $message';
  }
}

/// Database related failure.
class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Firebase / remote API failure.
class RemoteException extends AppException {
  const RemoteException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Authentication failure.
class AuthenticationException extends AppException {
  const AuthenticationException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Network/connectivity failure.
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Sync failure.
class SyncException extends AppException {
  const SyncException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });
}