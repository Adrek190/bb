import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final Function(String?) onGenderChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الطفل',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                title: 'ذكر',
                value: 'male',
                icon: Icons.boy,
                color: AppColors.maleColor,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: _buildGenderOption(
                title: 'أنثى',
                value: 'female',
                icon: Icons.girl,
                color: AppColors.femaleColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedGender == value;

    return GestureDetector(
      onTap: () => onGenderChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingLarge,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : AppColors.borderPrimary,
            width: isSelected
                ? AppDimensions.borderWidthThick
                : AppDimensions.borderWidth,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة الراديو
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.borderSecondary,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            // أيقونة النوع
            Icon(
              icon,
              size: AppDimensions.iconSizeLarge,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            // النص
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
