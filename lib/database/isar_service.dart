import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/sync/models/sync_operation_model.dart';
import '../features/animals/data/models/animal_model.dart';
import '../features/auth/data/auth_profile_service.dart';
import '../features/expenses/data/models/expense_model.dart';
import '../features/health/data/models/health_model.dart';
import '../features/inventory/data/models/inventory_model.dart';
import '../features/milk/data/models/milk_model.dart';
import '../features/pregnancy/data/models/pregnancy_model.dart';

/// Provides an Isar database scoped to the currently authenticated
/// Firebase user and farm.
///
/// The application is offline-first, so local records must never be
/// shared between different user/farm sessions. Instead of adding
/// ownership fields to every business model, each account/farm gets
/// its own Isar instance name.
class IsarService {
  IsarService._();

  static Isar? _isar;
  static String? _scopeKey;
  static String? _activeUid;
  static String? _activeFarmId;

  static const String _legacyMigrationMarker =
      'isar_legacy_migration_completed_v1';

  // ============================================================
  // GET SCOPED ISAR INSTANCE
  // ============================================================

  /// Returns the Isar database for the currently authenticated
  /// user + farm.
  ///
  /// If the Firebase user or farm profile is not available, no local
  /// business database is opened. This prevents an unauthenticated
  /// session from accidentally reading another user's local data.
  static Future<Isar> get instance async {
    final firebaseUser =
        AuthProfileService.instance.currentFirebaseUser;

    if (firebaseUser == null) {
      throw StateError(
        'Cannot open local database: no authenticated Firebase user.',
      );
    }

    final profile =
        await AuthProfileService.instance.getCurrentProfile();

    if (profile == null || !profile.canUseApplication) {
      throw StateError(
        'Cannot open local database: a valid authenticated '
        'user and farm profile are required.',
      );
    }

    final cleanFarmId = profile.farmId.trim();

    if (_isar != null &&
        _isar!.isOpen &&
        _activeUid == firebaseUser.uid &&
        _activeFarmId == cleanFarmId) {
      return _isar!;
    }

    return initializeForScope(
      uid: firebaseUser.uid,
      farmId: cleanFarmId,
    );
  }

  // ============================================================
  // INITIALIZE / SWITCH SCOPE
  // ============================================================

  static Future<Isar> initializeForScope({
    required String uid,
    required String farmId,
  }) async {
    final cleanUid = uid.trim();
    final cleanFarmId = farmId.trim();

    if (cleanUid.isEmpty) {
      throw StateError(
        'Cannot open local database: Firebase UID is empty.',
      );
    }

    if (cleanFarmId.isEmpty) {
      throw StateError(
        'Cannot open local database: farmId is empty.',
      );
    }

    final scopeKey = _buildScopeKey(
      cleanUid,
      cleanFarmId,
    );

    if (_isar != null &&
        _isar!.isOpen &&
        _scopeKey == scopeKey) {
      return _isar!;
    }

    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
    }

    _isar = null;
    _scopeKey = null;
    _activeUid = null;
    _activeFarmId = null;

    _isar = await _openScopedDatabase(
      scopeKey: scopeKey,
    );
    _scopeKey = scopeKey;
    _activeUid = cleanUid;
    _activeFarmId = cleanFarmId;

