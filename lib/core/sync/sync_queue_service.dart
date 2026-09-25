import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../../database/isar_service.dart';
import 'models/sync_operation_model.dart';

class SyncQueueService {
  SyncQueueService._();

  static final SyncQueueService instance =
      SyncQueueService._();

  bool _isProcessing = false;

  // ============================================================
  // ENQUEUE
  // ============================================================

  Future<int> enqueue({
    required String entityType,
    required int localId,
    required String operation,
    String? remoteId,
    Map<String, dynamic>? payload,
  }) async {
    final isar = await IsarService.instance;

    return isar.writeTxn(
      () => enqueueInTransaction(
        isar,
        entityType: entityType,
        localId: localId,
        operation: operation,
        remoteId: remoteId,
        payload: payload,
      ),
    );
  }

  Future<int> enqueueInTransaction(
    Isar isar, {
    required String entityType,
    required int localId,
    required String operation,
    String? remoteId,
    Map<String, dynamic>? payload,
  }) async {
    final now = DateTime.now();

    final candidates = await isar.syncOperationModels
        .filter()
        .entityTypeEqualTo(entityType)
        .localIdEqualTo(localId)
        .findAll();

    final existing = candidates
        .where(
          (item) =>
              item.status == 'pending' ||
              item.status == 'failed',
        )
        .firstOrNull;

    if (existing != null) {
      existing.operation = operation;

      if (remoteId != null &&
          remoteId.trim().isNotEmpty) {
        existing.remoteId = remoteId;
      }

      if (payload != null) {
        existing.payloadJson = jsonEncode(payload);
      }

      existing.nextRetryAt = now;
      existing.lastError = null;

      await isar.syncOperationModels.put(existing);

      return existing.id;
    }

    final item = SyncOperationModel(
      entityType: entityType,
      localId: localId,
      remoteId: remoteId,
      operation: operation,
      status: 'pending',
      retryCount: 0,
      createdAt: now,
      nextRetryAt: now,
      payloadJson:
          payload == null ? null : jsonEncode(payload),
    );

    await isar.syncOperationModels.put(item);

    return item.id;
  }

  // ============================================================
  // GET PENDING OPERATIONS
  // ============================================================

  Future<List<SyncOperationModel>> getPendingOperations({
    int limit = 50,
  }) async {
    final isar = await IsarService.instance;

    final now = DateTime.now();

    final operations = await isar.syncOperationModels
        .filter()
        .statusEqualTo('pending')
        .findAll();

    operations.removeWhere(
      (operation) =>
          operation.nextRetryAt != null &&
          operation.nextRetryAt!.isAfter(now),
    );

    operations.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );

    if (operations.length <= limit) {
      return operations;
    }

