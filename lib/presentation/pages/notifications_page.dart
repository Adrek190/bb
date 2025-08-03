import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';
import '../widgets/simple_notification_card.dart';
import '../../core/themes/app_colors.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  final VoidCallback? onNavigateToChildren;

  const NotificationsPage({super.key, this.onNavigateToChildren});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationsProvider>();
      // تعيين جميع الإشعارات كمقروءة عند دخول الصفحة
      provider.markAllAsRead();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'الإشعارات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 2,
          centerTitle: true,
          actions: [
            Consumer<NotificationsProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => provider.loadNotifications(),
                  tooltip: 'تحديث',
                );
              },
            ),
          ],
        ),
        body: Consumer<NotificationsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل الإشعارات...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (provider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'لا توجد إشعارات',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ستظهر الإشعارات الجديدة هنا',
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await provider.loadNotifications();
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return SimpleNotificationCard(
                    notification: notification,
                    onTap: () {
                      _handleNotificationTap(context, notification);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // التعامل مع النقر على الإشعار حسب نوعه
    switch (notification.type) {
      case 'bill_created':
      case 'bill_overdue':
      case 'payment_reminder':
        // الانتقال لصفحة الفواتير
        _navigateToBills(context);
        break;
      case 'bill_payment_confirmed':
      case 'bill_payment_rejected':
        // الانتقال لصفحة تاريخ المدفوعات في قسم الفواتير
        _navigateToBills(context);
        break;
      case 'child_request_submitted':
      case 'child_request_approved':
      case 'child_request_rejected':
        // الانتقال لصفحة الأطفال
        _navigateToChildren(context);
        break;
      case 'request_status_update':
        // الانتقال لصفحة الطلبات
        _navigateToRequests(context);
        break;
      default:
        // إظهار تفاصيل الإشعار
        _showNotificationDetails(context, notification);
    }
  }

  void _showNotificationDetails(
    BuildContext context,
    NotificationModel notification,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            if (notification.richContent != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (notification.richContent!['admin_note'] != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملاحظة الإدارة:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(notification.richContent!['admin_note']),
                    ],
                  ),
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          if (notification.richContent?['action_button'] != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleActionButton(
                  context,
                  notification.richContent!['action_button'],
                );
              },
              child: Text(notification.richContent!['action_button']['text']),
            ),
        ],
      ),
    );
  }

  void _handleActionButton(
    BuildContext context,
    Map<String, dynamic> actionButton,
  ) {
    final action = actionButton['action'];
    final data = actionButton['data'];

    switch (action) {
      case 'pay_bill':
        Navigator.pushNamed(
          context,
          '/bill_payment',
          arguments: data['bill_id'],
        );
        break;
      case 'view_request':
        Navigator.pushNamed(
          context,
          '/request_details',
          arguments: data['request_id'],
        );
        break;
      case 'start_using':
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('إجراء غير مدعوم: $action')));
    }
  }

  /// التنقل إلى صفحة الفواتير
  void _navigateToBills(BuildContext context) {
    Navigator.pushNamed(context, '/bills');
  }

  /// التنقل إلى صفحة الأطفال
  void _navigateToChildren(BuildContext context) {
    // استخدام callback إذا كان متوفراً
    if (widget.onNavigateToChildren != null) {
      Navigator.of(context).pop(); // إغلاق صفحة الإشعارات
      widget.onNavigateToChildren!(); // تغيير التبويب
    } else {
      // العودة للصفحة الرئيسية
      Navigator.of(context).popUntil((route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('انتقل إلى تبويب "الأبناء" لرؤية التفاصيل'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// التنقل إلى صفحة الطلبات
  void _navigateToRequests(BuildContext context) {
    Navigator.pushNamed(context, '/requests');
  }
}
