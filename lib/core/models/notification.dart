class NotificationModel {
  final String notificationId;
  final String? parentId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? relatedRequestId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.notificationId,
    this.parentId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.relatedRequestId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] as String,
      parentId: json['parent_id'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'info',
      isRead: json['is_read'] as bool? ?? false,
      relatedRequestId: json['related_request_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'parent_id': parentId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'related_request_id': relatedRequestId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? parentId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? relatedRequestId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedRequestId: relatedRequestId ?? this.relatedRequestId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  NotificationModel markAsRead() {
    return copyWith(isRead: true, updatedAt: DateTime.now());
  }

  @override
  String toString() {
    return 'NotificationModel(notificationId: $notificationId, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.notificationId == notificationId;
  }

  @override
  int get hashCode => notificationId.hashCode;
}
