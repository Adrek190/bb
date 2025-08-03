import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isArabicSelected = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // رأس القائمة الجانبية
          Container(
            height: 280,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // صورة المستخدم (مؤقتة)
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.amber,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // اسم المستخدم (مؤقت)
                const Text(
                  'ولي الأمر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // أيقونة الموقع
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // قائمة الروابط
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // الصفحة الرئيسية
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'الصفحة الرئيسية',
                  textColor: Colors.blue,
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                ),

                const Divider(height: 1),

                _buildDrawerItem(
                  icon: Icons.receipt_long,
                  title: 'الفواتير',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/bills');
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.shopping_bag,
                  title: 'الطلبات',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/requests');
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.directions_bus,
                  title: 'سجل الرحلات',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/all-trips');
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'شكاوي',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/complaints');
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.star_outline,
                  title: 'التقييم',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/ratings');
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.subscriptions,
                  title: 'الاشتراكات',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/subscriptions');
                  },
                ),

                const Divider(height: 1),

                // محدد اللغة
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'اللغة',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(width: 40), // مسافة لتنسيق مع الأيقونة
                          _buildLanguageOption(
                            flag: '🇸🇦',
                            label: 'عربي',
                            isSelected: isArabicSelected,
                            onTap: () {
                              setState(() {
                                isArabicSelected = true;
                              });
                              // TODO: تغيير اللغة إلى العربية
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildLanguageOption(
                            flag: '🇬🇧',
                            label: 'انجليزي',
                            isSelected: !isArabicSelected,
                            onTap: () {
                              setState(() {
                                isArabicSelected = false;
                              });
                              // TODO: تغيير اللغة إلى الإنجليزية
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // روابط الدعم
                _buildDrawerItem(
                  icon: Icons.support_agent,
                  title: 'تواصل مع خدمة العملاء',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: فتح صفحة التواصل
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.article,
                  title: 'شروط وأحكام الخدمة',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: فتح صفحة الشروط والأحكام
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'الأسئلة الشائعة',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: فتح صفحة الأسئلة الشائعة
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'عن البرنامج',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: فتح صفحة عن البرنامج
                  },
                ),

                const Divider(height: 1),

                // تسجيل الخروج
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'تسجيل خروج',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade600, size: 24),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.black87, fontSize: 16),
        textDirection: TextDirection.rtl,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.teal.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.teal, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.teal : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج', textDirection: TextDirection.rtl),
          content: const Text(
            'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'تسجيل خروج',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: تطبيق عملية تسجيل الخروج
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
