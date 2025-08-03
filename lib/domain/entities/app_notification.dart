enum NotificationType {
  requestSubmitted, // طلب مُرسل
  requestApproved, // طلب مقبول
  requestRejected, // طلب مرفوض
  general, // عام
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.requestSubmitted:
        return 'طلب جديد';
      case NotificationType.requestApproved:
        return 'طلب مقبول';
      case NotificationType.requestRejected:
        return 'طلب مرفوض';
      case NotificationType.general:
        return 'إشعار عام';
    }
  }

  String get typeKey {
    switch (this) {
      case NotificationType.requestSubmitted:
        return 'request_submitted';
      case NotificationType.requestApproved:
        return 'request_approved';
      case NotificationType.requestRejected:
        return 'request_rejected';
      case NotificationType.general:
        return 'general';
    }
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedId; // معرف الطلب المرتبط

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.relatedId,
  });

  // تحويل إلى Map للحفظ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.typeKey,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'relatedId': relatedId,
    };
  }

  // إنشاء من Map للاستراد
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: _typeFromString(map['type'] ?? 'general'),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: map['isRead'] ?? false,
      relatedId: map['relatedId'],
    );
  }

  static NotificationType _typeFromString(String type) {
    switch (type) {
      case 'request_submitted':
        return NotificationType.requestSubmitted;
      case 'request_approved':
        return NotificationType.requestApproved;
      case 'request_rejected':
        return NotificationType.requestRejected;
      case 'general':
      default:
        return NotificationType.general;
    }
  }

  // إنشاء نسخة مع تعديلات
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  @override
  String toString() {
    return 'AppNotification{id: $id, title: $title, type: $type, isRead: $isRead}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
