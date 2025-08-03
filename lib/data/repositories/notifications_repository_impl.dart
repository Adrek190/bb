import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../models/notification_model.dart';

/// تنفيذ Repository للإشعارات باستخدام Supabase
class NotificationsRepositoryImpl implements NotificationsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamController<List<NotificationModel>>? _notificationsController;

  /// الحصول على parent_id للمستخدم الحالي
  Future<String?> get _currentParentId async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('parents')
          .select('parent_id')
          .eq('auth_id', user.id)
          .single();

      return response['parent_id'] as String?;
    } catch (e) {
      print('خطأ في جلب parent_id: $e');
      return null;
    }
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) return [];

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('recipient_id', parentId)
          .order('created_at', ascending: false);

      return response
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('خطأ في جلب الإشعارات: $e');
      return [];
    }
  }

  @override
  Future<List<NotificationModel>> getUserNotifications({
    String? category,
    String? priority,
    String? type,
    bool? unreadOnly,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) return [];

      var query = _supabase
          .from('notifications')
          .select()
          .eq('recipient_id', parentId);

      // Apply filters
      if (category != null) {
        query = query.eq('category', category);
      }
      if (priority != null) {
        query = query.eq('priority', priority);
      }
      if (type != null) {
        query = query.eq('type', type);
      }
      if (unreadOnly == true) {
        query = query.eq('is_read', false);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      return response
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('خطأ في جلب الإشعارات المفلترة: $e');
      return [];
    }
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) return [];

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('recipient_id', parentId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return response
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('خطأ في جلب الإشعارات غير المقروءة: $e');
      return [];
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select('notification_id')
          .eq('recipient_id', parentId)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      print('خطأ في عد الإشعارات غير المقروءة: $e');
      return 0;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('notification_id', notificationId);
    } catch (e) {
      print('خطأ في تحديد الإشعار كمقروء: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) return;

      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('recipient_id', parentId)
          .eq('is_read', false);
    } catch (e) {
      print('خطأ في تحديد جميع الإشعارات كمقروءة: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('notification_id', notificationId);
    } catch (e) {
      print('خطأ في حذف الإشعار: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) return;

      await _supabase
          .from('notifications')
          .delete()
          .eq('recipient_id', parentId);
    } catch (e) {
      print('خطأ في حذف جميع الإشعارات: $e');
      rethrow;
    }
  }

  @override
  Stream<List<NotificationModel>> get notificationsStream {
    _notificationsController ??=
        StreamController<List<NotificationModel>>.broadcast();

    // إعداد Real-time subscription
    _setupRealtimeSubscription();

    return _notificationsController!.stream;
  }

  /// إعداد الاستماع للتحديثات المباشرة
  void _setupRealtimeSubscription() async {
    final parentId = await _currentParentId;
    if (parentId == null) return;

    _supabase
        .from('notifications')
        .stream(primaryKey: ['notification_id'])
        .eq('recipient_id', parentId)
        .order('created_at', ascending: false)
        .listen((data) {
          final notifications = data
              .map<NotificationModel>(
                (json) => NotificationModel.fromJson(json),
              )
              .toList();
          _notificationsController?.add(notifications);
        });
  }

  /// تنظيف الموارد
  void dispose() {
    _notificationsController?.close();
    _notificationsController = null;
  }
}
