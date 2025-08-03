import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscriptions_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/subscriptions/subscription_card.dart';
import '../widgets/subscriptions/subscriptions_filter_tabs.dart';
import '../widgets/subscriptions/subscriptions_stats_card.dart';
import '../widgets/shared/empty_state_widget.dart';
import '../widgets/shared/error_widget.dart';
import '../widgets/shared/loading_widget.dart';
import '../../core/themes/app_colors.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptions() async {
    if (!_isInitialized) {
      final provider = Provider.of<SubscriptionsProvider>(
        context,
        listen: false,
      );
      // TODO: استبدال هذا بمعرف المستخدم الحقيقي من نظام المصادقة
      await provider.loadUserSubscriptions('parent_123');
      _isInitialized = true;
    }
  }

  Future<void> _refreshSubscriptions() async {
    final provider = Provider.of<SubscriptionsProvider>(context, listen: false);
    await provider.refreshSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'الاشتراكات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _refreshSubscriptions,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث الاشتراكات',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<SubscriptionsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasSubscriptions) {
            return const LoadingWidget(message: 'جاري تحميل الاشتراكات...');
          }

          if (provider.hasError) {
            return CustomErrorWidget(
              message: provider.error!,
              onRetry: _refreshSubscriptions,
            );
          }

          if (!provider.hasSubscriptions) {
            return const EmptyStateWidget(
              icon: Icons.subscriptions_outlined,
              title: 'لا توجد اشتراكات',
              subtitle: 'لم يتم العثور على أي اشتراكات',
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshSubscriptions,
            child: Column(
              children: [
                // إحصائيات الاشتراكات
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SubscriptionsStatsCard(
                    totalActive: provider.totalActiveSubscriptions,
                    totalExpired: provider.totalExpiredSubscriptions,
                    totalExpiringSoon: provider.totalExpiringSoonSubscriptions,
                    totalValue: provider.totalSubscriptionValue,
                  ),
                ),

                // تبويبات التصفية
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: SubscriptionsFilterTabs(
                    tabController: _tabController,
                    activeCount: provider.totalActiveSubscriptions,
                    expiredCount: provider.totalExpiredSubscriptions,
                    expiringSoonCount: provider.totalExpiringSoonSubscriptions,
                  ),
                ),

                const SizedBox(height: 16),

                // قائمة الاشتراكات
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // الاشتراكات النشطة
                      _buildSubscriptionsList(
                        subscriptions: provider.activeSubscriptions,
                        emptyMessage: 'لا توجد اشتراكات نشطة',
                        emptyIcon: Icons.subscriptions_outlined,
                      ),

                      // الاشتراكات المنتهية
                      _buildSubscriptionsList(
                        subscriptions: provider.expiredSubscriptions,
                        emptyMessage: 'لا توجد اشتراكات منتهية',
                        emptyIcon: Icons.schedule_outlined,
                      ),

                      // الاشتراكات القريبة من الانتهاء
                      _buildSubscriptionsList(
                        subscriptions: provider.expiringSoonSubscriptions,
                        emptyMessage: 'لا توجد اشتراكات قريبة من الانتهاء',
                        emptyIcon: Icons.warning_amber_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionsList({
    required List subscriptions,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (subscriptions.isEmpty) {
      return EmptyStateWidget(
        icon: emptyIcon,
        title: emptyMessage,
        subtitle: 'سيتم عرض الاشتراكات هنا عندما تصبح متاحة',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: SubscriptionCard(
            subscription: subscription,
            onRenew: () => _showRenewalDialog(subscription),
            onCancel: () => _showCancelDialog(subscription),
            onDetails: () => _showSubscriptionDetails(subscription),
          ),
        );
      },
    );
  }

  void _showRenewalDialog(dynamic subscription) {
    SubscriptionType selectedType = SubscriptionType.monthly;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.refresh, color: AppColors.primary),
              SizedBox(width: 8),
              Text('تجديد الاشتراك'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر نوع التجديد للطفل: ${subscription.childName ?? 'غير محدد'}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text('سيتم إنشاء فاتورة جديدة للتجديد:'),
              const SizedBox(height: 8),
              RadioListTile<SubscriptionType>(
                title: const Text('شهري - 750 ريال'),
                subtitle: const Text('تجديد لمدة شهر واحد'),
                value: SubscriptionType.monthly,
                groupValue: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              RadioListTile<SubscriptionType>(
                title: const Text('ترم - 4500 ريال'),
                subtitle: const Text('تجديد لمدة 6 أشهر'),
                value: SubscriptionType.term,
                groupValue: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              RadioListTile<SubscriptionType>(
                title: const Text('سنوي - 9000 ريال'),
                subtitle: const Text('تجديد لمدة 12 شهر'),
                value: SubscriptionType.yearly,
                groupValue: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final provider = Provider.of<SubscriptionsProvider>(
                  context,
                  listen: false,
                );

                // إنشاء فاتورة تجديد بدلاً من التجديد المباشر
                final result = await provider.createRenewalBillWithType(
                  subscription.subscriptionId,
                  selectedType,
                );

                if (mounted) {
                  if (result != null && result['success'] == true) {
                    // عرض رسالة نجاح مع تفاصيل الفاتورة
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم إنشاء فاتورة التجديد بنجاح\n'
                          'رقم الفاتورة: ${result['bill_number']}\n'
                          'المبلغ: ${result['amount']} ريال',
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                        action: SnackBarAction(
                          label: 'عرض الفاتورة',
                          textColor: Colors.white,
                          onPressed: () {
                            // TODO: انتقال لصفحة الفواتير أو عرض تفاصيل الفاتورة
                          },
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result?['message'] ?? 'فشل في إنشاء فاتورة التجديد',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('إنشاء فاتورة التجديد'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(dynamic subscription) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'إلغاء الاشتراك',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل تريد إلغاء اشتراك ${subscription.childName}؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الإلغاء (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final provider = Provider.of<SubscriptionsProvider>(
                context,
                listen: false,
              );
              final success = await provider.cancelSubscription(
                subscription.subscriptionId,
                reasonController.text.trim(),
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'تم إلغاء الاشتراك' : 'فشل في إلغاء الاشتراك',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('إلغاء الاشتراك'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDetails(dynamic subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تفاصيل اشتراك ${subscription.childName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'نوع الاشتراك:',
                subscription.subscriptionTypeName,
              ),
              _buildDetailRow('الحالة:', subscription.subscriptionStatusName),
              _buildDetailRow(
                'تاريخ البداية:',
                subscription.formattedStartDate,
              ),
              _buildDetailRow('تاريخ الانتهاء:', subscription.formattedEndDate),
              _buildDetailRow(
                'المبلغ:',
                '${subscription.subscriptionAmount} ريال',
              ),
              _buildDetailRow(
                'المبلغ المدفوع:',
                '${subscription.paidAmount} ريال',
              ),
              if (subscription.adminNotes?.isNotEmpty == true)
                _buildDetailRow('ملاحظات:', subscription.adminNotes!),
              _buildDetailRow(
                'التجديد التلقائي:',
                subscription.autoRenewal ? 'مفعل' : 'غير مفعل',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
