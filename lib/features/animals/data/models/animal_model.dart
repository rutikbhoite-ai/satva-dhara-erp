import 'package:isar_community/isar.dart';

part 'animal_model.g.dart';

@collection
class AnimalModel {
  // ============================================================
  // LOCAL / CLOUD IDENTITY
  // ============================================================

  Id id = Isar.autoIncrement;

  @Index()
  String? firebaseId;

  // ============================================================
  // BASIC ANIMAL INFORMATION
  // ============================================================

  late String tagNumber;

  late String type;

  late String breed;

  late DateTime dateOfBirth;

  late String status;

  bool isMilking = true;

  // ============================================================
  // FARM ENTRY / OWNERSHIP HISTORY
  // ============================================================

  /// How the animal came into the farm.
  ///
  /// Supported values:
  /// - born_on_farm
  /// - purchased
  /// - transferred
  /// - unknown
  String sourceType = 'unknown';

  /// Date on which the animal entered this farm.
  DateTime? farmEntryDate;

  /// Season / batch from which the animal belongs to this farm.
  ///
  /// Example:
  /// 2025-26
  /// 2024-25
  String? farmEntrySeason;

  /// Previous farm / owner name if the animal was purchased
  /// or transferred.
  String? previousFarm;

  /// Original purchase date.
  DateTime? purchaseDate;

  /// Purchase price.
  double? purchasePrice;

  // ============================================================
  // ANIMAL LINEAGE
  // ============================================================

  /// Firebase ID of the mother animal.
  ///
  /// This creates the relationship:
  /// Current Animal -> Mother Animal
  String? motherAnimalId;

  /// Firebase ID of the father / bull.
  String? fatherAnimalId;

  /// Mother animal's tag number cached for display.
  ///
  /// This is optional and should not be treated as the
  /// primary relationship.
  String? motherTagNumber;

  /// Father / bull tag number cached for display.
  String? fatherTagNumber;

  // ============================================================
  // ADDITIONAL IDENTIFICATION
  // ============================================================

  /// RFID / electronic identification number.
  String? rfidNumber;

  /// Animal colour / visible identification.
  String? color;

  /// Additional identification marks or notes.
  String? identificationNotes;

  // ============================================================
  // PRODUCTION / BREEDING FOUNDATION
  // ============================================================

  /// Current lactation number.
  int? lactationNumber;

  /// Last calving / delivery date.
  DateTime? lastCalvingDate;

  /// Expected next calving date.
  DateTime? expectedCalvingDate;

  /// Current pregnancy status.
  ///
  /// Example:
  /// not_pregnant
  /// pregnant
  /// unknown
  String pregnancyStatus = 'unknown';

  // ============================================================
  // SYNC
  // ============================================================

  DateTime? lastSyncAt;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  AnimalModel({
    this.firebaseId,

    required this.tagNumber,

    required this.type,

    required this.breed,

    required this.dateOfBirth,

    required this.status,

    this.isMilking = true,

    this.sourceType = 'unknown',

    this.farmEntryDate,

    this.farmEntrySeason,

    this.previousFarm,

    this.purchaseDate,

    this.purchasePrice,

    this.motherAnimalId,

    this.fatherAnimalId,

    this.motherTagNumber,

    this.fatherTagNumber,

    this.rfidNumber,

    this.color,

    this.identificationNotes,

    this.lactationNumber,

    this.lastCalvingDate,

    this.expectedCalvingDate,

    this.pregnancyStatus = 'unknown',

    this.lastSyncAt,
  });

  // ============================================================
  // HELPER GETTERS
  // ============================================================

  bool get wasBornOnFarm =>
      sourceType == 'born_on_farm';

  bool get wasPurchased =>
      sourceType == 'purchased';

  bool get wasTransferred =>
      sourceType == 'transferred';

  bool get hasMother =>
      motherAnimalId != null &&
      motherAnimalId!.trim().isNotEmpty;

  bool get hasFather =>
      fatherAnimalId != null &&
      fatherAnimalId!.trim().isNotEmpty;

  bool get isPregnant =>
      pregnancyStatus == 'pregnant';

  bool get hasFarmHistory =>
      farmEntryDate != null ||
      (farmEntrySeason != null &&
          farmEntrySeason!.trim().isNotEmpty);

  bool get hasLineage =>
      hasMother || hasFather;
}