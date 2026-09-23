import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/sync/sync_queue_service.dart';
import '../../../../database/isar_service.dart';
import 'models/animal_model.dart';

class AnimalRepository {
  final SyncQueueService _syncQueue =
      SyncQueueService.instance;

  // ============================================================
  // GET ALL ANIMALS
  // ============================================================

  Future<List<AnimalModel>> getAllAnimals() async {
    final isar = await IsarService.instance;

    return await isar.animalModels
        .where()
        .findAll();
  }

  // ============================================================
  // GET ANIMAL BY LOCAL ID
  // ============================================================

  Future<AnimalModel?> getAnimalById(
    int id,
  ) async {
    final isar = await IsarService.instance;

    return await isar.animalModels.get(id);
  }

  // ============================================================
  // GET ANIMAL BY FIREBASE ID
  // ============================================================

  Future<AnimalModel?> getAnimalByFirebaseId(
    String firebaseId,
  ) async {
    final isar = await IsarService.instance;

    final value = firebaseId.trim();

    if (value.isEmpty) {
      return null;
    }

    return await isar.animalModels
        .filter()
        .firebaseIdEqualTo(value)
        .findFirst();
  }

  // ============================================================
  // GET ANIMAL BY TAG NUMBER
  // ============================================================

  Future<AnimalModel?> getAnimalByTagNumber(
    String tagNumber,
  ) async {
    final isar = await IsarService.instance;

    final value = tagNumber.trim();

    if (value.isEmpty) {
      return null;
    }

    return await isar.animalModels
        .filter()
        .tagNumberEqualTo(value)
        .findFirst();
  }

  // ============================================================
  // GET MOTHER ANIMAL
  // ============================================================

  Future<AnimalModel?> getMotherAnimal(
    AnimalModel animal,
  ) async {
    final motherId =
        animal.motherAnimalId?.trim();

    if (motherId == null ||
        motherId.isEmpty) {
      return null;
    }

    return getAnimalByFirebaseId(
      motherId,
    );
  }

  // ============================================================
  // GET FATHER / BULL
  // ============================================================

  Future<AnimalModel?> getFatherAnimal(
    AnimalModel animal,
  ) async {
    final fatherId =
        animal.fatherAnimalId?.trim();

    if (fatherId == null ||
        fatherId.isEmpty) {
      return null;
    }

    return getAnimalByFirebaseId(
      fatherId,
    );
  }

  // ============================================================
  // GET CHILDREN OF AN ANIMAL
  // ============================================================
  //
  // This is useful for lineage/history screens.
  //
  // Example:
  // Mother C-01
  //   ├── C-12
  //   ├── C-18
  //   └── C-24
  //
  // The relationship is stored using motherAnimalId.
  // ============================================================

  Future<List<AnimalModel>> getChildrenOfMother(
    AnimalModel mother,
  ) async {
    final firebaseId =
        mother.firebaseId?.trim();

    if (firebaseId == null ||
        firebaseId.isEmpty) {
      return [];
    }

    final isar = await IsarService.instance;

    return await isar.animalModels
        .filter()
        .motherAnimalIdEqualTo(firebaseId)
        .findAll();
  }

  // ============================================================
  // GET CHILDREN OF A FATHER / BULL
  // ============================================================

  Future<List<AnimalModel>> getChildrenOfFather(
    AnimalModel father,
  ) async {
    final firebaseId =
        father.firebaseId?.trim();

    if (firebaseId == null ||
        firebaseId.isEmpty) {
      return [];
    }

    final isar = await IsarService.instance;

    return await isar.animalModels
        .filter()
        .fatherAnimalIdEqualTo(firebaseId)
        .findAll();
  }

  // ============================================================
  // GET CHILDREN OF BOTH PARENTS
  // ============================================================

