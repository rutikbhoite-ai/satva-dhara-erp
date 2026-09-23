import '../errors/app_exception.dart';

/// Represents the result of an application operation.
///
/// V3 uses an explicit success/failure result instead of relying on
/// nullable values or throwing exceptions for expected application errors.
sealed class AppResult<T> {
  const AppResult();

  /// Returns true when the operation was successful.
  bool get isSuccess => this is Success<T>;

  /// Returns true when the operation failed.
  bool get isFailure => this is Failure<T>;

  /// Returns the successful data, otherwise null.
  T? get data => null;

  /// Returns the application error, otherwise null.
  AppException? get error => null;
}

/// Successful application operation.
final class Success<T> extends AppResult<T> {
  const Success(this.data);

  @override
  final T data;
}

/// Failed application operation.
final class Failure<T> extends AppResult<T> {
  const Failure(this.exception);

  @override
  AppException? get error => exception;

  final AppException exception;
}