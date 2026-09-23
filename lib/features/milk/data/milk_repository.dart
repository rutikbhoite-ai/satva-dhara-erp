import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/sync/sync_queue_service.dart';
import '../../../../database/isar_service.dart';
import 'models/milk_model.dart';

class MilkRepository {
  final SyncQueueService _syncQueue =
      SyncQueueService.instance;

  // ============================================================
  // GET ALL MILK ENTRIES
  // ============================================================

  Future<List<MilkModel>> getAllMilkEntries() async {
    final isar = await IsarService.instance;

    return await isar.milkModels
        .where()
        .sortByDateDesc()
        .findAll();
  }

  // ============================================================
  // ADD / UPDATE MILK ENTRY
  // ============================================================

  Future<bool> addMilkEntry(
    MilkModel milk,
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
          milk.firebaseId != null &&
          milk.firebaseId!.trim().isNotEmpty;

      final operation =
          hasFirebaseId ? 'update' : 'create';

      // --------------------------------------------------------
      // 3. ADD TO PERSISTENT SYNC QUEUE
      // --------------------------------------------------------

      await isar.writeTxn(() async {
        await isar.milkModels.put(milk);
        await _syncQueue.enqueueInTransaction(isar,
          entityType: 'milk', localId: milk.id,
          remoteId: milk.firebaseId, operation: operation);
      });

      debugPrint(
        'Milk saved locally and queued for sync. '
        'Local ID: ${milk.id}, '
        'Operation: $operation',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Milk local save / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // SYNC PENDING MILK ENTRIES
  // ============================================================
  //
  // CentralSyncEngine आता actual Firestore sync करेल.
  // Migration compatibility साठी method ठेवला आहे.
  // ============================================================

  Future<int> syncPendingMilkEntries() async {
    final pendingCount =
        await _syncQueue.getPendingCount();

    debugPrint(
      'Milk pending operations currently in queue: '
      '$pendingCount',
    );

    return pendingCount;
  }

  // ============================================================
  // DELETE MILK ENTRY
  // ============================================================

  Future<bool> deleteMilkEntry(
    MilkModel milk,
  ) async {
    final isar = await IsarService.instance;

    try {
      final firebaseId =
          milk.firebaseId?.trim();

      // --------------------------------------------------------
      // CASE 1:
      // LOCAL-ONLY RECORD
      // --------------------------------------------------------

      if (firebaseId == null ||
          firebaseId.isEmpty) {
        await isar.writeTxn(() async {
          await isar.milkModels.delete(
            milk.id,
          );
        });

        debugPrint(
          'Local-only milk entry deleted: '
          '${milk.id}',
        );

        return true;
      }

      // --------------------------------------------------------
      // CASE 2:
      // FIREBASE RECORD EXISTS
      // --------------------------------------------------------
      //
      // Delete local record immediately.
      // Firebase delete is persisted in the queue.
      //

      await isar.writeTxn(() async {
        await isar.milkModels.delete(
          milk.id,
        );
        await _syncQueue.enqueueInTransaction(isar,
          entityType: 'milk', localId: milk.id,
          remoteId: firebaseId, operation: 'delete');
      });

      debugPrint(
        'Milk deleted locally and Firebase delete '
        'queued: ${milk.id}',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Milk delete / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
