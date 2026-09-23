import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/sync/sync_queue_service.dart';
import '../../../../database/isar_service.dart';
import 'models/expense_model.dart';

class ExpenseRepository {
  final SyncQueueService _syncQueue =
      SyncQueueService.instance;

  // ============================================================
  // GET ALL EXPENSES
  // ============================================================

  Future<List<ExpenseModel>> getAllExpenses() async {
    final isar = await IsarService.instance;

    return await isar.expenseModels
        .where()
        .sortByDateDesc()
        .findAll();
  }

  // ============================================================
  // ADD / UPDATE EXPENSE
  // ============================================================

  Future<bool> addExpense(
    ExpenseModel expense,
  ) async {
    final isar = await IsarService.instance;

    try {
      // --------------------------------------------------------
      // 1. SAVE LOCALLY FIRST
      // --------------------------------------------------------

      // --------------------------------------------------------
      // 2. DETERMINE OPERATION
      // --------------------------------------------------------

      final hasFirebaseId =
          expense.firebaseId != null &&
          expense.firebaseId!.trim().isNotEmpty;

      final operation =
          hasFirebaseId ? 'update' : 'create';

      // --------------------------------------------------------
      // 3. ADD TO PERSISTENT SYNC QUEUE
      // --------------------------------------------------------

      await isar.writeTxn(() async {
        await isar.expenseModels.put(expense);
        await _syncQueue.enqueueInTransaction(isar,
          entityType: 'expense', localId: expense.id,
          remoteId: expense.firebaseId, operation: operation);
      });

      debugPrint(
        'Expense saved locally and queued for sync. '
        'Local ID: ${expense.id}, '
        'Operation: $operation',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Expense local save / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // SYNC PENDING EXPENSES
  // ============================================================
  //
  // CentralSyncEngine आता actual Firestore sync करेल.
  // Migration compatibility साठी method ठेवला आहे.
  // ============================================================

  Future<int> syncPendingExpenses() async {
    final pendingCount =
        await _syncQueue.getPendingCount();

    debugPrint(
      'Expense pending operations currently in queue: '
      '$pendingCount',
    );

    return pendingCount;
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  Future<bool> deleteExpense(
    ExpenseModel expense,
  ) async {
    final isar = await IsarService.instance;

    try {
      final firebaseId =
          expense.firebaseId?.trim();

      // --------------------------------------------------------
      // CASE 1:
      // LOCAL-ONLY RECORD
      // --------------------------------------------------------

      if (firebaseId == null ||
          firebaseId.isEmpty) {
        await isar.writeTxn(() async {
          await isar.expenseModels.delete(
            expense.id,
          );
        });

        debugPrint(
          'Local-only expense deleted: '
          '${expense.id}',
        );

        return true;
      }

      // --------------------------------------------------------
      // CASE 2:
      // FIREBASE RECORD EXISTS
      // --------------------------------------------------------
      //
      // Local record is removed immediately.
      // Firebase delete is persisted in the queue.
      //

      await isar.writeTxn(() async {
        await isar.expenseModels.delete(
          expense.id,
        );
        await _syncQueue.enqueueInTransaction(isar,
          entityType: 'expense', localId: expense.id,
          remoteId: firebaseId, operation: 'delete');
      });

      debugPrint(
        'Expense deleted locally and Firebase delete '
        'queued: ${expense.id}',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Expense delete / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
