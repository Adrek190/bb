/// نموذج الوالد - يطابق جدول parents
class Parent {
  final String parentId;
  final String parentName;
  final String phone;
  final String? email;
  final String? profileImageUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String? authId;

  const Parent({
    required this.parentId,
    required this.parentName,
    required this.phone,
    this.email,
    this.profileImageUrl,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    required this.isActive,
    this.authId,
  });

  /// إنشاء من Map (من قاعدة البيانات)
  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      parentId: json['parent_id'] as String,
      parentName: json['parent_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      authId: json['auth_id'] as String?,
    );
  }

  /// تحويل إلى Map (للحفظ في قاعدة البيانات)
  Map<String, dynamic> toJson() {
    return {
      'parent_id': parentId,
      'parent_name': parentName,
      'phone': phone,
      'email': email,
      'profile_image_url': profileImageUrl,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'auth_id': authId,
    };
  }

  /// نسخ الكائن مع تحديث بعض الخصائص
  Parent copyWith({
    String? parentId,
    String? parentName,
    String? phone,
    String? email,
    String? profileImageUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    bool? isActive,
    String? authId,
  }) {
    return Parent(
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      authId: authId ?? this.authId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Parent && other.parentId == parentId;
  }

  @override
  int get hashCode => parentId.hashCode;

  @override
  String toString() {
    return 'Parent(parentId: $parentId, parentName: $parentName, phone: $phone)';
  }
}
