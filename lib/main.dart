import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_theme.dart';
import 'core/network/connectivity_service.dart';
import 'core/sync/central_sync_engine.dart';
import 'core/sync/sync_queue_service.dart';
import 'database/isar_service.dart';
import 'firebase_options.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FLUTTER ERROR HANDLING
  // ============================================================

  FlutterError.onError = (
    FlutterErrorDetails details,
  ) {
    FlutterError.presentError(details);

    debugPrint(
      'Flutter Error: ${details.exception}',
    );

    if (details.stack != null) {
      debugPrintStack(
        stackTrace: details.stack!,
      );
    }
  };

  // ============================================================
  // FIREBASE + ISAR + CONNECTIVITY
  // ============================================================
  //
  // These services are independent during startup.
  // Initialize them concurrently to reduce cold-start time.
  //
  // ConnectivityService is initialized before the sync
  // lifecycle starts so CentralSyncEngine always receives
  // a real connectivity state.
  // ============================================================

  bool firebaseInitialized = false;
  bool isarInitialized = false;
  bool connectivityInitialized = false;

  final initializationResults =
      await Future.wait<bool>([
    _initializeFirebase(),
    _initializeIsar(),
    _initializeConnectivity(),
  ]);

  firebaseInitialized =
      initializationResults[0];

  isarInitialized =
      initializationResults[1];

  connectivityInitialized =
      initializationResults[2];

  debugPrint(
    'Startup initialization completed. '
    'Firebase=$firebaseInitialized, '
    'Isar=$isarInitialized, '
    'Connectivity=$connectivityInitialized',
  );

  // ============================================================
  // START APP FIRST
  // ============================================================
  //
  // Sync lifecycle starts after the first Flutter frame.
  // This keeps background sync work away from initial rendering.
  // ============================================================

  runApp(
    ProviderScope(
      child: SatvaDharaApp(
        firebaseInitialized:
            firebaseInitialized,
        isarInitialized:
            isarInitialized,
      ),
    ),
  );

  // ============================================================
  // POST-FRAME V3 SYNC LIFECYCLE
  // ============================================================

  if (firebaseInitialized &&
      isarInitialized &&
      connectivityInitialized) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        SyncLifecycleManager.instance.start();
      },
    );
  }
}

// ============================================================
// FIREBASE INITIALIZATION
// ============================================================

Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint(
      'Firebase initialized successfully.',
    );

    return true;
  } catch (e, stackTrace) {
    debugPrint(
      'Firebase initialization failed: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    return false;
  }
}

// ============================================================
// ISAR INITIALIZATION
// ============================================================

