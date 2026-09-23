import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar_community/isar.dart';

import '../../database/isar_service.dart';
import '../../features/animals/data/models/animal_model.dart';
import '../../features/auth/data/auth_profile_service.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/health/data/models/health_model.dart';
import '../../features/inventory/data/models/inventory_model.dart';
import '../../features/milk/data/models/milk_model.dart';
import '../../features/pregnancy/data/models/pregnancy_model.dart';

/// Downloads the signed-in farm's records to the local Isar database.
///
/// Remote records are upserted into Isar.
///
/// Records that already have a Firebase ID but no longer exist in the
/// current farm's Firestore result are removed from Isar.
///
/// Local records without a Firebase ID are never removed by this service.
class FirestorePullService {
  FirestorePullService._();

  static final FirestorePullService instance =
      FirestorePullService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // PUBLIC
  // ============================================================

  Future<void> pullFarmRecords() async {
    final user = FirebaseAuth.instance.currentUser;

    final profile =
        await AuthProfileService.instance.getCurrentProfile();

    if (user == null ||
        profile == null ||
        !profile.canUseApplication) {
      return;
    }

    final farmId = profile.farmId.trim();

    if (farmId.isEmpty) {
      return;
    }

    final isar = await IsarService.instance;

    await _pullAnimals(isar, farmId);
    await _pullMilk(isar, farmId);
    await _pullExpenses(isar, farmId);
    await _pullInventory(isar, farmId);
    await _pullHealth(isar, farmId);
    await _pullPregnancy(isar, farmId);
  }

  // ============================================================
  // FIRESTORE
  // ============================================================

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _records(
    String collection,
    String farmId,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('farmId', isEqualTo: farmId)
        .get();

    return snapshot.docs;
  }

  // ============================================================
  // PARSERS
  // ============================================================

  DateTime _date(dynamic value) {
    if (value == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      );
    }

