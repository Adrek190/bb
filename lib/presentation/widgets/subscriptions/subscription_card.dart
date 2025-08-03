import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../data/models/subscription_model.dart';
import '../../../domain/entities/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final VoidCallback? onRenew;
  final VoidCallback? onCancel;
  final VoidCallback? onDetails;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onRenew,
    this.onCancel,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Child info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.childName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subscription.subscriptionTypeName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(), color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          subscription.subscriptionStatusName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Dates and amount
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          'تاريخ البداية',
                          subscription.formattedStartDate,
                          Icons.calendar_today,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'تاريخ الانتهاء',
                          subscription.formattedEndDate,
                          Icons.event,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          'المبلغ',
                          '${subscription.subscriptionAmount} ريال',
                          Icons.payments,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'الحالة',
                          _getRemainingTimeText(),
                          Icons.access_time,
                        ),
                      ),
                    ],
                  ),

                  // Progress bar for active subscriptions
                  if (subscription.subscriptionStatus ==
                      SubscriptionStatus.active) ...[
                    const SizedBox(height: 16),
                    _buildProgressIndicator(),
                  ],

                  // Renewal reminder for expiring subscriptions
                  if (subscription.isExpiringSoon) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ينتهي الاشتراك قريباً، يُنصح بالتجديد',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      if (subscription.isRenewable) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onRenew,
                            icon: const Icon(Icons.receipt_long, size: 18),
                            label: const Text('إنشاء فاتورة تجديد'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDetails,
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('التفاصيل'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      if (subscription.subscriptionStatus ==
                          SubscriptionStatus.active) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onCancel,
                          icon: const Icon(Icons.cancel_outlined),
                          color: Colors.red,
                          tooltip: 'إلغاء الاشتراك',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = subscription.subscriptionProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدم الاشتراك',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(progress),
          ),
          minHeight: 6,
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (subscription.subscriptionStatus) {
      case SubscriptionStatus.active:
        return subscription.isExpiringSoon ? Colors.orange : Colors.green;
      case SubscriptionStatus.expired:
        return Colors.red;
      case SubscriptionStatus.cancelled:
        return Colors.grey;
      case SubscriptionStatus.inactive:
        return Colors.grey;
      case SubscriptionStatus.suspended:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (subscription.subscriptionStatus) {
      case SubscriptionStatus.active:
        return subscription.isExpiringSoon ? Icons.warning : Icons.check_circle;
      case SubscriptionStatus.expired:
        return Icons.cancel;
      case SubscriptionStatus.cancelled:
        return Icons.block;
      case SubscriptionStatus.inactive:
        return Icons.pause_circle_outline;
      case SubscriptionStatus.suspended:
        return Icons.pause;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress > 0.7) return Colors.red;
    if (progress > 0.5) return Colors.orange;
    return AppColors.primary;
  }

  String _getRemainingTimeText() {
    final now = DateTime.now();
    final endDate = subscription.endDate;

    if (endDate.isBefore(now)) {
      final expired = now.difference(endDate).inDays;
      return 'انتهى منذ $expired يوم';
    } else {
      final remaining = endDate.difference(now).inDays;
      if (remaining == 0) {
        return 'ينتهي اليوم';
      } else if (remaining == 1) {
        return 'ينتهي غداً';
      } else {
        return 'باقي $remaining يوم';
      }
    }
  }
}
