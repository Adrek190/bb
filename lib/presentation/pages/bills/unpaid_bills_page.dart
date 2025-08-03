import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/bill_model.dart';
import '../../widgets/payment_bottom_sheet.dart';

class UnpaidBillsPage extends StatefulWidget {
  const UnpaidBillsPage({super.key});

  @override
  State<UnpaidBillsPage> createState() => _UnpaidBillsPageState();
}

class _UnpaidBillsPageState extends State<UnpaidBillsPage> {
  List<BillModel> unpaidBills = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUnpaidBills();
  }

  Future<void> _loadUnpaidBills() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // جلب معرف الوالد من الخدمة
      final authService = context.read<AuthService>();
      final parentId = await authService.getParentId();

      if (parentId == null) {
        throw Exception('لم يتم العثور على بيانات المستخدم');
      }

      // استدعاء دالة جلب الفواتير غير المدفوعة
      final response = await Supabase.instance.client.rpc(
        'get_unpaid_bills',
        params: {'p_parent_id': parentId},
      );

      if (response == null) {
        setState(() {
          unpaidBills = [];
          isLoading = false;
        });
        return;
      }

      final List<dynamic> billsData = response as List<dynamic>;

      setState(() {
        unpaidBills = billsData
            .map((bill) => BillModel.fromJson(bill))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في تحميل الفواتير: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _showPaymentBottomSheet(BillModel bill) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentBottomSheet(bill: bill),
    );

    if (result == true) {
      // إعادة تحميل الفواتير بعد الدفع
      _loadUnpaidBills();

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلب الدفع بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفواتير غير المدفوعة'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUnpaidBills,
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _loadUnpaidBills, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUnpaidBills,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (unpaidBills.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'لا توجد فواتير غير مدفوعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('جميع فواتيرك مدفوعة!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unpaidBills.length,
      itemBuilder: (context, index) {
        final bill = unpaidBills[index];
        return _buildBillCard(bill);
      },
    );
  }

  Widget _buildBillCard(BillModel bill) {
    final isOverdue = bill.status == 'overdue';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isOverdue ? Border.all(color: Colors.red, width: 2) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bill.billNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue ? Colors.red[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOverdue ? 'متأخر' : 'مستحق',
                      style: TextStyle(
                        color: isOverdue ? Colors.red[800] : Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // وصف الفاتورة
              Text(
                bill.billDescription,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // المبلغ وتاريخ الاستحقاق
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المبلغ',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${bill.amount.toStringAsFixed(2)} ريال',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (bill.dueDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'تاريخ الاستحقاق',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _formatDate(bill.dueDate!),
                          style: TextStyle(
                            fontSize: 14,
                            color: isOverdue ? Colors.red : Colors.grey[700],
                            fontWeight: isOverdue
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // زر الدفع
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentBottomSheet(bill),
                  icon: const Icon(Icons.payment),
                  label: const Text('دفع الفاتورة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverdue ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
