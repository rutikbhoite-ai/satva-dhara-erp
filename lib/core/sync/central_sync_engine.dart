import 'package:firebase_auth/firebase_auth.dart';

import '../../core/logging/app_logger.dart';
import '../../core/network/connectivity_service.dart';
import '../../database/isar_service.dart';

import '../../features/animals/data/models/animal_model.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/health/data/models/health_model.dart';
import '../../features/inventory/data/models/inventory_model.dart';
import '../../features/milk/data/models/milk_model.dart';
import '../../features/pregnancy/data/models/pregnancy_model.dart';

import '../../services/sync/firestore_sync_service.dart';
import '../../services/sync/firestore_pull_service.dart';
import '../../features/audit_log/data/audit_log_service.dart';

import 'models/sync_operation_model.dart';
import 'sync_queue_service.dart';

/// Central synchronization engine for V3.
///
/// Responsibilities:
/// - Reads persistent sync operations from Isar.
/// - Checks authentication.
/// - Checks network availability.
/// - Sends records to the existing FirestoreSyncService.
/// - Updates local Firebase IDs and sync timestamps.
/// - Handles create/update/delete operations.
/// - Retries failed operations.
/// - Prevents concurrent sync runs.
///
/// IMPORTANT:
/// This engine is intentionally not started automatically from
/// main.dart yet. Existing V2 repositories are still responsible
/// for their current synchronization until repository migration
/// is completed.
class CentralSyncEngine {
  CentralSyncEngine._();

  static final CentralSyncEngine instance =
      CentralSyncEngine._();

  final SyncQueueService _queue =
      SyncQueueService.instance;

  final FirestoreSyncService _firestore =
      FirestoreSyncService.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final ConnectivityService _connectivity =
      ConnectivityService.instance;

  // ============================================================
  // PROCESS QUEUE
  // ============================================================

  Future<SyncEngineResult> processQueue({
    int batchSize = 50,
  }) async {
    return await _queue.runWithProcessingLock(
          () async {
            return await _processQueueInternal(
              batchSize: batchSize,
            );
          },
        ) ??
        const SyncEngineResult(
          processed: 0,
          succeeded: 0,
          failed: 0,
          conflicts: 0,
          skipped: 0,
        );
  }

