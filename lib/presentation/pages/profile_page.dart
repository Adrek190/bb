import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/parent_profile_provider.dart';

/// صفحة الملف الشخصي للوالد
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // تحميل بيانات الوالد عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParentProfileProvider>().loadParentProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ParentProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentParent == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ: ${provider.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadParentProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (provider.currentParent == null) {
            return const Center(
              child: Text(
                'لا توجد بيانات متاحة',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadParentProfile(forceRefresh: true);
            },
            color: const Color(0xFF2E7D32),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // صورة الملف الشخصي
                  _buildProfileImage(context, provider),
                  const SizedBox(height: 24),

                  // بطاقة معلومات الوالد
                  _buildParentInfoCard(context, provider),
                  const SizedBox(height: 16),

                  // بطاقة الإعدادات
                  _buildSettingsCard(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// بناء صورة الملف الشخصي
  Widget _buildProfileImage(
    BuildContext context,
    ParentProfileProvider provider,
  ) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E7D32), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: provider.profileImageUrl != null
                  ? Image.network(
                      provider.profileImageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2E7D32),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          // زر تحرير الصورة
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImageSourceDialog(context, provider),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // مؤشر التحميل عند رفع الصورة
          if (provider.isUpdating)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// بناء بطاقة معلومات الوالد
  Widget _buildParentInfoCard(
    BuildContext context,
    ParentProfileProvider provider,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المعلومات الشخصية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditNameDialog(context, provider),
                  icon: const Icon(Icons.edit, color: Color(0xFF2E7D32)),
                ),
              ],
            ),
            const Divider(),

            // اسم الوالد
            _buildInfoRow(
              Icons.person,
              'الاسم',
              provider.parentName.isNotEmpty ? provider.parentName : 'غير محدد',
            ),
            const SizedBox(height: 12),

            // رقم الهاتف
            _buildInfoRow(
              Icons.phone,
              'رقم الهاتف',
              provider.parentPhone.isNotEmpty
                  ? provider.parentPhone
                  : 'غير محدد',
            ),
            const SizedBox(height: 12),

            // البريد الإلكتروني
            _buildInfoRow(
              Icons.email,
              'البريد الإلكتروني',
              provider.parentEmail.isNotEmpty
                  ? provider.parentEmail
                  : 'غير محدد',
            ),
            const SizedBox(height: 12),

            // حالة التحقق
            _buildInfoRow(
              provider.isVerified ? Icons.verified : Icons.warning,
              'حالة التحقق',
              provider.isVerified ? 'محقق' : 'غير محقق',
              valueColor: provider.isVerified ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة الإعدادات
  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإعدادات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const Divider(),

            // تغيير كلمة المرور
            _buildSettingsTile(Icons.lock, 'تغيير كلمة المرور', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم إضافة هذه الميزة قريباً')),
              );
            }),

            // الإشعارات
            _buildSettingsTile(Icons.notifications, 'إعدادات الإشعارات', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم إضافة هذه الميزة قريباً')),
              );
            }),

            // المساعدة
            _buildSettingsTile(Icons.help, 'المساعدة والدعم', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم إضافة هذه الميزة قريباً')),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// بناء صف معلومات
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء عنصر إعدادات
  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// عرض حوار اختيار مصدر الصورة
  void _showImageSourceDialog(
    BuildContext context,
    ParentProfileProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختر مصدر الصورة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
                title: const Text('الكاميرا'),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.selectProfileImage(source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF2E7D32),
                ),
                title: const Text('المعرض'),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.selectProfileImage(source: ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// عرض حوار تحرير الاسم
  void _showEditNameDialog(
    BuildContext context,
    ParentProfileProvider provider,
  ) {
    final TextEditingController controller = TextEditingController(
      text: provider.parentName,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تحرير الاسم'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'الاسم',
              border: OutlineInputBorder(),
            ),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  final success = await provider.updateParentName(
                    controller.text.trim(),
                  );

                  if (provider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ: ${provider.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث الاسم بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
