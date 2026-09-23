import 'package:isar_community/isar.dart';

part 'sync_operation_model.g.dart';

@collection
class SyncOperationModel {
  // ============================================================
  // LOCAL ISAR ID
  // ============================================================

  Id id = Isar.autoIncrement;

  // ============================================================
  // ENTITY
  // ============================================================

  /// Business entity type.
  ///
  /// Examples:
  /// animal
  /// milk
  /// expense
  /// inventory
  /// health
  /// pregnancy
  @Index()
  late String entityType;

  /// Local Isar ID of the business record.
  @Index()
  late int localId;

  /// Firestore document ID.
  ///
  /// Null when the record has not yet been uploaded.
  String? remoteId;

  // ============================================================
  // OPERATION
  // ============================================================

  /// Pending operation type.
  ///
  /// Expected values:
  /// create
  /// update
  /// delete
  late String operation;

  // ============================================================
  // SYNC STATUS
  // ============================================================

  /// Current queue status.
  ///
  /// Expected values:
  /// pending
  /// syncing
  /// synced
  /// failed
  /// conflict
  @Index()
  late String status;

  // ============================================================
  // RETRY
  // ============================================================

  /// Number of sync attempts already made.
  int retryCount = 0;

  /// Next time this operation should be attempted.
  DateTime? nextRetryAt;

  /// Last time an attempt was made.
  DateTime? lastAttemptAt;

  /// Last sync error message.
  String? lastError;

  // ============================================================
  // TIMESTAMPS
  // ============================================================

  /// Time when this queue operation was created.
  @Index()
  late DateTime createdAt;

  /// Time when this operation was successfully synced.
  DateTime? syncedAt;

  // ============================================================
  // PAYLOAD
  // ============================================================

  /// JSON encoded operation payload.
  ///
  /// Example:
  /// {
  ///   "tagNumber": "C-01",
  ///   "type": "Cow",
  ///   "breed": "HF"
  /// }
  String? payloadJson;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  SyncOperationModel({
    this.remoteId,
    required this.entityType,
    required this.localId,
    required this.operation,
    required this.status,
    this.retryCount = 0,
    required this.createdAt,
    this.nextRetryAt,
    this.lastAttemptAt,
    this.lastError,
    this.syncedAt,
    this.payloadJson,
  });
}