import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/sync/sync_queue_service.dart';
import '../../../../database/isar_service.dart';
import 'models/inventory_model.dart';

class InventoryRepository {
  final SyncQueueService _syncQueue =
      SyncQueueService.instance;

  // ============================================================
  // GET ALL INVENTORY
  // ============================================================

  Future<List<InventoryModel>> getAllItems() async {
    final isar = await IsarService.instance;

    return await isar.inventoryModels
        .where()
        .findAll();
  }

  // ============================================================
  // ADD / UPDATE INVENTORY
  // ============================================================

  Future<bool> addOrUpdateItem(
    InventoryModel item,
  ) async {
    final isar = await IsarService.instance;

    try {
      // --------------------------------------------------------
      // DETERMINE CREATE / UPDATE
      // --------------------------------------------------------

      final hasFirebaseId =
          item.firebaseId != null &&
          item.firebaseId!.trim().isNotEmpty;

      final operation =
          hasFirebaseId ? 'update' : 'create';

      // --------------------------------------------------------
      // SAVE LOCALLY + QUEUE IN SAME TRANSACTION
      // --------------------------------------------------------

      await isar.writeTxn(() async {
        await isar.inventoryModels.put(item);

        await _syncQueue.enqueueInTransaction(
          isar,
          entityType: 'inventory',
          localId: item.id,
          remoteId: item.firebaseId,
          operation: operation,
        );
      });

      debugPrint(
        'Inventory saved locally and queued for sync. '
        'Local ID: ${item.id}, '
        'Operation: $operation',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Inventory local save / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // SYNC PENDING INVENTORY
  // ============================================================
  //
  // CentralSyncEngine actual Firestore synchronization करतो.
  //
  // हा method compatibility / status check साठी आहे.
  // फक्त INVENTORY entity चे pending operations count केले जातात.
  // ============================================================

  Future<int> syncPendingInventory() async {
    final pendingCount =
        await _syncQueue.getPendingCountByEntity(
      'inventory',
    );

    debugPrint(
      'Inventory pending operations currently in queue: '
      '$pendingCount',
    );

    return pendingCount;
  }

  // ============================================================
  // DELETE INVENTORY
  // ============================================================

  Future<bool> deleteItem(
    InventoryModel item,
  ) async {
    final isar = await IsarService.instance;

    try {
      final firebaseId =
          item.firebaseId?.trim();

      // --------------------------------------------------------
      // CASE 1:
      // LOCAL-ONLY RECORD
      // --------------------------------------------------------
      //
      // Record Firebase वर कधीच sync झालेला नसेल तर
      // remote delete करण्याची गरज नाही.
      // --------------------------------------------------------

      if (firebaseId == null ||
          firebaseId.isEmpty) {
        await isar.writeTxn(() async {
          await isar.inventoryModels.delete(
            item.id,
          );
        });

        debugPrint(
          'Local-only inventory item deleted: '
          '${item.itemName}',
        );

        return true;
      }

      // --------------------------------------------------------
      // CASE 2:
      // FIREBASE RECORD EXISTS
      // --------------------------------------------------------
      //
      // Local record लगेच delete केला जातो.
      //
      // Firebase delete persistent queue मध्ये ठेवला जातो.
      // CentralSyncEngine remoteId वापरून Firestore delete करेल.
      // --------------------------------------------------------

      await isar.writeTxn(() async {
        await isar.inventoryModels.delete(
          item.id,
        );

        await _syncQueue.enqueueInTransaction(
          isar,
          entityType: 'inventory',
          localId: item.id,
          remoteId: firebaseId,
          operation: 'delete',
        );
      });

      debugPrint(
        'Inventory item deleted locally and Firebase '
        'delete queued: ${item.itemName}',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Inventory delete / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}