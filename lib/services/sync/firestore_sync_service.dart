import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../features/milk/data/models/milk_model.dart';
import '../../features/animals/data/models/animal_model.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/health/data/models/health_model.dart';
import '../../features/inventory/data/models/inventory_model.dart';
import '../../features/pregnancy/data/models/pregnancy_model.dart';
import '../../features/auth/data/auth_profile_service.dart';

class FirestoreSyncService {
  FirestoreSyncService._();

  static final FirestoreSyncService instance =
      FirestoreSyncService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<Map<String, String>?> _ownershipFields({
    required bool isCreate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final profile = await AuthProfileService.instance.getCurrentProfile();
    if (user == null || profile == null || !profile.canUseApplication) {
      debugPrint('Firestore sync skipped: active farm profile is required.');
      return null;
    }
    return {
      'farmId': profile.farmId.trim(),
      if (isCreate) 'createdBy': user.uid,
    };
  }

  // ============================================================
  // ANIMAL
  // ============================================================

  Future<String?> saveAnimalRecord(
    AnimalModel animal,
  ) async {
    try {
      final ownership = await _ownershipFields(isCreate: animal.firebaseId == null || animal.firebaseId!.trim().isEmpty);
      if (ownership == null) return null;
      final collection =
          _firestore.collection('animals');

      DocumentReference<Map<String, dynamic>> document;

      if (animal.firebaseId != null &&
          animal.firebaseId!.trim().isNotEmpty) {
        document =
            collection.doc(animal.firebaseId);
      } else {
        document = collection.doc();
      }

      await document.set(
        {
          ...ownership,
          // ------------------------------------------------------
          // BASIC INFORMATION
          // ------------------------------------------------------

          'tagNumber': animal.tagNumber,
          'type': animal.type,
          'breed': animal.breed,
          'dateOfBirth':
              animal.dateOfBirth.toIso8601String(),
          'status': animal.status,
          'isMilking': animal.isMilking,

          // ------------------------------------------------------
          // FARM ENTRY / OWNERSHIP HISTORY
          // ------------------------------------------------------

          'sourceType': animal.sourceType,

          'farmEntryDate':
              animal.farmEntryDate?.toIso8601String(),

          'farmEntrySeason':
              animal.farmEntrySeason,

          'previousFarm':
              animal.previousFarm,

          'purchaseDate':
              animal.purchaseDate?.toIso8601String(),

          'purchasePrice':
              animal.purchasePrice,

          // ------------------------------------------------------
          // ANIMAL LINEAGE
          // ------------------------------------------------------

          'motherAnimalId':
              animal.motherAnimalId,

          'fatherAnimalId':
              animal.fatherAnimalId,

          'motherTagNumber':
              animal.motherTagNumber,

          'fatherTagNumber':
              animal.fatherTagNumber,

          // ------------------------------------------------------
          // ADDITIONAL IDENTIFICATION
          // ------------------------------------------------------

          'rfidNumber':
              animal.rfidNumber,

          'color':
              animal.color,

          'identificationNotes':
              animal.identificationNotes,

          // ------------------------------------------------------
          // PRODUCTION / BREEDING
          // ------------------------------------------------------

          'lactationNumber':
              animal.lactationNumber,

          'lastCalvingDate':
              animal.lastCalvingDate?.toIso8601String(),

          'expectedCalvingDate':
              animal.expectedCalvingDate?.toIso8601String(),

          'pregnancyStatus':
              animal.pregnancyStatus,

          // ------------------------------------------------------
          // SYNC INFORMATION
          // ------------------------------------------------------

          'timestamp':
              FieldValue.serverTimestamp(),

          'schemaVersion': 3,

          'source':
              'satva_dhara_erp',
        },
        SetOptions(
          merge: true,
        ),
      );

      return document.id;
    } catch (e, stackTrace) {
      debugPrint(
        'Animal Firestore sync failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  Future<bool> deleteAnimalRecord(
    String? firebaseId,
  ) async {
    if (firebaseId == null ||
        firebaseId.trim().isEmpty) {
      return true;
    }

    try {
      await _firestore.collection('animals').doc(firebaseId).set(
        {'deletedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      debugPrint(
        'Animal deleted from Firestore: $firebaseId',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Animal Firestore delete failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // MILK
  // ============================================================

  Future<String?> saveMilkRecord(
    MilkModel milk,
  ) async {
    try {
      final ownership = await _ownershipFields(isCreate: milk.firebaseId == null || milk.firebaseId!.trim().isEmpty);
      if (ownership == null) return null;
      final collection =
          _firestore.collection('milk_records');

      DocumentReference<Map<String, dynamic>> document;

      if (milk.firebaseId != null &&
          milk.firebaseId!.trim().isNotEmpty) {
        document =
            collection.doc(milk.firebaseId);
      } else {
        document = collection.doc();
      }

      await document.set(
        {
          ...ownership,
          'animalFirebaseId':
              milk.animalFirebaseId,
          'animalTagNumber':
              milk.animalTagNumber,
          'date':
              milk.date.toIso8601String(),
          'shift':
              milk.shift,
          'quantityInLiters':
              milk.quantityInLiters,
          'fat':
              milk.fat,
          'snf':
              milk.snf,
          'ratePerLiter':
              milk.ratePerLiter,
          'totalPrice':
              milk.totalPrice,
          'timestamp':
              FieldValue.serverTimestamp(),
          'schemaVersion':
              2,
          'source':
              'satva_dhara_erp',
        },
        SetOptions(
          merge: true,
        ),
      );

      return document.id;
    } catch (e, stackTrace) {
      debugPrint(
        'Milk Firestore sync failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  Future<bool> deleteMilkRecord(
    String? firebaseId,
  ) async {
    if (firebaseId == null ||
        firebaseId.trim().isEmpty) {
      return true;
    }

    try {
      await _firestore.collection('milk_records').doc(firebaseId).set(
        {'deletedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      debugPrint(
        'Milk deleted from Firestore: $firebaseId',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Milk Firestore delete failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // EXPENSE
  // ============================================================

  Future<String?> saveExpenseRecord(
    ExpenseModel expense,
  ) async {
    try {
      final ownership = await _ownershipFields(isCreate: expense.firebaseId == null || expense.firebaseId!.trim().isEmpty);
      if (ownership == null) return null;
      final collection =
          _firestore.collection('expenses');

      DocumentReference<Map<String, dynamic>> document;

      if (expense.firebaseId != null &&
          expense.firebaseId!.trim().isNotEmpty) {
        document =
            collection.doc(expense.firebaseId);
      } else {
        document = collection.doc();
      }

      await document.set(
        {
          ...ownership,
          'date':
              expense.date.toIso8601String(),
          'category':
              expense.category,
          'amount':
              expense.amount,
          'description':
              expense.description,
          'timestamp':
              FieldValue.serverTimestamp(),
          'schemaVersion':
              2,
          'source':
              'satva_dhara_erp',
        },
        SetOptions(
          merge: true,
        ),
      );

      return document.id;
    } catch (e, stackTrace) {
      debugPrint(
        'Expense Firestore sync failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  Future<bool> deleteExpenseRecord(
    String? firebaseId,
  ) async {
    if (firebaseId == null ||
        firebaseId.trim().isEmpty) {
      return true;
    }

    try {
      await _firestore.collection('expenses').doc(firebaseId).set(
        {'deletedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      debugPrint(
        'Expense deleted from Firestore: $firebaseId',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Expense Firestore delete failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // HEALTH
  // ============================================================

  Future<String?> saveHealthRecord(
    HealthModel health,
  ) async {
    try {
      final ownership = await _ownershipFields(isCreate: health.firebaseId == null || health.firebaseId!.trim().isEmpty);
      if (ownership == null) return null;
      final collection =
          _firestore.collection('health_records');

      DocumentReference<Map<String, dynamic>> document;

      if (health.firebaseId != null &&
          health.firebaseId!.trim().isNotEmpty) {
        document =
            collection.doc(health.firebaseId);
      } else {
        document = collection.doc();
      }

      await document.set(
        {
          ...ownership,
          'animalFirebaseId':
              health.animalFirebaseId,
          'animalTagNumber':
              health.animalTagNumber,
          'date':
              health.date.toIso8601String(),
          'type':
              health.type,
          'diagnosis':
              health.diagnosis,
          'treatment':
              health.treatment,
          'cost':
              health.cost,
          'nextFollowUpDate':
              health.nextFollowUpDate
                  ?.toIso8601String(),
          'timestamp':
              FieldValue.serverTimestamp(),
          'schemaVersion':
              2,
          'source':
              'satva_dhara_erp',
        },
        SetOptions(
          merge: true,
        ),
      );

      return document.id;
    } catch (e, stackTrace) {
      debugPrint(
        'Health Firestore sync failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  Future<bool> deleteHealthRecord(
    String? firebaseId,
  ) async {
    if (firebaseId == null ||
        firebaseId.trim().isEmpty) {
      return true;
    }

    try {
      await _firestore.collection('health_records').doc(firebaseId).set(
        {'deletedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      debugPrint(
        'Health record deleted from Firestore: $firebaseId',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Health Firestore delete failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // INVENTORY
  // ============================================================

  Future<String?> saveInventoryRecord(
    InventoryModel item,
  ) async {
    try {
      final ownership = await _ownershipFields(isCreate: item.firebaseId == null || item.firebaseId!.trim().isEmpty);
      if (ownership == null) return null;
      final collection =
          _firestore.collection('inventory');

      DocumentReference<Map<String, dynamic>> document;

      if (item.firebaseId != null &&
          item.firebaseId!.trim().isNotEmpty) {
        document =
            collection.doc(item.firebaseId);
      } else {
        document = collection.doc();
      }

      await document.set(
        {
          ...ownership,
          'itemName':
              item.itemName,
          'category':
              item.category,
          'quantity':
              item.quantity,
          'unit':
              item.unit,
          'minThreshold':
              item.minThreshold,
          'timestamp':
              FieldValue.serverTimestamp(),
          'schemaVersion':
              2,
          'source':
              'satva_dhara_erp',
        },
        SetOptions(
          merge: true,
        ),
      );

      return document.id;
    } catch (e, stackTrace) {
      debugPrint(
        'Inventory Firestore sync failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  Future<bool> deleteInventoryRecord(
    String? firebaseId,
  ) async {
    if (firebaseId == null ||
        firebaseId.trim().isEmpty) {
      return true;
    }

    try {
      await _firestore.collection('inventory').doc(firebaseId).set(
        {'deletedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      debugPrint(
        'Inventory deleted from Firestore: $firebaseId',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Inventory Firestore delete failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // PREGNANCY
  // ============================================================

  Future<String?> savePregnancyRecord(
    PregnancyModel record,
  ) async {
    try {
      final ownership = await _ownershipFields(isCreate: record.firebaseId == null || record.firebaseId!.trim().isEmpty);
      if (ownership == null) return null;
      final collection =
          _firestore.collection('pregnancy_records');

      DocumentReference<Map<String, dynamic>> document;

      if (record.firebaseId != null &&
          record.firebaseId!.trim().isNotEmpty) {
        document =
            collection.doc(record.firebaseId);
      } else {
        document = collection.doc();
      }

      await document.set(
        {
          ...ownership,
          'animalFirebaseId':
              record.animalFirebaseId,
          'animalTagNumber':
              record.animalTagNumber,
          'breedingDate':
              record.breedingDate.toIso8601String(),
          'bullOrSemenDetail':
              record.bullOrSemenDetail,
          'status':
              record.status,
          'expectedDeliveryDate':
              record.expectedDeliveryDate
                  ?.toIso8601String(),
          'actualDeliveryDate':
              record.actualDeliveryDate
                  ?.toIso8601String(),
          'timestamp':
              FieldValue.serverTimestamp(),
          'schemaVersion':
              2,
          'source':
              'satva_dhara_erp',
        },
        SetOptions(
          merge: true,
        ),
      );

      return document.id;
    } catch (e, stackTrace) {
      debugPrint(
        'Pregnancy Firestore sync failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  Future<bool> deletePregnancyRecord(
    String? firebaseId,
  ) async {
    if (firebaseId == null ||
        firebaseId.trim().isEmpty) {
      return true;
    }

    try {
      await _firestore.collection('pregnancy_records').doc(firebaseId).set(
        {'deletedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      debugPrint(
        'Pregnancy record deleted from Firestore: '
        '$firebaseId',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Pregnancy Firestore delete failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
