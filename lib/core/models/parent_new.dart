class Parent {
  final String parentId;
  final String parentName;
  final String phone;
  final String? email;
  final String passwordHash;
  final bool isVerified;
  final String? verificationToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String? authId;
  final String? profileImageUrl;

  const Parent({
    required this.parentId,
    required this.parentName,
    required this.phone,
    this.email,
    required this.passwordHash,
    required this.isVerified,
    this.verificationToken,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    required this.isActive,
    this.authId,
    this.profileImageUrl,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      parentId: json['parent_id'] as String,
      parentName: json['parent_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      passwordHash: json['password_hash'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      verificationToken: json['verification_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      authId: json['auth_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parent_id': parentId,
      'parent_name': parentName,
      'phone': phone,
      'email': email,
      'password_hash': passwordHash,
      'is_verified': isVerified,
      'verification_token': verificationToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'auth_id': authId,
      'profile_image_url': profileImageUrl,
    };
  }

  Parent copyWith({
    String? parentId,
    String? parentName,
    String? phone,
    String? email,
    String? passwordHash,
    bool? isVerified,
    String? verificationToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    bool? isActive,
    String? authId,
    String? profileImageUrl,
  }) {
    return Parent(
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      isVerified: isVerified ?? this.isVerified,
      verificationToken: verificationToken ?? this.verificationToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      authId: authId ?? this.authId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'Parent(parentId: $parentId, parentName: $parentName, phone: $phone, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Parent && other.parentId == parentId;
  }

  @override
  int get hashCode => parentId.hashCode;
}
