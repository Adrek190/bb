import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class UnderReviewBillsPage extends StatefulWidget {
  const UnderReviewBillsPage({super.key});

  @override
  State<UnderReviewBillsPage> createState() => _UnderReviewBillsPageState();
}

class _UnderReviewBillsPageState extends State<UnderReviewBillsPage> {
  List<Map<String, dynamic>> underReviewBills = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUnderReviewBills();
  }

  Future<void> _loadUnderReviewBills() async {
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

      // استدعاء دالة جلب الفواتير تحت المراجعة
      final response = await Supabase.instance.client.rpc(
        'get_bills_under_review',
        params: {'p_parent_id': parentId},
      );

      if (response == null) {
        setState(() {
          underReviewBills = [];
          isLoading = false;
        });
        return;
      }

      final List<dynamic> billsData = response as List<dynamic>;

      setState(() {
        underReviewBills = billsData.cast<Map<String, dynamic>>();
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
        title: const Text('الفواتير تحت المراجعة'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUnderReviewBills,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUnderReviewBills,
        child: _buildBody(),
      ),
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
              onPressed: _loadUnderReviewBills,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (underReviewBills.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد فواتير تحت المراجعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'لم ترسل أي طلبات دفع بعد',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: underReviewBills.length,
      itemBuilder: (context, index) {
        final bill = underReviewBills[index];
        return _buildBillCard(bill);
      },
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill) {
    final status = bill['status'] as String;
    final isRejected = status == 'rejected';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isRejected ? Border.all(color: Colors.red, width: 2) : null,
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
                      color: isRejected ? Colors.red[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isRejected ? 'مرفوض' : 'تحت المراجعة',
                      style: TextStyle(
                        color: isRejected
                            ? Colors.red[800]
                            : Colors.orange[800],
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
                bill['bill_description'] ?? 'لا يوجد وصف',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // تفاصيل الدفع
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
                      'تفاصيل الدفع المرسلة:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'البنك:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              bill['bank_name'] ?? 'غير محدد',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'المبلغ:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${(bill['amount'] ?? 0).toStringAsFixed(2)} ريال',
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
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Text(
                          'رقم الحوالة: ',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          bill['transfer_number'] ?? 'غير محدد',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // تاريخ الإرسال
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'تم الإرسال: ${_formatDate(bill['submitted_at'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              // ملاحظات الإدارة (في حالة الرفض)
              if (isRejected && bill['admin_notes'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.red[600],
                          ),
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
                        style: TextStyle(color: Colors.red[800]),
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
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
}