  Future<SyncEngineResult> _processQueueInternal({
    required int batchSize,
  }) async {
    // ==========================================================
    // NETWORK
    // ==========================================================

    if (!_connectivity.isConnected) {
      AppLogger.info(
        'Sync skipped because device is offline.',
      );

      return const SyncEngineResult(
        processed: 0,
        succeeded: 0,
        failed: 0,
        conflicts: 0,
        skipped: 0,
      );
    }

    // ==========================================================
    // AUTHENTICATION
    // ==========================================================

    final user = _auth.currentUser;

    if (user == null) {
      AppLogger.info(
        'Sync skipped because no Firebase user is authenticated.',
      );

      return const SyncEngineResult(
        processed: 0,
        succeeded: 0,
        failed: 0,
        conflicts: 0,
        skipped: 0,
      );
    }

    AppLogger.debug(
      'Starting V3 sync queue processing for user ${user.uid}.',
    );

    // ==========================================================
    // PREPARE RETRIES
    // ==========================================================

    await _queue.recoverStaleSyncingOperations();
    await _queue.prepareDueFailedOperations();

    // ==========================================================
    // GET PENDING OPERATIONS
    // ==========================================================

    final operations =
        await _queue.getPendingOperations(
      limit: batchSize,
    );

    if (operations.isEmpty) {
      AppLogger.debug(
        'V3 sync queue is empty.',
      );

      // No local queue work remains. Continue to the remote pull gate below
      // so that login/app-start sync can also refresh local data from Firestore.
      // The same pending/failed/conflict checks below still protect unsynced
      // local work from being replaced by a remote snapshot.
    }

    int processed = 0;
    int succeeded = 0;
    int failed = 0;
    int conflicts = 0;
    int skipped = 0;

    // ==========================================================
    // PROCESS SEQUENTIALLY
    // ==========================================================

    for (final operation in operations) {
      processed++;

      final result =
          await _processOperation(operation);

      switch (result) {
        case _OperationResult.success:
          succeeded++;
          break;

        case _OperationResult.failed:
          failed++;
          break;

        case _OperationResult.conflict:
          conflicts++;
          break;

        case _OperationResult.skipped:
          skipped++;
          break;
      }
    }

    AppLogger.info(
      'V3 sync completed. '
      'Processed: $processed, '
      'Succeeded: $succeeded, '
      'Failed: $failed, '
      'Conflicts: $conflicts, '
      'Skipped: $skipped',
    );

    // Pull only when no local work remains. This protects offline edits
    // from being replaced by an older remote snapshot.
    if (await _queue.getPendingCount() == 0 &&
        await _queue.getFailedCount() == 0 &&
        await _queue.getConflictCount() == 0) {
      try {
        await FirestorePullService.instance.pullFarmRecords();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Remote farm pull failed.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return SyncEngineResult(
      processed: processed,
      succeeded: succeeded,
      failed: failed,
      conflicts: conflicts,
      skipped: skipped,
    );
  }

  // ============================================================
  // PROCESS SINGLE OPERATION
  // ============================================================

  Future<_OperationResult> _processOperation(
    SyncOperationModel operation,
  ) async {
    try {
      await _queue.markSyncing(operation);

      final entityType =
          operation.entityType.trim().toLowerCase();

      final operationType =
          operation.operation.trim().toLowerCase();

      final _OperationResult result;

      switch (operationType) {
        case 'create':
        case 'update':
          result = await _processSaveOperation(
            operation,
            entityType,
          );
          break;

        case 'delete':
          result = await _processDeleteOperation(
            operation,
            entityType,
          );
          break;

        default:
          await _queue.markConflict(
            operation,
            'Unsupported sync operation: '
            '${operation.operation}',
          );

          AppLogger.error(
            'Unsupported sync operation: '
            '${operation.operation}',
          );

          return _OperationResult.conflict;
      }

      if (result == _OperationResult.success) {
        await AuditLogService.instance.createLog(
          module: entityType,
          action: operationType,
          entityType: entityType,
          entityId:
              operation.remoteId ??
              operation.localId.toString(),
          summary:
              '$entityType $operationType synced',
          metadata: {
            'localId': operation.localId,
          },
        );
      }

      return result;
    } catch (e, stackTrace) {
      await _queue.markFailed(
        operation,
        e,
      );

      AppLogger.error(
        'Unexpected sync operation error.',
        error: e,
        stackTrace: stackTrace,
      );

      return _OperationResult.failed;
    }
  }

  // ============================================================
  // SAVE / UPDATE
  // ============================================================

  Future<_OperationResult> _processSaveOperation(
    SyncOperationModel operation,
    String entityType,
  ) async {
    switch (entityType) {
      case 'animal':
        return await _syncAnimal(operation);

      case 'milk':
        return await _syncMilk(operation);

      case 'expense':
        return await _syncExpense(operation);

      case 'inventory':
        return await _syncInventory(operation);

      case 'health':
        return await _syncHealth(operation);

      case 'pregnancy':
        return await _syncPregnancy(operation);

      default:
        await _queue.markConflict(
          operation,
          'Unsupported entity type: $entityType',
        );

        return _OperationResult.conflict;
    }
  }

  // ============================================================
  // ANIMAL
  // ============================================================

  Future<_OperationResult> _syncAnimal(
    SyncOperationModel operation,
  ) async {
    final isar = await IsarService.instance;

    final animal =
        await isar.animalModels.get(
      operation.localId,
    );

    if (animal == null) {
      return await _handleMissingLocalRecord(
        operation,
        entityType: 'animal',
      );
    }

    final firebaseId =
        await _firestore.saveAnimalRecord(
      animal,
    );

    if (firebaseId == null) {
      await _queue.markFailed(
        operation,
        'Animal Firestore sync returned null.',
      );

      return _OperationResult.failed;
    }

    animal.firebaseId = firebaseId;
    animal.lastSyncAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.animalModels.put(animal);
    });

    await _queue.markSynced(
      operation,
      remoteId: firebaseId,
    );

    return _OperationResult.success;
  }

