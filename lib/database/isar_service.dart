import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../core/sync/models/sync_operation_model.dart';

import '../features/animals/data/models/animal_model.dart';
import '../features/milk/data/models/milk_model.dart';
import '../features/expenses/data/models/expense_model.dart';
import '../features/inventory/data/models/inventory_model.dart';
import '../features/health/data/models/health_model.dart';
import '../features/pregnancy/data/models/pregnancy_model.dart';

class IsarService {
  IsarService._();

  static Isar? _isar;

  // ============================================================
  // GET ISAR INSTANCE
  // ============================================================

  static Future<Isar> get instance async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    _isar = await _initDB();

    return _isar!;
  }

  // ============================================================
  // INITIALIZE DATABASE
  // ============================================================

  static Future<Isar> _initDB() async {
    final directory =
        await getApplicationDocumentsDirectory();

    return Isar.open(
      [
        // ======================================================
        // EXISTING BUSINESS COLLECTIONS
        // ======================================================

        AnimalModelSchema,
        MilkModelSchema,
        ExpenseModelSchema,
        InventoryModelSchema,
        HealthModelSchema,
        PregnancyModelSchema,

        // ======================================================
        // V3 SYNC QUEUE
        // ======================================================

        SyncOperationModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  static Future<void> close() async {
    final isar = _isar;

    if (isar == null) {
      return;
    }

    if (isar.isOpen) {
      await isar.close();
    }

    _isar = null;
  }
}