    return _isar!;
  }

  // ============================================================
  // OPEN DATABASE
  // ============================================================

  static Future<Isar> _openScopedDatabase({
    required String scopeKey,
  }) async {
    final directory =
        await getApplicationDocumentsDirectory();

    final scopedIsar = await Isar.open(
      _schemas,
      directory: directory.path,
      name: scopeKey,
      inspector: false,
    );

    final prefs =
        await SharedPreferences.getInstance();

    final migrationCompleted =
        prefs.getBool(_legacyMigrationMarker) ?? false;

    if (migrationCompleted) {
      return scopedIsar;
    }

    final legacy = await Isar.open(
      _schemas,
      directory: directory.path,
      name: Isar.defaultName,
      inspector: false,
    );

    try {
      final hasLegacyData =
          await _legacyDatabaseHasData(legacy);

      if (hasLegacyData) {
        final scopedHasData =
            await _scopedDatabaseHasData(scopedIsar);

        if (!scopedHasData) {
          await _copyLegacyData(
            legacy: legacy,
            target: scopedIsar,
          );

          debugPrint(
            'Legacy Isar database migrated to scoped database: '
            '$scopeKey',
          );
        } else {
          debugPrint(
            'Scoped Isar database already contains data. '
            'Legacy database will not overwrite it.',
          );
        }
      }

      await prefs.setBool(
        _legacyMigrationMarker,
        true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Legacy Isar database migration failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      await scopedIsar.close(
        deleteFromDisk: true,
      );

      rethrow;
    } finally {
      await legacy.close(
        deleteFromDisk: true,
      );
    }

    return scopedIsar;
  }

  // ============================================================
  // LEGACY MIGRATION
  // ============================================================

  static Future<bool> _legacyDatabaseHasData(
    Isar legacy,
  ) async {
    return await legacy.animalModels.count() > 0 ||
        await legacy.milkModels.count() > 0 ||
        await legacy.expenseModels.count() > 0 ||
        await legacy.inventoryModels.count() > 0 ||
        await legacy.healthModels.count() > 0 ||
        await legacy.pregnancyModels.count() > 0 ||
        await legacy.syncOperationModels.count() > 0;
  }

  static Future<bool> _scopedDatabaseHasData(
    Isar scoped,
  ) async {
    return await scoped.animalModels.count() > 0 ||
        await scoped.milkModels.count() > 0 ||
        await scoped.expenseModels.count() > 0 ||
        await scoped.inventoryModels.count() > 0 ||
        await scoped.healthModels.count() > 0 ||
        await scoped.pregnancyModels.count() > 0 ||
        await scoped.syncOperationModels.count() > 0;
  }

  static Future<void> _copyLegacyData({
    required Isar legacy,
    required Isar target,
  }) async {
    final animals =
        await legacy.animalModels.where().findAll();
    final milk =
        await legacy.milkModels.where().findAll();
    final expenses =
        await legacy.expenseModels.where().findAll();
    final inventory =
        await legacy.inventoryModels.where().findAll();
    final health =
        await legacy.healthModels.where().findAll();
    final pregnancy =
        await legacy.pregnancyModels.where().findAll();
    final syncOperations =
        await legacy.syncOperationModels.where().findAll();

    await target.writeTxn(() async {
      if (animals.isNotEmpty) {
        await target.animalModels.putAll(animals);
      }

      if (milk.isNotEmpty) {
        await target.milkModels.putAll(milk);
      }

      if (expenses.isNotEmpty) {
        await target.expenseModels.putAll(expenses);
      }

      if (inventory.isNotEmpty) {
        await target.inventoryModels.putAll(inventory);
      }

      if (health.isNotEmpty) {
        await target.healthModels.putAll(health);
      }

      if (pregnancy.isNotEmpty) {
        await target.pregnancyModels.putAll(pregnancy);
      }

      if (syncOperations.isNotEmpty) {
        await target.syncOperationModels.putAll(
          syncOperations,
        );
      }
    });
  }

  // ============================================================
  // SCHEMA
  // ============================================================

  static const List<CollectionSchema<dynamic>> _schemas = [
    AnimalModelSchema,
    MilkModelSchema,
    ExpenseModelSchema,
    InventoryModelSchema,
    HealthModelSchema,
    PregnancyModelSchema,
    SyncOperationModelSchema,
  ];

  // ============================================================
  // SCOPE KEY
  // ============================================================

  static String _buildScopeKey(
    String uid,
    String farmId,
  ) {
    final farmHash = _stableHash(farmId);

    return 'satva_${_sanitize(uid)}_$farmHash';
  }

  static String _sanitize(
    String value,
  ) {
    final sanitized = value.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );

    if (sanitized.isEmpty) {
      return 'unknown';
    }

    return sanitized.length > 48
        ? sanitized.substring(0, 48)
        : sanitized;
  }

  /// Stable FNV-1a 64-bit style hash for farmId.
  ///
  /// A stable hash is used instead of String.hashCode because
  /// String.hashCode is not an appropriate persistent database key.
  static String _stableHash(
    String value,
  ) {
    var hash = 0xcbf29ce484222325;

    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash =
          (hash * 0x100000001b3) &
          0x7fffffffffffffff;
    }

    return hash
        .toRadixString(16)
        .padLeft(16, '0');
  }

  // ============================================================
  // CLOSE CURRENT SCOPE
  // ============================================================

  static Future<void> close() async {
    final isar = _isar;

    if (isar == null) {
      _scopeKey = null;
      _activeUid = null;
      _activeFarmId = null;
      return;
    }

    if (isar.isOpen) {
      await isar.close();
    }

    _isar = null;
    _scopeKey = null;
    _activeUid = null;
    _activeFarmId = null;
  }

  // ============================================================
  // DEBUG / SESSION INFO
  // ============================================================

  static String? get activeScopeKey =>
      _scopeKey;

  static bool get isOpen =>
      _isar?.isOpen ?? false;
}
