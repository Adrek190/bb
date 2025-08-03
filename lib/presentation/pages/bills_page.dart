// lib/presentation/pages/bills_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bills_provider.dart';
import '../widgets/app_drawer.dart';

/// صفحة إدارة الفواتير
class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // استدعاء البيانات عند تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBillsData();
    });
  }

  void _loadBillsData() async {
    final billsProvider = Provider.of<BillsProvider>(context, listen: false);
    await billsProvider.loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفواتير'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'الفواتير الفردية', icon: Icon(Icons.receipt)),
            Tab(
              text: 'الفواتير المُجمعة',
              icon: Icon(Icons.featured_play_list),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(), // إضافة القائمة الجانبية
      body: TabBarView(
        controller: _tabController,
        children: [_IndividualBillsTab(), _BatchBillsTab()],
      ),
      floatingActionButton: Consumer<BillsProvider>(
        builder: (context, billsProvider, child) {
          final hasSelectedBills = billsProvider.selectedBills.isNotEmpty;

          return FloatingActionButton.extended(
            onPressed: hasSelectedBills ? _showBatchPaymentDialog : null,
            backgroundColor: hasSelectedBills
                ? Theme.of(context).primaryColor
                : Colors.grey,
            icon: const Icon(Icons.payment, color: Colors.white),
            label: Text(
              hasSelectedBills
                  ? 'دفع مُجمع (${billsProvider.selectedBills.length})'
                  : 'اختر فواتير للدفع',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  void _showBatchPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => const BatchPaymentDialog(),
    );
  }
}

/// تبويب الفواتير الفردية
class _IndividualBillsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BillsProvider>(
      builder: (context, billsProvider, child) {
        if (billsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (billsProvider.bills.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا توجد فواتير متاحة',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: billsProvider.bills.length,
          itemBuilder: (context, index) {
            final bill = billsProvider.bills[index];
            return _BillCard(bill: bill);
          },
        );
      },
    );
  }
}

/// تبويب الفواتير المُجمعة
class _BatchBillsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BillsProvider>(
      builder: (context, billsProvider, child) {
        if (billsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (billsProvider.batchBills.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.featured_play_list, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا توجد فواتير مُجمعة',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: billsProvider.batchBills.length,
          itemBuilder: (context, index) {
            final batchBill = billsProvider.batchBills[index];
            return _BatchBillCard(batchBill: batchBill);
          },
        );
      },
    );
  }
}

/// بطاقة الفاتورة الفردية
class _BillCard extends StatelessWidget {
  final dynamic bill; // Using dynamic for now until we import the entities

  const _BillCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Consumer<BillsProvider>(
        builder: (context, billsProvider, child) {
          final isSelected = billsProvider.selectedBills.contains(bill);

          return InkWell(
            onTap: () => billsProvider.toggleBillSelection(bill),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bill.billNumber ?? 'فاتورة',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bill.billDescription ?? 'وصف الفاتورة',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${bill.amount?.toStringAsFixed(2) ?? '0.00'} ر.س',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      _buildStatusChip(bill.status),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(dynamic status) {
    String statusText;
    Color statusColor;

    // Handle status based on its type
    if (status.toString() == 'BillStatus.pending') {
      statusText = 'معلقة';
      statusColor = Colors.orange;
    } else if (status.toString() == 'BillStatus.underReview') {
      statusText = 'تحت المراجعة';
      statusColor = Colors.blue;
    } else if (status.toString() == 'BillStatus.paid') {
      statusText = 'مدفوعة';
      statusColor = Colors.green;
    } else if (status.toString() == 'BillStatus.rejected') {
      statusText = 'مرفوضة';
      statusColor = Colors.red;
    } else if (status.toString() == 'BillStatus.cancelled') {
      statusText = 'ملغاة';
      statusColor = Colors.grey;
    } else if (status.toString() == 'BillStatus.overdue') {
      statusText = 'متأخرة';
      statusColor = Colors.deepOrange;
    } else {
      statusText = 'غير معروف';
      statusColor = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// بطاقة الفاتورة المُجمعة
class _BatchBillCard extends StatelessWidget {
  final dynamic batchBill; // Using dynamic for now

  const _BatchBillCard({required this.batchBill});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              batchBill.batchNumber ?? 'فاتورة مُجمعة',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              batchBill.batchDescription ?? 'وصف الفاتورة المُجمعة',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${batchBill.totalAmount?.toStringAsFixed(2) ?? '0.00'} ر.س',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'عدد الفواتير: ${batchBill.individualBillsCount ?? 0}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// حوار الدفع المُجمع
class BatchPaymentDialog extends StatefulWidget {
  const BatchPaymentDialog({super.key});

  @override
  State<BatchPaymentDialog> createState() => _BatchPaymentDialogState();
}

class _BatchPaymentDialogState extends State<BatchPaymentDialog> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إنشاء فاتورة مُجمعة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<BillsProvider>(
            builder: (context, billsProvider, child) {
              return Text(
                'عدد الفواتير المحددة: ${billsProvider.selectedBills.length}\n'
                'إجمالي المبلغ: ${billsProvider.selectedBillsTotal.toStringAsFixed(2)} ر.س',
                style: const TextStyle(fontSize: 16),
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'وصف الفاتورة المُجمعة',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(onPressed: _createBatchBill, child: const Text('إنشاء')),
      ],
    );
  }

  Future<void> _createBatchBill() async {
    // TODO: Implement batch bill creation
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء الفاتورة المُجمعة بنجاح')),
    );
  }
}
