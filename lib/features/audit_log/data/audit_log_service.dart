import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'audit_log_model.dart';
import '../../auth/data/auth_profile_service.dart';
import '../../auth/data/user_profile_model.dart';

class AuditLogService {
  AuditLogService._();

  static final AuditLogService instance =
      AuditLogService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final AuthProfileService _authProfileService =
      AuthProfileService.instance;

  static const String _collection =
      'audit_logs';

  // ============================================================
  // CREATE AUDIT LOG
  // ============================================================

  Future<String?> createLog({
    required String module,
    required String action,
    required String entityType,
    required String entityId,
    required String summary,
    Map<String, dynamic> metadata = const {},
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        'AuditLogService: Cannot create log. '
        'No authenticated user.',
      );

      return null;
    }

    try {
      UserProfileModel? profile;

      try {
        profile =
            await _authProfileService
                .getCurrentProfile();
      } catch (e, stackTrace) {
        debugPrint(
          'AuditLogService: profile loading failed: $e',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      }

      final farmId =
          profile?.farmId.trim() ?? '';

      if (farmId.isEmpty) {
        debugPrint(
          'AuditLogService: Cannot create audit log. '
          'farmId is empty.',
        );

        return null;
      }

      final userName =
          profile?.displayName.trim().isNotEmpty == true
              ? profile!.displayName.trim()
              : (user.displayName ?? '').trim();

      final userEmail =
          profile?.email.trim().isNotEmpty == true
              ? profile!.email.trim()
              : (user.email ?? '').trim();

      final userRole =
          profile?.role.trim().isNotEmpty == true
              ? profile!.role.trim()
              : 'staff';

      final log = AuditLogModel(
        farmId: farmId,
        userId: user.uid,
        userName: userName,
        userEmail: userEmail,
        userRole: userRole,
        module: module.trim(),
        action: action.trim(),
        entityType: entityType.trim(),
        entityId: entityId.trim(),
        summary: summary.trim(),
        metadata: Map<String, dynamic>.from(
          metadata,
        ),
        createdAt: DateTime.now(),
      );

      final documentReference =
          await _firestore
              .collection(_collection)
              .add(
                {
                  ...log.toMap(),
                  // Required by the append-only Firestore rule; never trust a
                  // caller-supplied creator value.
                  'createdBy': user.uid,
                },
              );

      debugPrint(
        'Audit log created successfully: '
        '${documentReference.id}',
      );

      return documentReference.id;
    } catch (e, stackTrace) {
      debugPrint(
        'AuditLogService: create log failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ============================================================
  // CREATE FROM MODEL
  // ============================================================

  Future<String?> createFromModel(
    AuditLogModel log,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        'AuditLogService: Cannot create log. '
        'No authenticated user.',
      );

      return null;
    }

    if (log.userId != user.uid) {
      debugPrint(
        'AuditLogService: User ID mismatch.',
      );

      return null;
    }

    if (!log.isValid) {
      debugPrint(
        'AuditLogService: Invalid audit log model.',
      );

      return null;
    }

    try {
      final reference =
          await _firestore
              .collection(_collection)
              .add(
                log.toMap(),
              );

      debugPrint(
        'Audit log created from model: '
        '${reference.id}',
      );

      return reference.id;
    } catch (e, stackTrace) {
      debugPrint(
        'AuditLogService: createFromModel failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ============================================================
  // GET CURRENT USER LOGS
  // ============================================================

  Future<List<AuditLogModel>> getCurrentUserLogs({
    int limit = 100,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return [];
    }

    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where(
                'userId',
                isEqualTo: user.uid,
              )
              .orderBy(
                'createdAt',
                descending: true,
              )
              .limit(limit)
              .get();

      return snapshot.docs
          .map(
            (document) =>
                AuditLogModel.fromFirestore(
              document,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      debugPrint(
        'AuditLogService: getCurrentUserLogs failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return [];
    }
  }

  // ============================================================
  // GET FARM LOGS
  // ============================================================

  Future<List<AuditLogModel>> getFarmLogs({
    required String farmId,
    int limit = 100,
  }) async {
    final cleanFarmId =
        farmId.trim();

    if (cleanFarmId.isEmpty) {
      return [];
    }

    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where(
                'farmId',
                isEqualTo: cleanFarmId,
              )
              .orderBy(
                'createdAt',
                descending: true,
              )
              .limit(limit)
              .get();

      return snapshot.docs
          .map(
            (document) =>
                AuditLogModel.fromFirestore(
              document,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      debugPrint(
        'AuditLogService: getFarmLogs failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return [];
    }
  }

  // ============================================================
  // GET CURRENT FARM LOGS
  // ============================================================

  Future<List<AuditLogModel>>
      getCurrentFarmLogs({
    int limit = 100,
  }) async {
    try {
      final profile =
          await _authProfileService
              .getCurrentProfile();

      if (profile == null) {
        debugPrint(
          'AuditLogService: Current profile not found.',
        );

        return [];
      }

      if (!profile.hasValidFarm) {
        debugPrint(
          'AuditLogService: Current profile has no farm.',
        );

        return [];
      }

      return getFarmLogs(
        farmId: profile.farmId,
        limit: limit,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'AuditLogService: getCurrentFarmLogs failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return [];
    }
  }

  // ============================================================
  // GET ALL LOGS FOR CURRENT FARM
  // ============================================================
  //
  // The Audit Log screen uses this method as its single loading
  // entry point. It is intentionally farm-scoped; it does not
  // read audit records from other farms.
  // ============================================================

  Future<List<AuditLogModel>> getAllLogs({
    int limit = 500,
  }) async {
    final safeLimit = limit < 1 ? 1 : limit;

    return getCurrentFarmLogs(
      limit: safeLimit,
    );
  }

  // ============================================================
  // WATCH FARM LOGS
  // ============================================================

  Stream<List<AuditLogModel>> watchFarmLogs({
    required String farmId,
    int limit = 100,
  }) {
    final cleanFarmId =
        farmId.trim();

    if (cleanFarmId.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection(_collection)
        .where(
          'farmId',
          isEqualTo: cleanFarmId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (document) =>
                      AuditLogModel.fromFirestore(
                    document,
                  ),
                )
                .toList();
          },
        );
  }

  // ============================================================
  // WATCH CURRENT FARM LOGS
  // ============================================================

  Stream<List<AuditLogModel>>
      watchCurrentFarmLogs({
    int limit = 100,
  }) async* {
    try {
      final profile =
          await _authProfileService
              .getCurrentProfile();

      if (profile == null ||
          !profile.hasValidFarm) {
        yield [];
        return;
      }

      yield* watchFarmLogs(
        farmId: profile.farmId,
        limit: limit,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'AuditLogService: watchCurrentFarmLogs failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      yield [];
    }
  }

  // ============================================================
  // GET LOG BY ID
  // ============================================================

  Future<AuditLogModel?> getLogById(
    String logId,
  ) async {
    final cleanId =
        logId.trim();

    if (cleanId.isEmpty) {
      return null;
    }

    try {
      final document =
          await _firestore
              .collection(_collection)
              .doc(cleanId)
              .get();

      if (!document.exists) {
        return null;
      }

      return AuditLogModel.fromFirestore(
        document,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'AuditLogService: getLogById failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ============================================================
  // DELETE SINGLE LOG
  // ============================================================
  //
  // Audit logs are normally protected.
  // Only Admin / Owner can delete.
  // ============================================================

  Future<bool> deleteLog(
    String logId,
  ) async {
    final cleanId =
        logId.trim();

    if (cleanId.isEmpty) {
      return false;
    }

    try {
      final profile =
          await _authProfileService
              .getCurrentProfile();

      if (profile == null ||
          !profile.isAdmin) {
        debugPrint(
          'AuditLogService: Delete denied. '
          'Admin/Owner permission required.',
        );

        return false;
      }

      await _firestore
          .collection(_collection)
          .doc(cleanId)
          .delete();

      debugPrint(
        'Audit log deleted: $cleanId',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'AuditLogService: deleteLog failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // DELETE MULTIPLE LOGS
  // ============================================================

  Future<bool> deleteLogs(
    List<String> logIds,
  ) async {
    if (logIds.isEmpty) {
      return true;
    }

    try {
      final profile =
          await _authProfileService
              .getCurrentProfile();

      if (profile == null ||
          !profile.isAdmin) {
        debugPrint(
          'AuditLogService: Bulk delete denied.',
        );

        return false;
      }

      final batch =
          _firestore.batch();

      for (final logId in logIds) {
        final cleanId =
            logId.trim();

        if (cleanId.isEmpty) {
          continue;
        }

        final reference =
            _firestore
                .collection(_collection)
                .doc(cleanId);

        batch.delete(reference);
      }

      await batch.commit();

      debugPrint(
        'Audit logs deleted: '
        '${logIds.length}',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'AuditLogService: deleteLogs failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}
