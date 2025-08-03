import '../../domain/entities/notification.dart';

/// Model للإشعار - للتحويل من وإلى قاعدة البيانات
class NotificationModel extends NotificationEntity {
  final String priority;
  final String category;
  final bool isArchived;
  final DateTime? readAt;
  final DateTime? scheduledFor;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final Map<String, dynamic>? richContent;

  const NotificationModel({
    required super.id,
    required super.parentId,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    super.relatedRequestId,
    required super.createdAt,
    required super.updatedAt,
    required this.priority,
    required this.category,
    required this.isArchived,
    this.readAt,
    this.scheduledFor,
    this.relatedEntityType,
    this.relatedEntityId,
    this.richContent,
  });

  /// تحويل من JSON إلى Model
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'] as String,
      parentId: json['recipient_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'system_announcement',
      priority: json['priority'] as String? ?? 'normal',
      category: json['category'] as String? ?? 'system',
      isRead: json['is_read'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      relatedRequestId: json['related_request_id'] as String?,
      relatedEntityType: json['related_entity_type'] as String?,
      relatedEntityId: json['related_entity_id'] as String?,
      richContent: json['rich_content'] != null
          ? Map<String, dynamic>.from(json['rich_content'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'] as String)
          : null,
    );
  }

  /// تحويل من Model إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'notification_id': id,
      'recipient_id': parentId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'category': category,
      'is_read': isRead,
      'is_archived': isArchived,
      'related_request_id': relatedRequestId,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
      'rich_content': richContent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'scheduled_for': scheduledFor?.toIso8601String(),
    };
  }

  /// تحويل من Entity إلى Model
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      parentId: entity.parentId,
      title: entity.title,
      message: entity.message,
      type: entity.type,
      priority: 'normal',
      category: 'system',
      isRead: entity.isRead,
      isArchived: false,
      relatedRequestId: entity.relatedRequestId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// نسخ مع تحديث
  @override
  NotificationModel copyWith({
    String? id,
    String? parentId,
    String? title,
    String? message,
    String? type,
    String? priority,
    String? category,
    bool? isRead,
    bool? isArchived,
    String? relatedRequestId,
    String? relatedEntityType,
    String? relatedEntityId,
    Map<String, dynamic>? richContent,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? readAt,
    DateTime? scheduledFor,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      relatedRequestId: relatedRequestId ?? this.relatedRequestId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      richContent: richContent ?? this.richContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readAt: readAt ?? this.readAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
    );
  }

  // خصائص مساعدة
  bool get isUrgent => priority == 'urgent';
  bool get isHigh => priority == 'high';
  bool get isBillingRelated => category == 'billing';
  bool get isSystemRelated => category == 'system';
  bool get hasActionButton => richContent?['action_button'] != null;

  String get priorityEmoji {
    switch (priority) {
      case 'urgent':
        return '🚨';
      case 'high':
        return '⚠️';
      case 'low':
        return '💙';
      default:
        return '📢';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case 'billing':
        return '💳';
      case 'registration':
        return '👶';
      case 'system':
        return '⚙️';
      case 'transport':
        return '🚌';
      default:
        return '📋';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}
