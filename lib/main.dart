import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_theme.dart';
import 'core/network/connectivity_service.dart';
import 'features/auth/data/auth_profile_service.dart';
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
  // FIREBASE + CONNECTIVITY
  // ============================================================
  //
  // Firebase and connectivity are independent during startup.
  // The Isar database is initialized lazily after a valid user/farm
  // profile is available, so local data is always account-scoped.
  //
  // ConnectivityService is initialized before the sync
  // lifecycle starts so CentralSyncEngine always receives
  // a real connectivity state.
  // ============================================================

  bool firebaseInitialized = false;
  bool connectivityInitialized = false;

  final initializationResults =
      await Future.wait<bool>([
    _initializeFirebase(),
    _initializeConnectivity(),
  ]);

  firebaseInitialized =
      initializationResults[0];

  connectivityInitialized =
      initializationResults[1];

  debugPrint(
    'Startup initialization completed. '
    'Firebase=$firebaseInitialized, '
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
      ),
    ),
  );

  // ============================================================
  // POST-FRAME V3 SYNC LIFECYCLE
  // ============================================================

  if (firebaseInitialized &&
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

  Completer<void>? _syncCompletion;

  int _sessionGeneration = 0;

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
    _sessionGeneration++;
    final generation = _sessionGeneration;

    _handleUserSessionChanged(
      user,
      generation: generation,
    );
  }

  Future<void> _handleUserSessionChanged(
    User? user, {
    required int generation,
  }) async {
    if (user == null) {
      // Never close Isar while a sync transaction may still be using
      // it. Wait for the active lifecycle sync to finish first.
      final activeSync = _syncCompletion;

      if (activeSync != null) {
        await activeSync.future;
      }

      if (generation != _sessionGeneration) {
        return;
      }

      await IsarService.close();

      debugPrint(
        'No authenticated user. '
        'Scoped local database closed; V3 sync waiting for login.',
      );

      return;
    }

    debugPrint(
      'Authenticated user detected: '
      '${user.uid}',
    );

    try {
      final profile =
          await AuthProfileService.instance.getCurrentProfile();

      if (generation != _sessionGeneration) {
        return;
      }

      if (profile == null || !profile.canUseApplication) {
        await IsarService.close();

        debugPrint(
          'Authenticated user does not have a valid active farm profile. '
          'Scoped local database remains closed.',
        );

        return;
      }

      if (generation != _sessionGeneration) {
        return;
      }

      await IsarService.initializeForScope(
        uid: profile.uid,
        farmId: profile.farmId,
      );

      if (generation != _sessionGeneration) {
        return;
      }

      await _syncNow(
        reason: 'authentication',
      );
    } catch (e, stackTrace) {
      if (generation == _sessionGeneration) {
        await IsarService.close();
      }

      debugPrint(
        'User session initialization failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
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
    final completion = Completer<void>();
    _syncCompletion = completion;

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

      if (!completion.isCompleted) {
        completion.complete();
      }

      if (identical(_syncCompletion, completion)) {
        _syncCompletion = null;
      }
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
  });

  final bool firebaseInitialized;

  @override
  Widget build(
    BuildContext context,
  ) {
    if (!firebaseInitialized) {
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