  Future<List<AnimalModel>> getChildrenOfParents({
    String? motherAnimalId,
    String? fatherAnimalId,
  }) async {
    final isar = await IsarService.instance;

    final motherId =
        motherAnimalId?.trim();

    final fatherId =
        fatherAnimalId?.trim();

    if ((motherId == null ||
            motherId.isEmpty) &&
        (fatherId == null ||
            fatherId.isEmpty)) {
      return [];
    }

    if (motherId != null &&
        motherId.isNotEmpty &&
        fatherId != null &&
        fatherId.isNotEmpty) {
      return await isar.animalModels
          .filter()
          .motherAnimalIdEqualTo(motherId)
          .and()
          .fatherAnimalIdEqualTo(fatherId)
          .findAll();
    }

    if (motherId != null &&
        motherId.isNotEmpty) {
      return await isar.animalModels
          .filter()
          .motherAnimalIdEqualTo(motherId)
          .findAll();
    }

    return await isar.animalModels
        .filter()
        .fatherAnimalIdEqualTo(fatherId!)
        .findAll();
  }

  // ============================================================
  // GET ANIMALS BY SOURCE TYPE
  // ============================================================

  Future<List<AnimalModel>> getAnimalsBySourceType(
    String sourceType,
  ) async {
    final isar = await IsarService.instance;

    final value =
        sourceType.trim();

    if (value.isEmpty) {
      return [];
    }

    return await isar.animalModels
        .filter()
        .sourceTypeEqualTo(value)
        .findAll();
  }

  // ============================================================
  // GET ANIMALS BY FARM ENTRY SEASON
  // ============================================================

  Future<List<AnimalModel>> getAnimalsByFarmEntrySeason(
    String season,
  ) async {
    final isar = await IsarService.instance;

    final value =
        season.trim();

    if (value.isEmpty) {
      return [];
    }

    return await isar.animalModels
        .filter()
        .farmEntrySeasonEqualTo(value)
        .findAll();
  }

  // ============================================================
  // ADD / UPDATE ANIMAL
  // ============================================================

  Future<bool> addAnimal(
    AnimalModel animal,
  ) async {
    final isar =
        await IsarService.instance;

    try {
      // --------------------------------------------------------
      // 1. SAVE LOCALLY FIRST
      // --------------------------------------------------------

      // --------------------------------------------------------
      // 2. DETERMINE CREATE / UPDATE
      // --------------------------------------------------------

      final hasFirebaseId =
          animal.firebaseId != null &&
          animal.firebaseId!.trim().isNotEmpty;

      final operation =
          hasFirebaseId
              ? 'update'
              : 'create';

      // --------------------------------------------------------
      // 3. ADD TO PERSISTENT SYNC QUEUE
      // --------------------------------------------------------

      await isar.writeTxn(() async {
        await isar.animalModels.put(animal);
        await _syncQueue.enqueueInTransaction(
          isar,
          entityType: 'animal', localId: animal.id,
          remoteId: animal.firebaseId, operation: operation,
        );
      });

      debugPrint(
        'Animal saved locally and queued for sync. '
        'Local ID: ${animal.id}, '
        'Operation: $operation',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Animal local save / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // SYNC PENDING ANIMALS
  // ============================================================

  Future<int> syncPendingAnimals() async {
    final pendingCount =
        await _syncQueue.getPendingCount();

    debugPrint(
      'Animal pending operations currently in queue: '
      '$pendingCount',
    );

    return pendingCount;
  }

  // ============================================================
  // DELETE ANIMAL
  // ============================================================

  Future<bool> deleteAnimal(
    AnimalModel animal,
  ) async {
    final isar =
        await IsarService.instance;

    try {
      final firebaseId =
          animal.firebaseId?.trim();

      // --------------------------------------------------------
      // CASE 1:
      // NEVER SYNCED TO FIREBASE
      // --------------------------------------------------------

      if (firebaseId == null ||
          firebaseId.isEmpty) {
        await isar.writeTxn(() async {
          await isar.animalModels.delete(
            animal.id,
          );
        });

        debugPrint(
          'Local-only animal deleted: '
          '${animal.tagNumber}',
        );

        return true;
      }

      // --------------------------------------------------------
      // CASE 2:
      // ALREADY EXISTS IN FIREBASE
      // --------------------------------------------------------

      await isar.writeTxn(() async {
        await isar.animalModels.delete(
          animal.id,
        );
        await _syncQueue.enqueueInTransaction(
          isar, entityType: 'animal', localId: animal.id,
          remoteId: firebaseId, operation: 'delete',
        );
      });

      debugPrint(
        'Animal deleted locally and Firebase delete '
        'queued: ${animal.tagNumber}',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'Animal delete / queue failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
