import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/sync/sync_queue_service.dart';
import '../../../../database/isar_service.dart';
import 'models/pregnancy_model.dart';

class PregnancyRepository {
  final SyncQueueService _syncQueue =
      SyncQueueService.instance;

  // ============================================================
  // GET ALL PREGNANCY RECORDS
  // ============================================================

  Future<List<PregnancyModel>> getAllPregnancyRecords() async {
    final isar = await IsarService.instance;

    return await isar.pregnancyModels
        .where()
        .sortByBreedingDateDesc()
        .findAll();
  }

  // ============================================================
  // ADD / UPDATE PREGNANCY RECORD
  // ============================================================

  Future<bool> addPregnancyRecord(
    PregnancyModel record,
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
        await isar.pregnancyModels.put(record);
        await _syncQueue.enqueueInTransaction(isar,
          entityType: 'pregnancy', localId: record.id,
          remoteId: record.firebaseId, operation: operation);
      });

      debugPrint(
        'Pregnancy record saved locally and queued for sync. '
        'Local ID: ${record.id}, '
        'Operation: $operation',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Pregnancy local save / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // SYNC PENDING PREGNANCY RECORDS
  // ============================================================
  //
  // CentralSyncEngine आता actual Firestore sync करेल.
  // Migration compatibility साठी method ठेवला आहे.
  // ============================================================

  Future<int> syncPendingPregnancyRecords() async {
    final pendingCount =
        await _syncQueue.getPendingCount();

    debugPrint(
      'Pregnancy pending operations currently in queue: '
      '$pendingCount',
    );

    return pendingCount;
  }

  // ============================================================
  // DELETE PREGNANCY RECORD
  // ============================================================

  Future<bool> deletePregnancyRecord(
    PregnancyModel record,
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
          await isar.pregnancyModels.delete(
            record.id,
          );
        });

        debugPrint(
          'Local-only pregnancy record deleted: '
          '${record.animalTagNumber}',
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
        await isar.pregnancyModels.delete(
          record.id,
        );
        await _syncQueue.enqueueInTransaction(isar,
          entityType: 'pregnancy', localId: record.id,
          remoteId: firebaseId, operation: 'delete');
      });

      debugPrint(
        'Pregnancy record deleted locally and Firebase '
        'delete queued: ${record.animalTagNumber}',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Pregnancy delete / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
