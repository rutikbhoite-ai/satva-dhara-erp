import 'package:flutter_test/flutter_test.dart';
import 'package:satva_dhara_erp/core/errors/app_exception.dart';
import 'package:satva_dhara_erp/core/result/app_result.dart';

void main() {
  group('AppResult', () {
    test('Success exposes data and success state', () {
      const result = Success<String>('milk saved');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, 'milk saved');
      expect(result.error, isNull);
    });

    test('Failure exposes exception and failure state', () {
      const exception = DatabaseException(
        'Database write failed',
        code: 'database_write_failed',
      );
      const result = Failure<String>(exception);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.data, isNull);
      expect(result.error, same(exception));
    });

    test('AppException formats message with code', () {
      const exception = AppException(
        'Permission denied',
        code: 'permission_denied',
      );

      expect(exception.toString(), '[permission_denied] Permission denied');
    });

    test('specialized exceptions preserve their type', () {
      const authentication = AuthenticationException('Login required');
      const network = NetworkException('Offline');
      const remote = RemoteException('Firebase unavailable');
      const sync = SyncException('Sync failed');

      expect(authentication, isA<AuthenticationException>());
      expect(network, isA<NetworkException>());
      expect(remote, isA<RemoteException>());
      expect(sync, isA<SyncException>());
    });
  });
}
