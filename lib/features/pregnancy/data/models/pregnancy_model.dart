import 'package:isar_community/isar.dart';

part 'pregnancy_model.g.dart';

@collection
class PregnancyModel {
  Id id = Isar.autoIncrement;

  @Index()
  String? firebaseId;

  /// Permanent reference to Animal Master.
  ///
  /// This stores AnimalModel.firebaseId and must be used
  /// as the primary relationship between Pregnancy and Animal.
  ///
  /// animalTagNumber is intentionally kept separately because
  /// the animal tag can be changed later.
  @Index()
  String? animalFirebaseId;

  /// Historical/display snapshot of the animal tag.
  ///
  /// Do not use this as the permanent Animal relationship.
  late String animalTagNumber;

  late DateTime breedingDate;
  late String bullOrSemenDetail;
  late String status;
  DateTime? expectedDeliveryDate;
  DateTime? actualDeliveryDate;
  DateTime? lastSyncAt;

  PregnancyModel({
    this.firebaseId,
    this.animalFirebaseId,
    required this.animalTagNumber,
    required this.breedingDate,
    required this.bullOrSemenDetail,
    required this.status,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.lastSyncAt,
  });
}