  // ============================================================
  // MILK
  // ============================================================

  Future<_OperationResult> _syncMilk(
    SyncOperationModel operation,
  ) async {
    final isar = await IsarService.instance;

    final milk =
        await isar.milkModels.get(
      operation.localId,
    );

    if (milk == null) {
      return await _handleMissingLocalRecord(
        operation,
        entityType: 'milk',
      );
    }

    final firebaseId =
        await _firestore.saveMilkRecord(
      milk,
    );

    if (firebaseId == null) {
      await _queue.markFailed(
        operation,
        'Milk Firestore sync returned null.',
      );

      return _OperationResult.failed;
    }

    milk.firebaseId = firebaseId;
    milk.lastSyncAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.milkModels.put(milk);
    });

    await _queue.markSynced(
      operation,
      remoteId: firebaseId,
    );

    return _OperationResult.success;
  }

  // ============================================================
  // EXPENSE
  // ============================================================

  Future<_OperationResult> _syncExpense(
    SyncOperationModel operation,
  ) async {
    final isar = await IsarService.instance;

    final expense =
        await isar.expenseModels.get(
      operation.localId,
    );

    if (expense == null) {
      return await _handleMissingLocalRecord(
        operation,
        entityType: 'expense',
      );
    }

    final firebaseId =
        await _firestore.saveExpenseRecord(
      expense,
    );

    if (firebaseId == null) {
      await _queue.markFailed(
        operation,
        'Expense Firestore sync returned null.',
      );

      return _OperationResult.failed;
    }

    expense.firebaseId = firebaseId;
    expense.lastSyncAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.expenseModels.put(expense);
    });

    await _queue.markSynced(
      operation,
      remoteId: firebaseId,
    );

    return _OperationResult.success;
  }

  // ============================================================
  // INVENTORY
  // ============================================================

  Future<_OperationResult> _syncInventory(
    SyncOperationModel operation,
  ) async {
    final isar = await IsarService.instance;

    final item =
        await isar.inventoryModels.get(
      operation.localId,
    );

    if (item == null) {
      return await _handleMissingLocalRecord(
        operation,
        entityType: 'inventory',
      );
    }

    final firebaseId =
        await _firestore.saveInventoryRecord(
      item,
    );

    if (firebaseId == null) {
      await _queue.markFailed(
        operation,
        'Inventory Firestore sync returned null.',
      );

      return _OperationResult.failed;
    }

    item.firebaseId = firebaseId;
    item.lastSyncAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.inventoryModels.put(item);
    });

    await _queue.markSynced(
      operation,
      remoteId: firebaseId,
    );

    return _OperationResult.success;
  }

  // ============================================================
  // HEALTH
  // ============================================================

  Future<_OperationResult> _syncHealth(
    SyncOperationModel operation,
  ) async {
    final isar = await IsarService.instance;

    final health =
        await isar.healthModels.get(
      operation.localId,
    );

    if (health == null) {
      return await _handleMissingLocalRecord(
        operation,
        entityType: 'health',
      );
    }

    final firebaseId =
        await _firestore.saveHealthRecord(
      health,
    );

    if (firebaseId == null) {
      await _queue.markFailed(
        operation,
        'Health Firestore sync returned null.',
      );

      return _OperationResult.failed;
    }

    health.firebaseId = firebaseId;
    health.lastSyncAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.healthModels.put(health);
    });

    await _queue.markSynced(
      operation,
      remoteId: firebaseId,
    );

    return _OperationResult.success;
  }

  // ============================================================
  // PREGNANCY
  // ============================================================

  Future<_OperationResult> _syncPregnancy(
    SyncOperationModel operation,
  ) async {
    final isar = await IsarService.instance;

    final pregnancy =
        await isar.pregnancyModels.get(
      operation.localId,
    );

    if (pregnancy == null) {
      return await _handleMissingLocalRecord(
        operation,
        entityType: 'pregnancy',
      );
    }

    final firebaseId =
        await _firestore.savePregnancyRecord(
      pregnancy,
    );

    if (firebaseId == null) {
      await _queue.markFailed(
        operation,
        'Pregnancy Firestore sync returned null.',
      );

      return _OperationResult.failed;
    }

    pregnancy.firebaseId = firebaseId;
    pregnancy.lastSyncAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.pregnancyModels.put(
        pregnancy,
      );
    });

    await _queue.markSynced(
      operation,
      remoteId: firebaseId,
    );

    return _OperationResult.success;
  }

  // ============================================================
  // MISSING LOCAL RECORD
  // ============================================================

  Future<_OperationResult> _handleMissingLocalRecord(
    SyncOperationModel operation, {
    required String entityType,
  }) async {
    final operationType =
        operation.operation.trim().toLowerCase();

    final remoteId =
        operation.remoteId?.trim();

    // ----------------------------------------------------------
    // CREATE + NO REMOTE ID
    // ----------------------------------------------------------
    //
    // This means the record was created locally but deleted
    // before its first successful Firebase sync.
    //
    // There is no remote document to create or delete.
    // Therefore the queue operation can safely be completed.
    //

    if (operationType == 'create' &&
        (remoteId == null || remoteId.isEmpty)) {
      await _queue.markSynced(
        operation,
      );

      AppLogger.info(
        'Skipped stale create operation because the '
        '$entityType local record was deleted before first sync. '
        'Local ID: ${operation.localId}',
      );

      return _OperationResult.success;
    }

    // ----------------------------------------------------------
    // ALL OTHER CASES
    // ----------------------------------------------------------
    //
    // Example:
    // update operation + missing local record
    //
    // We cannot safely determine whether this was an intentional
    // delete or an unexpected local-data loss.
    //

    await _queue.markConflict(
      operation,
      '$entityType local record not found. '
      'Local ID: ${operation.localId}',
    );

    return _OperationResult.conflict;
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<_OperationResult> _processDeleteOperation(
    SyncOperationModel operation,
    String entityType,
  ) async {
    final remoteId =
        operation.remoteId?.trim();

    if (remoteId == null || remoteId.isEmpty) {
      // There is nothing to delete remotely.
      //
      // This can happen when a local-only record is deleted
      // before it ever reached Firebase.
      await _queue.markSynced(
        operation,
      );

      return _OperationResult.success;
    }

    bool deleted;

    switch (entityType) {
      case 'animal':
        deleted =
            await _firestore.deleteAnimalRecord(
          remoteId,
        );
        break;

      case 'milk':
        deleted =
            await _firestore.deleteMilkRecord(
          remoteId,
        );
        break;

      case 'expense':
        deleted =
            await _firestore.deleteExpenseRecord(
          remoteId,
        );
        break;

      case 'inventory':
        deleted =
            await _firestore.deleteInventoryRecord(
          remoteId,
        );
        break;

      case 'health':
        deleted =
            await _firestore.deleteHealthRecord(
          remoteId,
        );
        break;

      case 'pregnancy':
        deleted =
            await _firestore.deletePregnancyRecord(
          remoteId,
        );
        break;

      default:
        await _queue.markConflict(
          operation,
          'Unsupported delete entity type: '
          '$entityType',
        );

        return _OperationResult.conflict;
    }

    if (!deleted) {
      await _queue.markFailed(
        operation,
        'Firestore delete operation failed.',
      );

      return _OperationResult.failed;
    }

    await _queue.markSynced(
      operation,
    );

    return _OperationResult.success;
  }
}

// ============================================================
// OPERATION RESULT
// ============================================================

enum _OperationResult {
  success,
  failed,
  conflict,
  skipped,
}

// ============================================================
// PUBLIC RESULT
// ============================================================

class SyncEngineResult {
  const SyncEngineResult({
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.conflicts,
    required this.skipped,
  });

  final int processed;
  final int succeeded;
  final int failed;
  final int conflicts;
  final int skipped;

  bool get hasErrors =>
      failed > 0 || conflicts > 0;

  bool get isSuccess =>
      !hasErrors;

  @override
  String toString() {
    return 'SyncEngineResult('
        'processed: $processed, '
        'succeeded: $succeeded, '
        'failed: $failed, '
        'conflicts: $conflicts, '
        'skipped: $skipped'
        ')';
  }
}