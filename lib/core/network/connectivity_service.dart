import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../logging/app_logger.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance =
      ConnectivityService._();

  final Connectivity _connectivity =
      Connectivity();

  StreamSubscription<List<ConnectivityResult>>?
      _subscription;

  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  Stream<bool> get statusStream =>
      _statusController.stream;

  // Safe default:
  // Until the first real connectivity check completes,
  // the application must not assume that network is available.
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    try {
      final result =
          await _connectivity.checkConnectivity();

      _updateStatus(result);

      _subscription =
          _connectivity.onConnectivityChanged.listen(
        _updateStatus,
        onError: (
          Object error,
          StackTrace stackTrace,
        ) {
          AppLogger.error(
            'Connectivity stream error',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );

      AppLogger.info(
        'Connectivity service initialized. '
        'Connected: $_isConnected',
      );
    } catch (e, stackTrace) {
      // If the connectivity check itself fails,
      // keep the application in a safe offline state.
      _isConnected = false;

      AppLogger.error(
        'Connectivity initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _updateStatus(
    List<ConnectivityResult> results,
  ) {
    final connected =
        results.any(
      (result) =>
          result != ConnectivityResult.none,
    );

    if (_isConnected == connected) {
      return;
    }

    _isConnected = connected;

    if (!_statusController.isClosed) {
      _statusController.add(
        connected,
      );
    }

    AppLogger.info(
      connected
          ? 'Network connection available.'
          : 'Device appears to be offline.',
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();

    _subscription = null;

    if (!_statusController.isClosed) {
      await _statusController.close();
    }
  }
}