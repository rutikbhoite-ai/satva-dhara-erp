import 'package:isar_community/isar.dart';

part 'milk_model.g.dart';

@collection
class MilkModel {
  Id id = Isar.autoIncrement;

  @Index()
  String? firebaseId;

  /// Permanent reference to Animal Master.
  ///
  /// This stores AnimalModel.firebaseId and must be used
  /// as the primary relationship between Milk and Animal.
  ///
  /// animalTagNumber is intentionally kept separately because
  /// the animal tag can be changed later.
  @Index()
  String? animalFirebaseId;

  /// Historical/display snapshot of the animal tag at the
  /// time this milk record was created/updated.
  ///
  /// Do not use this as the permanent Animal relationship.
  late String animalTagNumber;

  late DateTime date;
  late String shift;
  late double quantityInLiters;
  late double fat;
  late double snf;
  late double ratePerLiter;
  late double totalPrice;

  DateTime? lastSyncAt;

  MilkModel({
    this.firebaseId,
    this.animalFirebaseId,
    required this.animalTagNumber,
    required this.date,
    required this.shift,
    required this.quantityInLiters,
    required this.fat,
    required this.snf,
    required this.ratePerLiter,
    required this.totalPrice,
    this.lastSyncAt,
  });
}