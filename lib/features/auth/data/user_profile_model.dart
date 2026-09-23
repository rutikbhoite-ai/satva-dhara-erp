class UserProfileModel {
  final String uid;
  final String email;
  final String displayName;
  final String farmId;
  final String role;
  final bool isActive;

  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.farmId,
    required this.role,
    required this.isActive,
  });

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory UserProfileModel.fromMap(
    String uid,
    Map<String, dynamic> data,
  ) {
    return UserProfileModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName:
          data['displayName'] as String? ?? '',
      farmId:
          data['farmId'] as String? ?? '',
      role:
          data['role'] as String? ?? 'staff',
      isActive:
          data['isActive'] as bool? ?? true,
    );
  }

  // ============================================================
  // TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'farmId': farmId,
      'role': role,
      'isActive': isActive,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? farmId,
    String? role,
    bool? isActive,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName:
          displayName ?? this.displayName,
      farmId: farmId ?? this.farmId,
      role: role ?? this.role,
      isActive:
          isActive ?? this.isActive,
    );
  }

  // ============================================================
  // ROLE HELPERS
  // ============================================================

  bool get isOwner =>
      role.toLowerCase() == 'owner';

  bool get isAdmin =>
      role.toLowerCase() == 'admin' ||
      isOwner;

  bool get isManager =>
      role.toLowerCase() == 'manager' ||
      isAdmin;

  bool get isStaff =>
      role.toLowerCase() == 'staff';

  // ============================================================
  // VALIDATION
  // ============================================================

  bool get hasValidFarm =>
      farmId.trim().isNotEmpty;

  bool get hasValidIdentity =>
      uid.trim().isNotEmpty &&
      email.trim().isNotEmpty;

  bool get canUseApplication =>
      isActive &&
      hasValidIdentity &&
      hasValidFarm;

  @override
  String toString() {
    return 'UserProfileModel('
        'uid: $uid, '
        'email: $email, '
        'displayName: $displayName, '
        'farmId: $farmId, '
        'role: $role, '
        'isActive: $isActive'
        ')';
  }
}