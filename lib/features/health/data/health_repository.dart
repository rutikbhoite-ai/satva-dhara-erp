import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/sync/sync_queue_service.dart';
import '../../../../database/isar_service.dart';
import 'models/health_model.dart';

class HealthRepository {
  final SyncQueueService _syncQueue =
      SyncQueueService.instance;

  // ============================================================
  // GET ALL HEALTH RECORDS
  // ============================================================

  Future<List<HealthModel>> getAllHealthRecords() async {
    final isar = await IsarService.instance;

    return await isar.healthModels
        .where()
        .sortByDateDesc()
        .findAll();
  }

  // ============================================================
  // ADD / UPDATE HEALTH RECORD
  // ============================================================

  Future<bool> addHealthRecord(
    HealthModel record,
  ) async {
    final isar = await IsarService.instance;

    try {
      // --------------------------------------------------------
      // 1. SAVE LOCALLY FIRST
      // --------------------------------------------------------

      // --------------------------------------------------------
      // 2. DETERMINE CREATE / UPDATE
      // --------------------------------------------------------

      final hasFirebaseId =
          record.firebaseId != null &&
          record.firebaseId!.trim().isNotEmpty;

      final operation =
          hasFirebaseId ? 'update' : 'create';

      // --------------------------------------------------------
      // 3. ADD TO PERSISTENT SYNC QUEUE
      // --------------------------------------------------------

      await isar.writeTxn(() async {
        await isar.healthModels.put(record);
        await _syncQueue.enqueueInTransaction(isar,
          entityType: 'health', localId: record.id,
          remoteId: record.firebaseId, operation: operation);
      });

      debugPrint(
        'Health record saved locally and queued for sync. '
        'Local ID: ${record.id}, '
        'Operation: $operation',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Health local save / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // SYNC PENDING HEALTH RECORDS
  // ============================================================
  //
  // CentralSyncEngine आता actual Firestore sync करेल.
  // Migration compatibility साठी method ठेवला आहे.
  // ============================================================

  Future<int> syncPendingHealthRecords() async {
    final pendingCount =
        await _syncQueue.getPendingCount();

    debugPrint(
      'Health pending operations currently in queue: '
      '$pendingCount',
    );

    return pendingCount;
  }

  // ============================================================
  // DELETE HEALTH RECORD
  // ============================================================

  Future<bool> deleteHealthRecord(
    HealthModel record,
  ) async {
    final isar = await IsarService.instance;

    try {
      final firebaseId =
          record.firebaseId?.trim();

      // --------------------------------------------------------
      // CASE 1:
      // LOCAL-ONLY RECORD
      // --------------------------------------------------------

      if (firebaseId == null ||
          firebaseId.isEmpty) {
        await isar.writeTxn(() async {
          await isar.healthModels.delete(
            record.id,
          );
        });

        debugPrint(
          'Local-only health record deleted: '
          '${record.id}',
        );

        return true;
      }

      // --------------------------------------------------------
      // CASE 2:
      // FIREBASE RECORD EXISTS
      // --------------------------------------------------------
      //
      // Delete locally immediately.
      // Firebase delete is persisted in the sync queue.
      //

      await isar.writeTxn(() async {
        await isar.healthModels.delete(
          record.id,
        );
        await _syncQueue.enqueueInTransaction(isar,
          entityType: 'health', localId: record.id,
          remoteId: firebaseId, operation: 'delete');
      });

      debugPrint(
        'Health record deleted locally and Firebase '
        'delete queued: ${record.id}',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Health delete / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
