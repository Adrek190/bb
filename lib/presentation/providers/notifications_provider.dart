import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification.dart';
import '../../data/models/notification_model.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Provider for managing notifications with real-time updates
///
/// Features:
/// - Real-time notifications from Supabase
/// - Mark notifications as read/unread
/// - Filter by notification type and category
/// - Auto-refresh capabilities
/// - Rich content support
/// - Priority-based filtering
class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository _notificationsRepository;
  final SupabaseClient _supabaseClient;

  NotificationsProvider(
    this._notificationsRepository, {
    SupabaseClient? supabaseClient,
  }) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // State
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Map<String, dynamic>>>? _realTimeSubscription;
  DateTime? _lastUpdate;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get allNotifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;

  // Computed properties
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  List<NotificationModel> get urgentNotifications =>
      _notifications.where((n) => n.isUrgent).toList();

  List<NotificationModel> get paymentNotifications =>
      _notifications.where((n) => n.isBillingRelated).toList();

  bool get hasNotifications => _notifications.isNotEmpty;

  /// Initialize provider and start real-time listening
  Future<void> initialize() async {
    await loadNotifications();
    _setupRealTimeListener();
  }

  /// Load all notifications for current user
  Future<void> loadNotifications({
    bool forceRefresh = false,
    String? category,
    String? priority,
    String? type,
    bool? unreadOnly,
    int limit = 50,
  }) async {
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    _clearError();

    try {
      _notifications = await _notificationsRepository.getUserNotifications(
        category: category,
        priority: priority,
        type: type,
        unreadOnly: unreadOnly,
        limit: limit,
      );
      _lastUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _notificationsRepository.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      await _notificationsRepository.markAllAsRead();

      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _notificationsRepository.deleteNotification(notificationId);

      // Remove from local state
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  /// Dismiss notification (remove from UI without server call)
  Future<void> dismissNotification(String notificationId) async {
    try {
      // Remove from local state immediately
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      // Optionally, you can add a server call here later
      // await _notificationsRepository.hideNotification(notificationId);
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }

  /// Get notifications by type
  List<NotificationEntity> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get recent notifications (last 7 days)
  List<NotificationEntity> getRecentNotifications() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications.where((n) => n.createdAt.isAfter(weekAgo)).toList();
  }

  /// Filter notifications by date range
  List<NotificationEntity> getNotificationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _notifications.where((n) {
      return n.createdAt.isAfter(startDate) && n.createdAt.isBefore(endDate);
    }).toList();
  }

  /// Search notifications by title or message
  List<NotificationEntity> searchNotifications(String query) {
    if (query.isEmpty) return _notifications;

    final lowerQuery = query.toLowerCase();
    return _notifications.where((n) {
      return n.title.toLowerCase().contains(lowerQuery) ||
          n.message.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Create notification when request status changes
  Future<void> createRequestStatusNotification(
    String requestId,
    String status,
  ) async {
    try {
      String title = '';
      String message = '';
      String type = 'info';

      switch (status) {
        case 'approved':
          title = 'تم قبول طلبك ✅';
          message = 'تم قبول طلب إضافة طفل جديد للنقل المدرسي';
          type = 'success';
          break;
        case 'rejected':
          title = 'تم رفض طلبك ❌';
          message = 'تم رفض طلب إضافة طفل جديد. يرجى مراجعة البيانات';
          type = 'warning';
          break;
        case 'pending':
          title = 'طلب قيد المراجعة ⏳';
          message = 'طلبك قيد المراجعة من قبل الإدارة';
          type = 'info';
          break;
        default:
          title = 'تحديث في طلبك';
          message = 'تم تحديث حالة طلب النقل المدرسي';
          type = 'info';
      }

      // Create notification through repository
      // Note: createNotification method needs to be added to repository
      // For now, we'll simulate the creation by adding to local state
      final newNotification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        parentId: _supabaseClient.auth.currentUser?.id ?? '',
        title: title,
        message: message,
        type: type,
        priority: 'normal',
        category: 'system',
        isRead: false,
        isArchived: false,
        relatedRequestId: requestId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to local state
      _notifications.insert(0, newNotification);
      notifyListeners();

      // TODO: Implement actual API call when repository method is available
      // await _notificationsRepository.createNotification(...)
    } catch (e) {
      // Silent fail - don't disrupt the main flow
      debugPrint('Failed to create notification: $e');
    }
  }

  /// Setup real-time listener for notifications
  void _setupRealTimeListener() {
    try {
      final currentUserId = _supabaseClient.auth.currentUser?.id;
      if (currentUserId == null) {
        debugPrint('No authenticated user for real-time notifications');
        return;
      }

      _realTimeSubscription = _supabaseClient
          .from('notifications')
          .stream(primaryKey: ['notification_id'])
          .eq('recipient_id', currentUserId)
          .listen(
            (data) {
              _handleRealTimeUpdate(data);
            },
            onError: (error) {
              debugPrint('Real-time notification error: $error');
            },
          );
    } catch (e) {
      debugPrint('Failed to setup real-time listener: $e');
    }
  }

  /// Handle real-time updates from Supabase
  void _handleRealTimeUpdate(List<Map<String, dynamic>> data) {
    try {
      // Convert to models
      final newNotifications =
          data
              .map((json) => _mapJsonToNotification(json))
              .where((notification) => notification != null)
              .cast<NotificationModel>()
              .toList()
            ..sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            ); // Sort by newest first

      // Update local state
      _notifications = newNotifications;
      _lastUpdate = DateTime.now();

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to handle real-time update: $e');
    }
  }

  /// Map JSON to NotificationModel
  NotificationModel? _mapJsonToNotification(Map<String, dynamic> json) {
    try {
      return NotificationModel.fromJson(json);
    } catch (e) {
      debugPrint('Failed to map notification JSON: $e');
      return null;
    }
  }

  /// Refresh data (pull-to-refresh)
  Future<void> refresh() async {
    await loadNotifications(forceRefresh: true);
  }

  /// Clear all notifications (local only)
  void clear() {
    _notifications.clear();
    _lastUpdate = null;
    _clearError();
    notifyListeners();
  }

  /// Auto-mark notifications as read when viewed
  void markNotificationAsViewed(String notificationId) {
    final notification = _notifications
        .where((n) => n.id == notificationId)
        .firstOrNull;

    if (notification != null && !notification.isRead) {
      // Mark as read in background
      markAsRead(notificationId);
    }
  }

  /// Get notification statistics
  Map<String, int> get statistics {
    return {
      'total': _notifications.length,
      'unread': unreadCount,
      'read': readNotifications.length,
      'success': getNotificationsByType('success').length,
      'warning': getNotificationsByType('warning').length,
      'info': getNotificationsByType('info').length,
      'error': getNotificationsByType('error').length,
    };
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'حدث خطأ غير متوقع: ${error.toString()}';
  }

  @override
  void dispose() {
    _realTimeSubscription?.cancel();
    super.dispose();
  }
}
