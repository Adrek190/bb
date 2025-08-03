/// كائن الإشعار
class NotificationEntity {
  final String id;
  final String parentId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? relatedRequestId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationEntity({
    required this.id,
    required this.parentId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.relatedRequestId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// نسخ الكائن مع تحديث بعض الخصائص
  NotificationEntity copyWith({
    String? id,
    String? parentId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? relatedRequestId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationEntity(id: $id, title: $title, type: $type, isRead: $isRead)';
  }
}