    return operations.take(limit).toList();
  }

  // ============================================================
  // PREPARE DUE FAILED OPERATIONS
  // ============================================================

  /// Converts failed operations whose retry time has arrived
  /// back to pending state.
  ///
  /// This is what makes automatic retry possible.
  Future<int> prepareDueFailedOperations() async {
    final isar = await IsarService.instance;

    final now = DateTime.now();

    final failedOperations = await isar.syncOperationModels
        .filter()
        .statusEqualTo('failed')
        .findAll();

    final dueOperations = failedOperations.where(
      (operation) {
        final retryAt = operation.nextRetryAt;

        if (retryAt == null) {
          return true;
        }

        return !retryAt.isAfter(now);
      },
    ).toList();

    if (dueOperations.isEmpty) {
      return 0;
    }

    await isar.writeTxn(() async {
      for (final operation in dueOperations) {
        operation.status = 'pending';
        operation.lastError = null;

        await isar.syncOperationModels.put(
          operation,
        );
      }
    });

    return dueOperations.length;
  }

  /// Requeues an operation interrupted after it was marked as syncing.
  Future<int> recoverStaleSyncingOperations({
    Duration olderThan = const Duration(minutes: 2),
  }) async {
    final isar = await IsarService.instance;

    final cutoff =
        DateTime.now().subtract(olderThan);

    final syncing = await isar.syncOperationModels
        .filter()
        .statusEqualTo('syncing')
        .findAll();

    final stale = syncing
        .where(
          (item) =>
              item.lastAttemptAt == null ||
              item.lastAttemptAt!.isBefore(cutoff),
        )
        .toList();

    if (stale.isEmpty) {
      return 0;
    }

    await isar.writeTxn(() async {
      for (final item in stale) {
        item.status = 'pending';
        item.nextRetryAt = DateTime.now();
        item.lastError =
            'Recovered after interrupted sync.';

        await isar.syncOperationModels.put(item);
      }
    });

    return stale.length;
  }

  // ============================================================
  // MARK AS SYNCING
  // ============================================================

  Future<void> markSyncing(
    SyncOperationModel operation,
  ) async {
    final isar = await IsarService.instance;

    operation.status = 'syncing';
    operation.lastAttemptAt = DateTime.now();
    operation.lastError = null;

    await isar.writeTxn(() async {
      await isar.syncOperationModels.put(operation);
    });
  }

  // ============================================================
  // MARK AS SYNCED
  // ============================================================

  Future<void> markSynced(
    SyncOperationModel operation, {
    String? remoteId,
  }) async {
    final isar = await IsarService.instance;

    operation.status = 'synced';

    if (remoteId != null &&
        remoteId.trim().isNotEmpty) {
      operation.remoteId = remoteId;
    }

    operation.syncedAt = DateTime.now();
    operation.lastError = null;
    operation.nextRetryAt = null;

    await isar.writeTxn(() async {
      await isar.syncOperationModels.put(operation);
    });
  }

  // ============================================================
  // MARK AS FAILED
  // ============================================================

  Future<void> markFailed(
    SyncOperationModel operation,
    Object error,
  ) async {
    final isar = await IsarService.instance;

    operation.status = 'failed';
    operation.retryCount++;
    operation.lastAttemptAt = DateTime.now();
    operation.lastError = error.toString();

    operation.nextRetryAt = DateTime.now().add(
      _calculateRetryDelay(
        operation.retryCount,
      ),
    );

    await isar.writeTxn(() async {
      await isar.syncOperationModels.put(operation);
    });
  }

  // ============================================================
  // MARK AS CONFLICT
  // ============================================================

  Future<void> markConflict(
    SyncOperationModel operation,
    String message,
  ) async {
    final isar = await IsarService.instance;

    operation.status = 'conflict';
    operation.lastError = message;
    operation.lastAttemptAt = DateTime.now();
    operation.nextRetryAt = null;

    await isar.writeTxn(() async {
      await isar.syncOperationModels.put(operation);
    });
  }

  // ============================================================
  // RETRY ALL FAILED OPERATIONS
  // ============================================================

  Future<int> retryFailedOperations() async {
    final isar = await IsarService.instance;

    final operations = await isar.syncOperationModels
        .filter()
        .statusEqualTo('failed')
        .findAll();

    if (operations.isEmpty) {
      return 0;
    }

    final now = DateTime.now();

    await isar.writeTxn(() async {
      for (final operation in operations) {
        operation.status = 'pending';
        operation.nextRetryAt = now;
        operation.lastError = null;

        await isar.syncOperationModels.put(
          operation,
        );
      }
    });

    return operations.length;
  }

  // ============================================================
  // REMOVE OPERATION
  // ============================================================

  Future<void> removeOperation(
    int operationId,
  ) async {
    final isar = await IsarService.instance;

    await isar.writeTxn(() async {
      await isar.syncOperationModels.delete(
        operationId,
      );
    });
  }

  // ============================================================
  // COUNTS
  // ============================================================

  Future<int> getPendingCount() async {
    final isar = await IsarService.instance;

    return isar.syncOperationModels
        .filter()
        .statusEqualTo('pending')
        .count();
  }

  // ============================================================
  // PENDING COUNT BY ENTITY
  // ============================================================

  Future<int> getPendingCountByEntity(
    String entityType,
  ) async {
    final isar = await IsarService.instance;

    final value = entityType.trim().toLowerCase();

    if (value.isEmpty) {
      return 0;
    }

    return isar.syncOperationModels
        .filter()
        .entityTypeEqualTo(value)
        .statusEqualTo('pending')
        .count();
  }

  Future<int> getFailedCount() async {
    final isar = await IsarService.instance;

    return isar.syncOperationModels
        .filter()
        .statusEqualTo('failed')
        .count();
  }

  Future<int> getConflictCount() async {
    final isar = await IsarService.instance;

    return isar.syncOperationModels
        .filter()
        .statusEqualTo('conflict')
        .count();
  }

  Future<int> getSyncingCount() async {
    final isar = await IsarService.instance;

    return isar.syncOperationModels
        .filter()
        .statusEqualTo('syncing')
        .count();
  }

  // ============================================================
  // CONFLICT OPERATIONS
  // ============================================================

  /// Returns unresolved sync conflicts for the current
  /// authenticated user/farm scoped Isar database.
  Future<List<SyncOperationModel>> getConflictOperations() async {
    final isar = await IsarService.instance;

    final operations = await isar.syncOperationModels
        .filter()
        .statusEqualTo('conflict')
        .findAll();

    operations.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return operations;
  }

  /// Moves a conflict back to the normal sync queue.
  ///
  /// This is used when the user wants the sync engine to try the
  /// operation again after reviewing the conflict.
  Future<bool> retryConflict(int operationId) async {
    final isar = await IsarService.instance;

    final operation =
        await isar.syncOperationModels.get(operationId);

    if (operation == null || operation.status != 'conflict') {
      return false;
    }

    operation.status = 'pending';
    operation.nextRetryAt = DateTime.now();
    operation.lastError = null;

    await isar.writeTxn(() async {
      await isar.syncOperationModels.put(operation);
    });

    return true;
  }

  /// Dismisses a conflict after explicit user confirmation.
  ///
  /// The local conflict queue entry is removed. This does not alter
  /// the business record or remote Firestore document.
  Future<bool> dismissConflict(int operationId) async {
    final isar = await IsarService.instance;

    final operation =
        await isar.syncOperationModels.get(operationId);

    if (operation == null || operation.status != 'conflict') {
      return false;
    }

    await isar.writeTxn(() async {
      await isar.syncOperationModels.delete(operationId);
    });

    return true;
  }

  // ============================================================
  // PROCESSING LOCK
  // ============================================================

  bool get isProcessing => _isProcessing;

  Future<T?> runWithProcessingLock<T>(
    Future<T> Function() action,
  ) async {
    if (_isProcessing) {
      return null;
    }

    _isProcessing = true;

    try {
      return await action();
    } finally {
      _isProcessing = false;
    }
  }

  // ============================================================
  // RETRY BACKOFF
  // ============================================================

  Duration _calculateRetryDelay(
    int retryCount,
  ) {
    final int safeRetryCount =
        retryCount.clamp(1, 6).toInt();

    final int seconds =
        5 * (1 << (safeRetryCount - 1));

    return Duration(
      seconds: seconds,
    );
  }

  // ============================================================
  // CLEAN OLD COMPLETED OPERATIONS
  // ============================================================

  Future<int> cleanCompletedOperations({
    Duration olderThan =
        const Duration(days: 7),
  }) async {
    final isar = await IsarService.instance;

    final cutoff =
        DateTime.now().subtract(olderThan);

    final operations = await isar.syncOperationModels
        .filter()
        .statusEqualTo('synced')
        .findAll();

    final idsToDelete = operations
        .where(
          (operation) =>
              operation.syncedAt != null &&
              operation.syncedAt!.isBefore(cutoff),
        )
        .map(
          (operation) => operation.id,
        )
        .toList();

    if (idsToDelete.isEmpty) {
      return 0;
    }

    await isar.writeTxn(() async {
      await isar.syncOperationModels.deleteAll(
        idsToDelete,
      );
    });

    return idsToDelete.length;
  }
}