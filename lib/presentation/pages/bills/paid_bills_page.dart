import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class PaidBillsPage extends StatefulWidget {
  const PaidBillsPage({super.key});

  @override
  State<PaidBillsPage> createState() => _PaidBillsPageState();
}

class _PaidBillsPageState extends State<PaidBillsPage> {
  List<Map<String, dynamic>> paidBills = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPaidBills();
  }

  Future<void> _loadPaidBills() async {
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

      // استدعاء دالة جلب الفواتير المدفوعة
      final response = await Supabase.instance.client.rpc(
        'get_paid_bills',
        params: {'p_parent_id': parentId},
      );

      if (response == null) {
        setState(() {
          paidBills = [];
          isLoading = false;
        });
        return;
      }

      final List<dynamic> billsData = response as List<dynamic>;

      setState(() {
        paidBills = billsData.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في تحميل الفواتير: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفواتير المدفوعة'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaidBills,
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _loadPaidBills, child: _buildBody()),
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
              onPressed: _loadPaidBills,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (paidBills.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد فواتير مدفوعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('لم تدفع أي فواتير بعد', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paidBills.length,
      itemBuilder: (context, index) {
        final bill = paidBills[index];
        return _buildBillCard(bill);
      },
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!, width: 1),
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
                    bill['bill_number'] ?? 'غير محدد',
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
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green[800],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'مدفوع',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // وصف الفاتورة
              Text(
                bill['bill_description'] ?? 'لا يوجد وصف',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // تفاصيل المبلغ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'قيمة الفاتورة:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '${(bill['amount'] ?? 0).toStringAsFixed(2)} ريال',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'المبلغ المدفوع:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '${(bill['paid_amount'] ?? 0).toStringAsFixed(2)} ريال',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // تفاصيل الدفع
              if (bill['bank_name'] != null ||
                  bill['transfer_number'] != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تفاصيل الدفع:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (bill['bank_name'] != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'البنك: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              bill['bank_name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                      if (bill['transfer_number'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.receipt,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'رقم الحوالة: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              bill['transfer_number'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // تاريخ الدفع
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  const Text(
                    'تاريخ الدفع: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    _formatDate(bill['payment_date']),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // ملاحظات الإدارة
              if (bill['admin_notes'] != null &&
                  bill['admin_notes'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
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
                      Row(
                        children: [
                          Icon(Icons.note, size: 16, color: Colors.blue[600]),
                          const SizedBox(width: 4),
                          const Text(
                            'ملاحظات الإدارة:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bill['admin_notes'],
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ],
                  ),
                ),
              ],

              // صورة الإيصال
              if (bill['receipt_image_path'] != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showReceiptImage(bill['receipt_image_path']),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 32, color: Colors.grey),
                        SizedBox(height: 4),
                        Text(
                          'اضغط لعرض صورة الإيصال',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // زر تحميل الفاتورة
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _downloadBillReceipt(bill),
                  icon: const Icon(Icons.download),
                  label: const Text('تحميل إيصال الدفع'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    side: BorderSide(color: Colors.green[300]!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic dateTime) {
    if (dateTime == null) return 'غير محدد';

    try {
      final date = DateTime.parse(dateTime.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'غير محدد';
    }
  }

  void _showReceiptImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('صورة الإيصال'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.black,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'سيتم تطوير عارض الصور قريباً',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadBillReceipt(Map<String, dynamic> bill) {
    // سيتم تطوير هذه الوظيفة لاحقاً
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تطوير وظيفة التحميل قريباً'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
