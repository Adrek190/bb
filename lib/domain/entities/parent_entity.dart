/// Parent entity من جدول parents في قاعدة البيانات
class ParentEntity {
  final String parentId;
  final String parentName;
  final String phone;
  final String? email;
  final bool isVerified;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String? authId;

  const ParentEntity({
    required this.parentId,
    required this.parentName,
    required this.phone,
    this.email,
    required this.isVerified,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLogin,
    required this.isActive,
    this.authId,
  });

  /// إنشاء من JSON
  factory ParentEntity.fromJson(Map<String, dynamic> json) {
    return ParentEntity(
      parentId: json['parent_id'] as String,
      parentName: json['parent_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      authId: json['auth_id'] as String?,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'parent_id': parentId,
      'parent_name': parentName,
      'phone': phone,
      'email': email,
      'is_verified': isVerified,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'auth_id': authId,
    };
  }

  /// نسخ مع تحديث بعض الخصائص
  ParentEntity copyWith({
    String? parentId,
    String? parentName,
    String? phone,
    String? email,
    bool? isVerified,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    String? authId,
  }) {
    return ParentEntity(
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      authId: authId ?? this.authId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParentEntity && other.parentId == parentId;
  }

  @override
  int get hashCode => parentId.hashCode;

  @override
  String toString() {
    return 'ParentEntity(parentId: $parentId, parentName: $parentName, phone: $phone)';
  }
}
