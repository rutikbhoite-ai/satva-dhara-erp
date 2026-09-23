import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  // ============================================================
  // BASIC
  // ============================================================

  final String? id;

  // ============================================================
  // FARM
  // ============================================================

  final String farmId;

  // ============================================================
  // USER
  // ============================================================

  final String userId;
  final String userName;
  final String userEmail;
  final String userRole;

  // ============================================================
  // AUDIT INFORMATION
  // ============================================================

  final String module;
  final String action;

  final String entityType;
  final String entityId;

  // ============================================================
  // DESCRIPTION / SUMMARY
  // ============================================================

  final String summary;

  // ============================================================
  // EXTRA INFORMATION
  // ============================================================

  final Map<String, dynamic> metadata;

  // ============================================================
  // TIMESTAMP
  // ============================================================

  final DateTime createdAt;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const AuditLogModel({
    this.id,
    required this.farmId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.module,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.summary,
    this.metadata = const {},
    required this.createdAt,
  });

  // ============================================================
  // BACKWARD COMPATIBILITY
  // ============================================================
  //
  // Older screen/code may use `description`.
  // Version 4 stores the actual value in `summary`.
  //
  // Therefore description simply points to summary.
  // ============================================================

  String get description => summary;

  // ============================================================
  // FIRESTORE → MODEL
  // ============================================================

  factory AuditLogModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data =
        document.data() ?? <String, dynamic>{};

    return AuditLogModel(
      id: document.id,
      farmId: _stringValue(
        data['farmId'],
      ),
      userId: _stringValue(
        data['userId'],
      ),
      userName: _stringValue(
        data['userName'],
      ),
      userEmail: _stringValue(
        data['userEmail'],
      ),
      userRole: _stringValue(
        data['userRole'],
      ),
      module: _stringValue(
        data['module'],
      ),
      action: _stringValue(
        data['action'],
      ),
      entityType: _stringValue(
        data['entityType'],
      ),
      entityId: _stringValue(
        data['entityId'],
      ),
      summary: _summaryValue(
        data,
      ),
      metadata: _mapValue(
        data['metadata'],
      ),
      createdAt: _dateTimeValue(
        data['createdAt'],
      ),
    );
  }

  // ============================================================
  // MAP → MODEL
  // ============================================================

  factory AuditLogModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return AuditLogModel(
      id: id,
      farmId: _stringValue(
        data['farmId'],
      ),
      userId: _stringValue(
        data['userId'],
      ),
      userName: _stringValue(
        data['userName'],
      ),
      userEmail: _stringValue(
        data['userEmail'],
      ),
      userRole: _stringValue(
        data['userRole'],
      ),
      module: _stringValue(
        data['module'],
      ),
      action: _stringValue(
        data['action'],
      ),
      entityType: _stringValue(
        data['entityType'],
      ),
      entityId: _stringValue(
        data['entityId'],
      ),
      summary: _summaryValue(
        data,
      ),
      metadata: _mapValue(
        data['metadata'],
      ),
      createdAt: _dateTimeValue(
        data['createdAt'],
      ),
    );
  }

  // ============================================================
  // MODEL → FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'farmId': farmId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userRole': userRole,
      'module': module,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'summary': summary,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(
        createdAt,
      ),
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  AuditLogModel copyWith({
    String? id,
    String? farmId,
    String? userId,
    String? userName,
    String? userEmail,
    String? userRole,
    String? module,
    String? action,
    String? entityType,
    String? entityId,
    String? summary,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return AuditLogModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userRole: userRole ?? this.userRole,
      module: module ?? this.module,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      summary: summary ?? this.summary,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ============================================================
  // ACTION LABEL
  // ============================================================

  String get actionLabel {
    switch (action.trim().toLowerCase()) {
      case 'create':
      case 'created':
      case 'add':
      case 'added':
        return 'तयार केले';

      case 'update':
      case 'updated':
      case 'edit':
      case 'edited':
        return 'अपडेट केले';

      case 'delete':
      case 'deleted':
      case 'remove':
      case 'removed':
        return 'हटवले';

      case 'login':
      case 'logged_in':
      case 'sign_in':
      case 'signed_in':
        return 'लॉगिन केले';

      case 'logout':
      case 'logged_out':
      case 'sign_out':
      case 'signed_out':
        return 'लॉगआउट केले';

      case 'view':
      case 'viewed':
        return 'पाहिले';

      case 'search':
      case 'searched':
        return 'शोध घेतला';

      case 'export':
      case 'exported':
        return 'Export केले';

      case 'print':
      case 'printed':
        return 'Print केले';

      case 'approve':
      case 'approved':
        return 'मंजूर केले';

      case 'reject':
      case 'rejected':
        return 'नाकारले';

      default:
        return action;
    }
  }

  // ============================================================
  // MODULE LABEL
  // ============================================================

  String get moduleLabel {
    switch (module.trim().toLowerCase()) {
      case 'animal':
      case 'animals':
        return 'जनावरे';

      case 'milk':
      case 'milk_entry':
      case 'milk_entries':
        return 'दूध';

      case 'expense':
      case 'expenses':
        return 'खर्च';

      case 'inventory':
      case 'stock':
        return 'साठा';

      case 'health':
      case 'animal_health':
        return 'आरोग्य';

      case 'pregnancy':
      case 'reproduction':
        return 'गर्भधारणा';

      case 'report':
      case 'reports':
        return 'रिपोर्ट';

      case 'user':
      case 'users':
        return 'वापरकर्ता';

      case 'auth':
      case 'authentication':
        return 'प्रमाणीकरण';

      case 'settings':
        return 'सेटिंग्ज';

      case 'dashboard':
        return 'डॅशबोर्ड';

      case 'audit':
      case 'audit_log':
      case 'audit_logs':
        return 'Audit Log';

      default:
        return module;
    }
  }

  // ============================================================
  // ENTITY LABEL
  // ============================================================

  String get entityLabel {
    switch (entityType.trim().toLowerCase()) {
      case 'animal':
      case 'animal_id':
        return 'जनावर';

      case 'milk':
      case 'milk_entry':
      case 'milk_record':
        return 'दूध नोंद';

      case 'expense':
      case 'expense_entry':
        return 'खर्च';

      case 'inventory':
      case 'inventory_item':
      case 'stock':
        return 'साठा';

      case 'health':
      case 'health_record':
        return 'आरोग्य नोंद';

      case 'pregnancy':
      case 'pregnancy_record':
        return 'गर्भधारणा';

      case 'user':
      case 'user_profile':
        return 'वापरकर्ता';

      case 'farm':
        return 'फार्म';

      case 'settings':
        return 'सेटिंग्ज';

      default:
        return entityType;
    }
  }

  // ============================================================
  // ACTION CHECKS
  // ============================================================

  bool get isCreate {
    final value =
        action.trim().toLowerCase();

    return value == 'create' ||
        value == 'created' ||
        value == 'add' ||
        value == 'added';
  }

  bool get isUpdate {
    final value =
        action.trim().toLowerCase();

    return value == 'update' ||
        value == 'updated' ||
        value == 'edit' ||
        value == 'edited';
  }

  bool get isDelete {
    final value =
        action.trim().toLowerCase();

    return value == 'delete' ||
        value == 'deleted' ||
        value == 'remove' ||
        value == 'removed';
  }

  bool get isLogin {
    final value =
        action.trim().toLowerCase();

    return value == 'login' ||
        value == 'logged_in' ||
        value == 'sign_in' ||
        value == 'signed_in';
  }

  bool get isLogout {
    final value =
        action.trim().toLowerCase();

    return value == 'logout' ||
        value == 'logged_out' ||
        value == 'sign_out' ||
        value == 'signed_out';
  }

  bool get isView {
    final value =
        action.trim().toLowerCase();

    return value == 'view' ||
        value == 'viewed';
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool get hasValidFarm =>
      farmId.trim().isNotEmpty;

  bool get hasValidUser =>
      userId.trim().isNotEmpty;

  bool get hasValidModule =>
      module.trim().isNotEmpty;

  bool get hasValidAction =>
      action.trim().isNotEmpty;

  bool get hasValidEntity =>
      entityType.trim().isNotEmpty;

  bool get hasValidSummary =>
      summary.trim().isNotEmpty;

  bool get isValid =>
      hasValidFarm &&
      hasValidUser &&
      hasValidModule &&
      hasValidAction &&
      hasValidEntity &&
      hasValidSummary;

  // ============================================================
  // DISPLAY TITLE
  // ============================================================

  String get displayTitle {
    if (summary.trim().isNotEmpty) {
      return summary.trim();
    }

    return '$moduleLabel • $actionLabel';
  }

  // ============================================================
  // DISPLAY USER
  // ============================================================

  String get displayUser {
    if (userName.trim().isNotEmpty) {
      return userName.trim();
    }

    if (userEmail.trim().isNotEmpty) {
      return userEmail.trim();
    }

    return 'Unknown User';
  }

  // ============================================================
  // DISPLAY ENTITY
  // ============================================================

  String get displayEntity {
    if (entityId.trim().isEmpty) {
      return entityLabel;
    }

    return '$entityLabel • $entityId';
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _stringValue(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // SUMMARY VALUE
  // ============================================================
  //
  // Version 4 uses `summary`.
  //
  // `description` is accepted while reading old documents
  // so existing audit logs do not break.
  // ============================================================

  static String _summaryValue(
    Map<String, dynamic> data,
  ) {
    final summary =
        data['summary'];

    if (summary != null &&
        summary.toString().trim().isNotEmpty) {
      return summary.toString();
    }

    final description =
        data['description'];

    if (description != null &&
        description.toString().trim().isNotEmpty) {
      return description.toString();
    }

    return '';
  }

  // ============================================================
  // MAP VALUE
  // ============================================================

  static Map<String, dynamic> _mapValue(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return <String, dynamic>{};
  }

  // ============================================================
  // DATE VALUE
  // ============================================================

  static DateTime _dateTimeValue(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parsed =
          DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value,
      );
    }

    return DateTime.fromMillisecondsSinceEpoch(
      0,
    );
  }

  // ============================================================
  // TO STRING
  // ============================================================

  @override
  String toString() {
    return 'AuditLogModel('
        'id: $id, '
        'farmId: $farmId, '
        'userId: $userId, '
        'userName: $userName, '
        'userEmail: $userEmail, '
        'userRole: $userRole, '
        'module: $module, '
        'action: $action, '
        'entityType: $entityType, '
        'entityId: $entityId, '
        'summary: $summary, '
        'metadata: $metadata, '
        'createdAt: $createdAt'
        ')';
  }
}