Future<bool> _initializeIsar() async {
  try {
    await IsarService.instance;

    debugPrint(
      'Isar database initialized successfully.',
    );

    return true;
  } catch (e, stackTrace) {
    debugPrint(
      'Isar DB initialization failed: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    return false;
  }
}

// ============================================================
// CONNECTIVITY INITIALIZATION
// ============================================================

Future<bool> _initializeConnectivity() async {
  try {
    await ConnectivityService.instance
        .initialize();

    debugPrint(
      'Connectivity service initialized successfully. '
      'Connected=${ConnectivityService.instance.isConnected}',
    );

    return true;
  } catch (e, stackTrace) {
    debugPrint(
      'Connectivity service initialization failed: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    return false;
  }
}

// ============================================================
// V3 SYNC LIFECYCLE MANAGER
// ============================================================

class SyncLifecycleManager {
  SyncLifecycleManager._();

  static final SyncLifecycleManager instance =
      SyncLifecycleManager._();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final ConnectivityService
      _connectivity =
      ConnectivityService.instance;

  final CentralSyncEngine _syncEngine =
      CentralSyncEngine.instance;

  StreamSubscription<User?>?
      _authSubscription;

  StreamSubscription<bool>?
      _connectivitySubscription;

  Timer? _periodicSyncTimer;

  bool _started = false;

  // Prevent overlapping lifecycle-triggered
  // sync calls.
  //
  // If another trigger arrives while sync is
  // running, one follow-up sync is requested.
  bool _syncInProgress = false;

  bool _syncRequestedAgain = false;

  // ============================================================
  // START
  // ============================================================

  void start() {
    if (_started) {
      return;
    }

    _started = true;

    debugPrint(
      'V3 Sync Lifecycle Manager started.',
    );

    // ----------------------------------------------------------
    // AUTH STATE
    // ----------------------------------------------------------

    _authSubscription =
        _auth.authStateChanges().listen(
      _handleAuthStateChanged,
      onError: (
        Object error,
        StackTrace stackTrace,
      ) {
        debugPrint(
          'Firebase Auth state listener error: '
          '$error',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      },
    );

    // ----------------------------------------------------------
    // CONNECTIVITY
    // ----------------------------------------------------------
    //
    // ConnectivityService is now the single source
    // of truth for network state.
    // ----------------------------------------------------------

    _connectivitySubscription =
        _connectivity.statusStream.listen(
      _handleConnectivityChanged,
      onError: (
        Object error,
        StackTrace stackTrace,
      ) {
        debugPrint(
          'Connectivity service listener error: '
          '$error',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      },
    );

    // ----------------------------------------------------------
    // PERIODIC SAFETY SYNC
    // ----------------------------------------------------------
    //
    // This is a fallback in case:
    //
    // - connectivity event is missed
    // - Firebase reconnects later
    // - platform network state changes unexpectedly
    //
    // CentralSyncEngine checks the actual
    // ConnectivityService state before syncing.
    // ----------------------------------------------------------

    _periodicSyncTimer =
        Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        _syncNow(
          reason: 'periodic',
        );
      },
    );

    // ----------------------------------------------------------
    // INITIAL SYNC
    // ----------------------------------------------------------

    if (_auth.currentUser != null) {
      _syncNow(
        reason: 'application-start',
      );
    }
  }

  // ============================================================
  // AUTH STATE CHANGED
  // ============================================================

  void _handleAuthStateChanged(
    User? user,
  ) {
    if (user == null) {
      debugPrint(
        'No authenticated user. '
        'V3 sync waiting for login.',
      );

      return;
    }

    debugPrint(
      'Authenticated user detected: '
      '${user.uid}',
    );

    _syncNow(
      reason: 'authentication',
    );
  }

  // ============================================================
  // CONNECTIVITY CHANGED
  // ============================================================

  void _handleConnectivityChanged(
    bool connected,
  ) {
    if (!connected) {
      debugPrint(
        'Device is offline. '
        'V3 sync paused.',
      );

      return;
    }

    debugPrint(
      'Network connection detected. '
      'Starting V3 sync.',
    );

    _syncNow(
      reason: 'connectivity-restored',
    );
  }

  // ============================================================
  // SYNC NOW
  // ============================================================

  Future<void> _syncNow({
    required String reason,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        'V3 sync skipped [$reason]: '
        'user is not authenticated.',
      );

      return;
    }

    if (_syncInProgress) {
      _syncRequestedAgain = true;

      debugPrint(
        'V3 sync request queued [$reason]: '
        'another sync is already running.',
      );

      return;
    }

    _syncInProgress = true;

    try {
      var currentReason = reason;

      do {
        _syncRequestedAgain = false;

        final currentUser =
            _auth.currentUser;

        if (currentUser == null) {
          debugPrint(
            'V3 sync stopped [$currentReason]: '
            'user is no longer authenticated.',
          );

          break;
        }

        debugPrint(
          'V3 sync triggered. '
          'Reason: $currentReason',
        );

        final result =
            await _syncEngine.processQueue(
          batchSize: 50,
        );

        if (result.processed == 0) {
          debugPrint(
            'V3 sync completed [$currentReason]: '
            'no pending local operations.',
          );
        } else {
          debugPrint(
            'V3 sync result [$currentReason]: '
            'processed=${result.processed}, '
            'succeeded=${result.succeeded}, '
            'failed=${result.failed}, '
            'conflicts=${result.conflicts}, '
            'skipped=${result.skipped}',
          );
        }

        // ------------------------------------------------------
        // CLEAN OLD COMPLETED OPERATIONS
        // ------------------------------------------------------

        if (result.succeeded > 0) {
          try {
            await SyncQueueService.instance
                .cleanCompletedOperations(
              olderThan:
                  const Duration(days: 7),
            );
          } catch (e, stackTrace) {
            debugPrint(
              'Sync queue cleanup failed: $e',
            );

            debugPrintStack(
              stackTrace: stackTrace,
            );
          }
        }

        if (_syncRequestedAgain) {
          currentReason =
              'queued-follow-up';
        }
      } while (_syncRequestedAgain);
    } catch (e, stackTrace) {
      debugPrint(
        'V3 sync failed [$reason]: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      _syncInProgress = false;
      _syncRequestedAgain = false;
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    if (!_started) {
      return;
    }

    _started = false;

    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;

    await _authSubscription?.cancel();
    _authSubscription = null;

    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    debugPrint(
      'V3 Sync Lifecycle Manager disposed.',
    );
  }
}

// ============================================================
// APP
// ============================================================

class SatvaDharaApp extends StatelessWidget {
  const SatvaDharaApp({
    super.key,
    required this.firebaseInitialized,
    required this.isarInitialized,
  });

  final bool firebaseInitialized;
  final bool isarInitialized;

  @override
  Widget build(
    BuildContext context,
  ) {
    if (!firebaseInitialized ||
        !isarInitialized) {
      return MaterialApp(
        title: 'Satva Dhara ERP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'App सुरू करता आली नाही. '
                'कृपया internet/configuration '
                'तपासून पुन्हा प्रयत्न करा.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'सत्व धारा डेअरी फार्म',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}