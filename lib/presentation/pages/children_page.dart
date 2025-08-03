import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_dimensions.dart';
import 'children/add_child_wizard_page.dart';

class ChildrenPage extends StatefulWidget {
  const ChildrenPage({super.key});

  @override
  State<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildEmptyState(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddChildWizardPage()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // رسالة "لا يوجد لديك أطفال" مطابقة للتصميم
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
                vertical: AppDimensions.paddingXLarge,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD), // لون تحذيري فاتح
                border: Border.all(
                  color: const Color(0xFFFFD60A), // لون تحذيري
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Text(
                'لا يوجد لديك أطفال',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXLarge),
            // نص توضيحي إضافي
            Text(
              'يمكنك إضافة طفل جديد بالضغط على زر الإضافة أدناه',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
