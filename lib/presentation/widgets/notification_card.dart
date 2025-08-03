import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool showActionButton;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.showActionButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: onDismiss != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: notification.isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getPriorityColor().withOpacity(0.3),
            width: notification.isRead ? 0.5 : 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: notification.isRead
                  ? Colors.white
                  : _getPriorityColor().withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildTitle(),
                const SizedBox(height: 6),
                _buildMessage(),
                if (notification.richContent != null) ...[
                  const SizedBox(height: 12),
                  _buildRichContent(),
                ],
                const SizedBox(height: 12),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // أيقونة الفئة
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _getPriorityColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              notification.categoryEmoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // نوع الإشعار والأولوية
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getTypeDisplayName(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    notification.priorityEmoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Text(
                notification.timeAgo,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // حالة القراءة
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getPriorityColor(),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      notification.title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
        color: notification.isRead ? Colors.grey[800] : Colors.black,
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      notification.message,
      style: TextStyle(
        fontSize: 14,
        color: notification.isRead ? Colors.grey[600] : Colors.grey[700],
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRichContent() {
    final richContent = notification.richContent!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات إضافية
          if (richContent['amount'] != null)
            _buildInfoRow('المبلغ', '${richContent['amount']} ريال'),

          if (richContent['due_date'] != null)
            _buildInfoRow(
              'تاريخ الاستحقاق',
              _formatDate(richContent['due_date']),
            ),

          if (richContent['days_overdue'] != null)
            _buildInfoRow(
              'أيام التأخير',
              '${richContent['days_overdue']} أيام',
              isWarning: true,
            ),

          // ملاحظة الإدارة
          if (richContent['admin_note'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظة الإدارة:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    richContent['admin_note'],
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ],

          // زر الإجراء
          if (showActionButton && richContent['action_button'] != null) ...[
            const SizedBox(height: 12),
            _buildActionButton(richContent['action_button']),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.orange[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> actionButton) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // سيتم التعامل مع الإجراء في الصفحة الرئيسية
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _getPriorityColor(),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(_getActionIcon(actionButton['action']), size: 18),
        label: Text(
          actionButton['text'] ?? 'إجراء',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // الفئة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getCategoryDisplayName(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getCategoryColor(),
            ),
          ),
        ),

        // حالة الإشعار
        if (notification.isArchived)
          const Icon(Icons.archive, size: 16, color: Colors.grey)
        else if (notification.scheduledFor != null &&
            notification.scheduledFor!.isAfter(DateTime.now()))
          const Icon(Icons.schedule, size: 16, color: Colors.orange),
      ],
    );
  }

  Color _getPriorityColor() {
    switch (notification.priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  Color _getCategoryColor() {
    switch (notification.category) {
      case 'billing':
        return Colors.purple;
      case 'registration':
        return Colors.teal;
      case 'transport':
        return Colors.amber;
      case 'system':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDisplayName() {
    switch (notification.type) {
      case 'bill_created':
        return 'فاتورة جديدة';
      case 'bill_overdue':
        return 'فاتورة متأخرة';
      case 'bill_payment_confirmed':
        return 'تأكيد الدفع';
      case 'bill_payment_rejected':
        return 'رفض الدفع';
      case 'child_request_submitted':
        return 'طلب طفل';
      case 'child_request_approved':
        return 'قبول الطلب';
      case 'child_request_rejected':
        return 'رفض الطلب';
      case 'payment_reminder':
        return 'تذكير دفع';
      case 'system_announcement':
        return 'إعلان النظام';
      case 'maintenance_notice':
        return 'إشعار صيانة';
      case 'welcome_message':
        return 'رسالة ترحيب';
      case 'urgent_notice':
        return 'إشعار عاجل';
      default:
        return 'إشعار';
    }
  }

  String _getCategoryDisplayName() {
    switch (notification.category) {
      case 'billing':
        return 'الفواتير';
      case 'registration':
        return 'التسجيل';
      case 'transport':
        return 'النقل';
      case 'system':
        return 'النظام';
      default:
        return 'عام';
    }
  }

  IconData _getActionIcon(String? action) {
    switch (action) {
      case 'pay_bill':
        return Icons.payment;
      case 'view_request':
        return Icons.visibility;
      case 'start_using':
        return Icons.play_arrow;
      case 'resubmit_request':
        return Icons.refresh;
      default:
        return Icons.arrow_forward;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
