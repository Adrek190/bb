import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../core/themes/app_colors.dart';

class SimpleNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const SimpleNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? Colors.grey[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead
              ? Colors.grey[300]!
              : AppColors.primary.withOpacity(0.2),
          width: notification.isRead ? 0.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة الإشعار
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getNotificationColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getNotificationIcon(),
                  color: _getNotificationColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // محتوى الإشعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: notification.isRead
                                  ? Colors.grey[700]
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        // نقطة للإشعارات غير المقروءة
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.isRead
                            ? Colors.grey[600]
                            : Colors.grey[800],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTimeAgo(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (notification.priority == 'urgent')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'عاجل',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // تحديد أيقونة الإشعار حسب النوع
  IconData _getNotificationIcon() {
    switch (notification.type) {
      case 'bill_created':
      case 'bill_overdue':
      case 'payment_reminder':
        return Icons.receipt_long;
      case 'bill_payment_confirmed':
        return Icons.check_circle;
      case 'bill_payment_rejected':
        return Icons.error;
      case 'child_request_submitted':
        return Icons.person_add;
      case 'child_request_approved':
        return Icons.verified;
      case 'child_request_rejected':
        return Icons.cancel;
      case 'transport_update':
        return Icons.directions_bus;
      case 'announcement':
        return Icons.campaign;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  // تحديد لون الإشعار حسب النوع والأولوية
  Color _getNotificationColor() {
    if (notification.priority == 'urgent') {
      return Colors.red;
    }

    switch (notification.type) {
      case 'bill_created':
      case 'bill_overdue':
      case 'payment_reminder':
        return Colors.orange;
      case 'bill_payment_confirmed':
      case 'child_request_approved':
        return Colors.green;
      case 'bill_payment_rejected':
      case 'child_request_rejected':
        return Colors.red;
      case 'child_request_submitted':
        return Colors.blue;
      case 'transport_update':
        return Colors.purple;
      case 'announcement':
        return Colors.indigo;
      case 'system':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  // تحويل الوقت إلى نص قابل للقراءة
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
