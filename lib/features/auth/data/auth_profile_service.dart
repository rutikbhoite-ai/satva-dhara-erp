import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_profile_model.dart';

class AuthProfileService {
  AuthProfileService._();

  static final AuthProfileService instance =
      AuthProfileService._();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _usersCollection =
      'users';

  // ============================================================
  // LOCAL CACHE KEYS
  // ============================================================

  static const String _cacheUid =
      'auth_profile_uid';

  static const String _cacheEmail =
      'auth_profile_email';

  static const String _cacheDisplayName =
      'auth_profile_display_name';

  static const String _cacheFarmId =
      'auth_profile_farm_id';

  static const String _cacheRole =
      'auth_profile_role';

  static const String _cacheIsActive =
      'auth_profile_is_active';

  // ============================================================
  // GET CURRENT FIREBASE USER
  // ============================================================

  User? get currentFirebaseUser =>
      _auth.currentUser;

  // ============================================================
  // GET CURRENT USER PROFILE
  // ============================================================

  Future<UserProfileModel?> getCurrentProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        'AuthProfileService: no authenticated user.',
      );

      return null;
    }

    // ----------------------------------------------------------
    // 1. TRY FIRESTORE
    // ----------------------------------------------------------

    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      if (snapshot.exists &&
          snapshot.data() != null) {
        final profile =
            UserProfileModel.fromMap(
          user.uid,
          snapshot.data()!,
        );

        await _cacheProfile(profile);

        debugPrint(
          'User profile loaded from Firestore: '
          '${profile.uid}',
        );

        return profile;
      }

      debugPrint(
        'User profile document not found for: '
        '${user.uid}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Firestore user profile read failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }

    // ----------------------------------------------------------
    // 2. FIRESTORE FAILED / DOCUMENT NOT FOUND
    //    TRY LOCAL CACHE
    // ----------------------------------------------------------

    final cachedProfile =
        await _getCachedProfile(
      firebaseUser: user,
    );

    if (cachedProfile != null) {
      debugPrint(
        'User profile loaded from local cache: '
        '${cachedProfile.uid}',
      );

      return cachedProfile;
    }

    debugPrint(
      'No local user profile cache available.',
    );

    return null;
  }

  // ============================================================
  // GET PROFILE FROM CACHE ONLY
  // ============================================================

  Future<UserProfileModel?> getCachedProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _getCachedProfile(
      firebaseUser: user,
    );
  }

  // ============================================================
  // SAVE / UPDATE PROFILE
  // ============================================================
  //
  // IMPORTANT:
  // This method does NOT automatically create a profile.
  //
  // User/Farm assignment must be explicitly controlled.
  // ============================================================

  Future<bool> saveProfile(
    UserProfileModel profile,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        'Cannot save profile: user is not authenticated.',
      );

      return false;
    }

    if (profile.uid != user.uid) {
      debugPrint(
        'Cannot save profile: UID mismatch.',
      );

      return false;
    }

    if (!profile.hasValidIdentity) {
      debugPrint(
        'Cannot save profile: invalid identity.',
      );

      return false;
    }

    if (!profile.hasValidFarm) {
      debugPrint(
        'Cannot save profile: farmId is empty.',
      );

      return false;
    }

    try {
      await _firestore
          .collection(_usersCollection)
          .doc(profile.uid)
          .set(
        profile.toMap(),
        SetOptions(
          merge: true,
        ),
      );

      await _cacheProfile(profile);

      debugPrint(
        'User profile saved successfully: '
        '${profile.uid}',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'User profile save failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ============================================================
  // CLEAR PROFILE
  // ============================================================

  Future<void> clearProfileCache() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove(_cacheUid);
      await prefs.remove(_cacheEmail);
      await prefs.remove(_cacheDisplayName);
      await prefs.remove(_cacheFarmId);
      await prefs.remove(_cacheRole);
      await prefs.remove(_cacheIsActive);

      debugPrint(
        'Auth profile cache cleared.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Auth profile cache clear failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // CACHE PROFILE
  // ============================================================

  Future<void> _cacheProfile(
    UserProfileModel profile,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _cacheUid,
      profile.uid,
    );

    await prefs.setString(
      _cacheEmail,
      profile.email,
    );

    await prefs.setString(
      _cacheDisplayName,
      profile.displayName,
    );

    await prefs.setString(
      _cacheFarmId,
      profile.farmId,
    );

    await prefs.setString(
      _cacheRole,
      profile.role,
    );

    await prefs.setBool(
      _cacheIsActive,
      profile.isActive,
    );
  }

  // ============================================================
  // READ CACHE
  // ============================================================

  Future<UserProfileModel?> _getCachedProfile({
    required User firebaseUser,
  }) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final uid =
          prefs.getString(_cacheUid);

      final email =
          prefs.getString(_cacheEmail);

      final displayName =
          prefs.getString(_cacheDisplayName);

      final farmId =
          prefs.getString(_cacheFarmId);

      final role =
          prefs.getString(_cacheRole);

      final isActive =
          prefs.getBool(_cacheIsActive);

      if (uid == null ||
          uid.trim().isEmpty ||
          uid != firebaseUser.uid) {
        return null;
      }

      if (farmId == null ||
          farmId.trim().isEmpty) {
        return null;
      }

      return UserProfileModel(
        uid: uid,
        email:
            email ??
            firebaseUser.email ??
            '',
        displayName:
            displayName ??
            firebaseUser.displayName ??
            '',
        farmId: farmId,
        role: role ?? 'staff',
        isActive:
            isActive ?? true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Reading cached user profile failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }
}