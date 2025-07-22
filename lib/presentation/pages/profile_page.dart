import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/edit_dialog.dart';
import '../providers/user_profile_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: const CustomAppBar(title: 'حسابي', showUserIcon: false),
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // الصورة الشخصية
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.amber,
                      backgroundImage: userProvider.profileImage != null
                          ? (kIsWeb
                                ? NetworkImage(userProvider.profileImage!.path)
                                : FileImage(
                                        File(userProvider.profileImage!.path),
                                      )
                                      as ImageProvider)
                          : null,
                      child: userProvider.profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey.shade600,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickProfileImage(context, userProvider),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // حقول البيانات
                _buildProfileField(
                  label: 'الاسم',
                  value: userProvider.userName,
                  icon: Icons.person_outline,
                  onEdit: () async {
                    final result = await EditDialog.showEditNameDialog(
                      context: context,
                      currentName: userProvider.userName,
                    );
                    if (result != null) {
                      userProvider.updateUserName(result);
                    }
                  },
                ),

                const SizedBox(height: 16),

                _buildProfileField(
                  label: 'الايميل',
                  value: userProvider.userEmail,
                  icon: Icons.email_outlined,
                  onEdit: () async {
                    final result = await EditDialog.showEditEmailDialog(
                      context: context,
                      currentEmail: userProvider.userEmail,
                    );
                    if (result != null) {
                      userProvider.updateUserEmail(result);
                    }
                  },
                ),

                const SizedBox(height: 16),

                _buildProfileField(
                  label: 'العنوان',
                  value: userProvider.userAddress,
                  icon: Icons.location_on_outlined,
                  onEdit: () async {
                    final result = await EditDialog.showEditAddressDialog(
                      context: context,
                      currentAddress: userProvider.userAddress,
                    );
                    if (result != null) {
                      userProvider.updateUserAddress(result);
                    }
                  },
                ),

                const SizedBox(height: 16),

                _buildProfileField(
                  label: 'رقم الهاتف',
                  value: userProvider.userPhone,
                  icon: Icons.phone_outlined,
                  onEdit: () async {
                    final result = await EditDialog.showEditPhoneDialog(
                      context: context,
                      currentPhone: userProvider.userPhone,
                    );
                    if (result != null) {
                      userProvider.updateUserPhone(result);
                    }
                  },
                ),

                const SizedBox(height: 16),

                _buildProfileField(
                  label: 'كلمة المرور',
                  value: '••••••••',
                  icon: Icons.lock_outline,
                  onEdit: () {
                    EditDialog.showEditPasswordDialog(context: context);
                  },
                ),

                const SizedBox(height: 30),

                // أزرار إضافية
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildActionButton(
                        icon: Icons.notifications_outlined,
                        title: 'الإشعارات',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: Icons.help_outline,
                        title: 'المساعدة والدعم',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: Icons.logout,
                        title: 'تسجيل الخروج',
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickProfileImage(
    BuildContext context,
    UserProfileProvider userProvider,
  ) async {
    final ImagePicker picker = ImagePicker();

    // عرض خيارات اختيار الصورة
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختيار الصورة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.camera),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text('الكاميرا'),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.gallery),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_library,
                              size: 40,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text('المعرض'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source != null) {
      try {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 800,
          maxHeight: 800,
        );

        if (pickedFile != null) {
          userProvider.updateProfileImage(pickedFile);

          // إظهار رسالة نجاح
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الصورة الشخصية بنجاح'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        // إظهار رسالة خطأ
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء اختيار الصورة: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.amber,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // يمكن إضافة منطق تسجيل الخروج هنا
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الخروج بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        );
      },
    );
  }
}