    return DateTime.tryParse(
          value.toString(),
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime? _nullableDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      );
    }

    return DateTime.tryParse(value.toString());
  }

  double _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  int? _int(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  bool _bool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      final normalized =
          value.trim().toLowerCase();

      if (normalized == 'true') {
        return true;
      }

      if (normalized == 'false') {
        return false;
      }
    }

    return fallback;
  }

  String _text(
    Map<String, dynamic> data,
    String key, [
    String fallback = '',
  ]) {
    return data[key]?.toString() ?? fallback;
  }

  // ============================================================
  // ANIMALS
  // ============================================================

  Future<void> _pullAnimals(
    Isar isar,
    String farmId,
  ) async {
    final docs = await _records(
      'animals',
      farmId,
    );

    final activeDocs = docs
        .where((doc) => doc.data()['deletedAt'] == null)
        .toList();

    final remoteIds =
        activeDocs.map((doc) => doc.id).toSet();

    await isar.writeTxn(() async {
      for (final doc in activeDocs) {
        final data = doc.data();

        final old = await isar.animalModels
            .filter()
            .firebaseIdEqualTo(doc.id)
            .findFirst();

        final item = AnimalModel(
          firebaseId: doc.id,
          tagNumber: _text(
            data,
            'tagNumber',
          ),
          type: _text(
            data,
            'type',
          ),
          breed: _text(
            data,
            'breed',
          ),
          dateOfBirth: _date(
            data['dateOfBirth'],
          ),
          status: _text(
            data,
            'status',
          ),
          isMilking: _bool(
            data['isMilking'],
            fallback: true,
          ),
          sourceType: _text(
            data,
            'sourceType',
            'unknown',
          ),
          farmEntryDate: _nullableDate(
            data['farmEntryDate'],
          ),
          farmEntrySeason:
              data['farmEntrySeason']?.toString(),
          previousFarm:
              data['previousFarm']?.toString(),
          purchaseDate: _nullableDate(
            data['purchaseDate'],
          ),
          purchasePrice:
              data['purchasePrice'] is num
                  ? _number(data['purchasePrice'])
                  : null,
          motherAnimalId:
              data['motherAnimalId']?.toString(),
          fatherAnimalId:
              data['fatherAnimalId']?.toString(),
          motherTagNumber:
              data['motherTagNumber']?.toString(),
          fatherTagNumber:
              data['fatherTagNumber']?.toString(),
          rfidNumber:
              data['rfidNumber']?.toString(),
          color:
              data['color']?.toString(),
          identificationNotes:
              data['identificationNotes']?.toString(),
          lactationNumber:
              _int(data['lactationNumber']),
          lastCalvingDate: _nullableDate(
            data['lastCalvingDate'],
          ),
          expectedCalvingDate: _nullableDate(
            data['expectedCalvingDate'],
          ),
          pregnancyStatus: _text(
            data,
            'pregnancyStatus',
            'unknown',
          ),
          lastSyncAt: DateTime.now(),
        )..id = old?.id ?? Isar.autoIncrement;

        await isar.animalModels.put(item);
      }

      await _removeMissingAnimals(
        isar,
        remoteIds,
      );
    });
  }

  Future<void> _removeMissingAnimals(
    Isar isar,
    Set<String> remoteIds,
  ) async {
    final localRecords =
        await isar.animalModels.where().findAll();

    final idsToDelete = localRecords
        .where(
          (item) =>
              item.firebaseId != null &&
              item.firebaseId!.isNotEmpty &&
              !remoteIds.contains(item.firebaseId),
        )
        .map((item) => item.id)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await isar.animalModels.deleteAll(
        idsToDelete,
      );
    }
  }

  // ============================================================
  // MILK
  // ============================================================

  Future<void> _pullMilk(
    Isar isar,
    String farmId,
  ) async {
    final docs = await _records(
      'milk_records',
      farmId,
    );

    final activeDocs = docs
        .where((doc) => doc.data()['deletedAt'] == null)
        .toList();

    final remoteIds =
        activeDocs.map((doc) => doc.id).toSet();

    await isar.writeTxn(() async {
      for (final doc in activeDocs) {
        final data = doc.data();

        final old = await isar.milkModels
            .filter()
            .firebaseIdEqualTo(doc.id)
            .findFirst();

        final item = MilkModel(
          firebaseId: doc.id,
          animalFirebaseId: data['animalFirebaseId']?.toString(),
          animalTagNumber: _text(
            data,
            'animalTagNumber',
          ),
          date: _date(data['date']),
          shift: _text(
            data,
            'shift',
          ),
          quantityInLiters: _number(
            data['quantityInLiters'],
          ),
          fat: _number(data['fat']),
          snf: _number(data['snf']),
          ratePerLiter: _number(
            data['ratePerLiter'],
          ),
          totalPrice: _number(
            data['totalPrice'],
          ),
          lastSyncAt: DateTime.now(),
        )..id = old?.id ?? Isar.autoIncrement;

        await isar.milkModels.put(item);
      }

      await _removeMissingMilk(
        isar,
        remoteIds,
      );
    });
  }

  Future<void> _removeMissingMilk(
    Isar isar,
    Set<String> remoteIds,
  ) async {
    final localRecords =
        await isar.milkModels.where().findAll();

    final idsToDelete = localRecords
        .where(
          (item) =>
              item.firebaseId != null &&
              item.firebaseId!.isNotEmpty &&
              !remoteIds.contains(item.firebaseId),
        )
        .map((item) => item.id)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await isar.milkModels.deleteAll(
        idsToDelete,
      );
    }
  }

  // ============================================================
  // EXPENSES
  // ============================================================

  Future<void> _pullExpenses(
    Isar isar,
    String farmId,
  ) async {
    final docs = await _records(
      'expenses',
      farmId,
    );

    final activeDocs = docs
        .where((doc) => doc.data()['deletedAt'] == null)
        .toList();

    final remoteIds =
        activeDocs.map((doc) => doc.id).toSet();

    await isar.writeTxn(() async {
      for (final doc in activeDocs) {
        final data = doc.data();

        final old = await isar.expenseModels
            .filter()
            .firebaseIdEqualTo(doc.id)
            .findFirst();

        final item = ExpenseModel(
          firebaseId: doc.id,
          date: _date(data['date']),
          category: _text(
            data,
            'category',
          ),
          amount: _number(
            data['amount'],
          ),
          description: _text(
            data,
            'description',
          ),
          lastSyncAt: DateTime.now(),
        )..id = old?.id ?? Isar.autoIncrement;

        await isar.expenseModels.put(item);
      }

      await _removeMissingExpenses(
        isar,
        remoteIds,
      );
    });
  }

  Future<void> _removeMissingExpenses(
    Isar isar,
    Set<String> remoteIds,
  ) async {
    final localRecords =
        await isar.expenseModels.where().findAll();

    final idsToDelete = localRecords
        .where(
          (item) =>
              item.firebaseId != null &&
              item.firebaseId!.isNotEmpty &&
              !remoteIds.contains(item.firebaseId),
        )
        .map((item) => item.id)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await isar.expenseModels.deleteAll(
        idsToDelete,
      );
    }
  }

  // ============================================================
  // INVENTORY
  // ============================================================

  Future<void> _pullInventory(
    Isar isar,
    String farmId,
  ) async {
    final docs = await _records(
      'inventory',
      farmId,
    );

    final activeDocs = docs
        .where((doc) => doc.data()['deletedAt'] == null)
        .toList();

    final remoteIds =
        activeDocs.map((doc) => doc.id).toSet();

    await isar.writeTxn(() async {
      for (final doc in activeDocs) {
        final data = doc.data();

        final old = await isar.inventoryModels
            .filter()
            .firebaseIdEqualTo(doc.id)
            .findFirst();

        final item = InventoryModel(
          firebaseId: doc.id,
          itemName: _text(
            data,
            'itemName',
          ),
          category: _text(
            data,
            'category',
          ),
          quantity: _number(
            data['quantity'],
          ),
          unit: _text(
            data,
            'unit',
          ),
          minThreshold: _number(
            data['minThreshold'],
          ),
          lastSyncAt: DateTime.now(),
        )..id = old?.id ?? Isar.autoIncrement;

        await isar.inventoryModels.put(item);
      }

      await _removeMissingInventory(
        isar,
        remoteIds,
      );
    });
  }

  Future<void> _removeMissingInventory(
    Isar isar,
    Set<String> remoteIds,
  ) async {
    final localRecords =
        await isar.inventoryModels.where().findAll();

    final idsToDelete = localRecords
        .where(
          (item) =>
              item.firebaseId != null &&
              item.firebaseId!.isNotEmpty &&
              !remoteIds.contains(item.firebaseId),
        )
        .map((item) => item.id)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await isar.inventoryModels.deleteAll(
        idsToDelete,
      );
    }
  }

  // ============================================================
  // HEALTH
  // ============================================================

  Future<void> _pullHealth(
    Isar isar,
    String farmId,
  ) async {
    final docs = await _records(
      'health_records',
      farmId,
    );

    final activeDocs = docs
        .where((doc) => doc.data()['deletedAt'] == null)
        .toList();

    final remoteIds =
        activeDocs.map((doc) => doc.id).toSet();

    await isar.writeTxn(() async {
      for (final doc in activeDocs) {
        final data = doc.data();

        final old = await isar.healthModels
            .filter()
            .firebaseIdEqualTo(doc.id)
            .findFirst();

        final item = HealthModel(
          firebaseId: doc.id,
          animalFirebaseId: data['animalFirebaseId']?.toString(),
          animalTagNumber: _text(
            data,
            'animalTagNumber',
          ),
          date: _date(data['date']),
          type: _text(
            data,
            'type',
          ),
          diagnosis: _text(
            data,
            'diagnosis',
          ),
          treatment: _text(
            data,
            'treatment',
          ),
          cost: _number(data['cost']),
          nextFollowUpDate: _nullableDate(
            data['nextFollowUpDate'],
          ),
          lastSyncAt: DateTime.now(),
        )..id = old?.id ?? Isar.autoIncrement;

        await isar.healthModels.put(item);
      }

      await _removeMissingHealth(
        isar,
        remoteIds,
      );
    });
  }

  Future<void> _removeMissingHealth(
    Isar isar,
    Set<String> remoteIds,
  ) async {
    final localRecords =
        await isar.healthModels.where().findAll();

    final idsToDelete = localRecords
        .where(
          (item) =>
              item.firebaseId != null &&
              item.firebaseId!.isNotEmpty &&
              !remoteIds.contains(item.firebaseId),
        )
        .map((item) => item.id)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await isar.healthModels.deleteAll(
        idsToDelete,
      );
    }
  }

  // ============================================================
  // PREGNANCY
  // ============================================================

  Future<void> _pullPregnancy(
    Isar isar,
    String farmId,
  ) async {
    final docs = await _records(
      'pregnancy_records',
      farmId,
    );

    final activeDocs = docs
        .where((doc) => doc.data()['deletedAt'] == null)
        .toList();

    final remoteIds =
        activeDocs.map((doc) => doc.id).toSet();

    await isar.writeTxn(() async {
      for (final doc in activeDocs) {
        final data = doc.data();

        final old = await isar.pregnancyModels
            .filter()
            .firebaseIdEqualTo(doc.id)
            .findFirst();

        final item = PregnancyModel(
          firebaseId: doc.id,
          animalFirebaseId: data['animalFirebaseId']?.toString(),
          animalTagNumber: _text(
            data,
            'animalTagNumber',
          ),
          breedingDate: _date(
            data['breedingDate'],
          ),
          bullOrSemenDetail: _text(
            data,
            'bullOrSemenDetail',
          ),
          status: _text(
            data,
            'status',
          ),
          expectedDeliveryDate: _nullableDate(
            data['expectedDeliveryDate'],
          ),
          actualDeliveryDate: _nullableDate(
            data['actualDeliveryDate'],
          ),
          lastSyncAt: DateTime.now(),
        )..id = old?.id ?? Isar.autoIncrement;

        await isar.pregnancyModels.put(item);
      }

      await _removeMissingPregnancy(
        isar,
        remoteIds,
      );
    });
  }

  Future<void> _removeMissingPregnancy(
    Isar isar,
    Set<String> remoteIds,
  ) async {
    final localRecords =
        await isar.pregnancyModels.where().findAll();

    final idsToDelete = localRecords
        .where(
          (item) =>
              item.firebaseId != null &&
              item.firebaseId!.isNotEmpty &&
              !remoteIds.contains(item.firebaseId),
        )
        .map((item) => item.id)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await isar.pregnancyModels.deleteAll(
        idsToDelete,
      );
    }
  }
}