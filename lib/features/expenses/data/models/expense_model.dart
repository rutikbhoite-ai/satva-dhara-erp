import 'package:isar_community/isar.dart';

part 'expense_model.g.dart';

@collection
class ExpenseModel {
  Id id = Isar.autoIncrement;

  @Index()
  String? firebaseId;

  late DateTime date;           // खर्चाची तारीख
  late String category;         // खर्चाचा प्रकार (चारा, औषध, पगार, इतर)
  late double amount;           // रक्कम (₹)
  late String description;      // खर्चाचा तपशील

  DateTime? lastSyncAt;

  ExpenseModel({
    this.firebaseId,
    required this.date,
    required this.category,
    required this.amount,
    required this.description,
    this.lastSyncAt,
  });
}