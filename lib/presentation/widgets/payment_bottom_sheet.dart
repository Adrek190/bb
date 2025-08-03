import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/bill_model.dart';

class PaymentBottomSheet extends StatefulWidget {
  final BillModel bill;

  const PaymentBottomSheet({super.key, required this.bill});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // خطوات العملية
  int currentStep = 0;
  final PageController _pageController = PageController();

  // بيانات النموذج
  String? selectedBankId;
  String? selectedBankName;
  String transferNumber = '';
  String? receiptImagePath;
  bool isLoading = false;

  // البنوك المتاحة
  List<Map<String, dynamic>> banks = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadBanks();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  Future<void> _loadBanks() async {
    try {
      final response = await Supabase.instance.client
          .from('banks')
          .select('bank_id, bank_name')
          .eq('is_active', true)
          .order('bank_name');

      setState(() {
        banks = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('خطأ في تحميل البنوك: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNextStep() {
    switch (currentStep) {
      case 0:
        return selectedBankId != null;
      case 1:
        return receiptImagePath != null;
      case 2:
        return transferNumber.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _submitPaymentRequest() async {
    if (!_canProceedToNextStep()) return;

    setState(() {
      isLoading = true;
    });

    try {
      print('🚀 بدء إرسال طلب الدفع...');

      final authService = context.read<AuthService>();
      final parentId = await authService.getParentId();

      print('👤 معرف الوالد: $parentId');

      if (parentId == null) {
        throw Exception('لم يتم العثور على بيانات المستخدم');
      }

      print('📄 معرف الفاتورة: ${widget.bill.billId}');
      print('🏦 معرف البنك: $selectedBankId');
      print('💰 المبلغ: ${widget.bill.amount}');
      print('🔢 رقم الحوالة: $transferNumber');

      final response = await Supabase.instance.client.rpc(
        'submit_bill_payment_request',
        params: {
          'p_bill_id': widget.bill.billId,
          'p_parent_id': parentId,
          'p_bank_id': selectedBankId,
          'p_transfer_number': transferNumber,
          'p_receipt_image_path': receiptImagePath,
          'p_amount': widget.bill.amount,
        },
      );

      print('✅ استجابة الخادم: $response');

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلب الدفع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('لم يتم تلقي رد من الخادم');
      }
    } catch (e) {
      print('❌ خطأ في إرسال الطلب: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إرسال الطلب: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProgressIndicator(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildBankSelectionStep(),
                        _buildReceiptUploadStep(),
                        _buildTransferNumberStep(),
                        _buildConfirmationStep(),
                      ],
                    ),
                  ),
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.payment, color: Colors.blue[600], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'دفع الفاتورة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'فاتورة رقم: ${widget.bill.billNumber}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '${widget.bill.amount.toStringAsFixed(2)} ريال',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : isActive
                          ? Colors.blue
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : _getStepIcon(index),
                      color: isActive || isCompleted
                          ? Colors.white
                          : Colors.grey[600],
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStepTitle(index),
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? Colors.blue : Colors.grey[600],
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.account_balance;
      case 1:
        return Icons.camera_alt;
      case 2:
        return Icons.receipt;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'اختيار البنك';
      case 1:
        return 'رفع الإيصال';
      case 2:
        return 'رقم الحوالة';
      case 3:
        return 'التأكيد';
      default:
        return '';
    }
  }

  Widget _buildBankSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏦 اختر البنك المحول منه',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'اختر البنك الذي قمت بالتحويل منه',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                final isSelected = selectedBankId == bank['bank_id'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[100] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                    ),
                    title: Text(
                      bank['bank_name'],
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedBankId = bank['bank_id'];
                        selectedBankName = bank['bank_name'];
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptUploadStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📷 ارفق صورة الإيصال',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'ارفع صورة رسالة عملية إتمام الدفع',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: receiptImagePath != null
                        ? Colors.green[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: receiptImagePath != null
                          ? Colors.green
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        receiptImagePath != null
                            ? Icons.check_circle
                            : Icons.cloud_upload,
                        size: 64,
                        color: receiptImagePath != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        receiptImagePath != null
                            ? 'تم رفع الصورة بنجاح!'
                            : 'اضغط لرفع صورة الإيصال',
                        style: TextStyle(
                          fontSize: 16,
                          color: receiptImagePath != null
                              ? Colors.green
                              : Colors.grey[600],
                          fontWeight: receiptImagePath != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (receiptImagePath == null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'PNG, JPG حتى 5MB',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferNumberStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔢 رقم الإيصال',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'أدخل رقم الإيصال أو الحوالة البنكية',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'رقم الإيصال / الحوالة',
              hintText: 'مثال: 123456789',
              prefixIcon: const Icon(Icons.receipt),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.text,
            textDirection: TextDirection.ltr,
            onChanged: (value) {
              setState(() {
                transferNumber = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'تأكد من كتابة رقم الإيصال بدقة كما يظهر في رسالة البنك',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✅ تأكيد البيانات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'تحقق من البيانات قبل الإرسال',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: [
                _buildConfirmationCard(
                  'فاتورة رقم',
                  widget.bill.billNumber,
                  Icons.receipt_long,
                ),
                _buildConfirmationCard(
                  'المبلغ المدفوع',
                  '${widget.bill.amount.toStringAsFixed(2)} ريال',
                  Icons.payment,
                ),
                _buildConfirmationCard(
                  'البنك المحول منه',
                  selectedBankName ?? 'غير محدد',
                  Icons.account_balance,
                ),
                _buildConfirmationCard(
                  'رقم الإيصال',
                  transferNumber.isNotEmpty ? transferNumber : 'غير محدد',
                  Icons.confirmation_number,
                ),
                _buildConfirmationCard(
                  'صورة الإيصال',
                  receiptImagePath != null ? 'تم الرفع ✓' : 'لم يتم الرفع',
                  Icons.image,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('السابق'),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (currentStep == 3) {
                        _submitPaymentRequest();
                      } else if (_canProceedToNextStep()) {
                        _nextStep();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      currentStep == 3 ? 'إرسال الطلب' : 'التالي',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage() {
    // مؤقتاً - سيتم تطوير رفع الصور لاحقاً
    setState(() {
      receiptImagePath = 'temp_image_path.jpg';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تطوير رفع الصور قريباً'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
