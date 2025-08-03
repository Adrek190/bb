import '../../data/models/notification_model.dart';

/// Repository للتعامل مع الإشعارات
abstract class NotificationsRepository {
  /// جلب جميع إشعارات المستخدم الحالي
  Future<List<NotificationModel>> getNotifications();

  /// جلب إشعارات المستخدم مع خيارات التصفية
  Future<List<NotificationModel>> getUserNotifications({
    String? category,
    String? priority,
    String? type,
    bool? unreadOnly,
    int limit = 50,
    int offset = 0,
  });

  /// جلب الإشعارات غير المقروءة
  Future<List<NotificationModel>> getUnreadNotifications();

  /// عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount();

  /// تحديد إشعار كمقروء
  Future<void> markAsRead(String notificationId);

  /// تحديد جميع الإشعارات كمقروءة
  Future<void> markAllAsRead();

  /// حذف إشعار
  Future<void> deleteNotification(String notificationId);

  /// حذف جميع الإشعارات
  Future<void> deleteAllNotifications();

  /// الاستماع للإشعارات الجديدة (Real-time)
  Stream<List<NotificationModel>> get notificationsStream;
}
