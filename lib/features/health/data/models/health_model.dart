import 'package:isar_community/isar.dart';

part 'health_model.g.dart';

@collection
class HealthModel {
  Id id = Isar.autoIncrement;

  @Index()
  String? firebaseId;

  /// Permanent reference to Animal Master.
  ///
  /// This stores AnimalModel.firebaseId and must be used
  /// as the primary relationship between Health and Animal.
  @Index()
  String? animalFirebaseId;

  /// Historical/display snapshot of the animal tag.
  ///
  /// Do not use this as the permanent Animal relationship.
  late String animalTagNumber;

  late DateTime date;
  late String type;
  late String diagnosis;
  late String treatment;
  late double cost;
  DateTime? nextFollowUpDate;
  DateTime? lastSyncAt;

  HealthModel({
    this.firebaseId,
    this.animalFirebaseId,
    required this.animalTagNumber,
    required this.date,
    required this.type,
    required this.diagnosis,
    required this.treatment,
    required this.cost,
    this.nextFollowUpDate,
    this.lastSyncAt,
  });
}