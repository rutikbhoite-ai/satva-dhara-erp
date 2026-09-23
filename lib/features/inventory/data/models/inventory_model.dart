import 'package:isar_community/isar.dart';

part 'inventory_model.g.dart';

@collection
class InventoryModel {
  Id id = Isar.autoIncrement;

  @Index()
  String? firebaseId;

  late String itemName;        // साहित्याचे नाव (उदा. सरकी पेंड, मका भुसा, व्हिटॅमिन)
  late String category;        // कॅटेगरी (पशुखाद्य / औषध / मिनरल)
  late double quantity;        // सध्याचा साठा (उदा. 50)
  late String unit;            // एकक (गोणी / किलो / लिटर)
  late double minThreshold;    // किमान साठा अलर्ट लिमिट (उदा. 5 गोणी)

  DateTime? lastSyncAt;

  InventoryModel({
    this.firebaseId,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minThreshold,
    this.lastSyncAt,
  });
}