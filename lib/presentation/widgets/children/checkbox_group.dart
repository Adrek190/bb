import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

class CheckboxGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onSelectionChanged;
  final bool allowMultiple;
  final String? errorText;

  const CheckboxGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
    this.allowMultiple = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),

        // الخيارات
        ...options.map((option) => _buildCheckboxItem(option)),

        // رسالة الخطأ
        if (errorText != null) ...[
          const SizedBox(height: AppDimensions.paddingXSmall),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckboxItem(String option) {
    final isSelected = selectedOptions.contains(option);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderPrimary,
          width: isSelected
              ? AppDimensions.borderWidthThick
              : AppDimensions.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: CheckboxListTile(
        title: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        value: isSelected,
        onChanged: (bool? checked) {
          _handleSelection(option, checked ?? false);
        },
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppColors.primary,
        checkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.borderSecondary,
          width: 2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingXSmall,
        ),
      ),
    );
  }

  void _handleSelection(String option, bool isChecked) {
    List<String> newSelection = List<String>.from(selectedOptions);

    if (isChecked) {
      if (allowMultiple) {
        if (!newSelection.contains(option)) {
          newSelection.add(option);
        }
      } else {
        // إذا لم يكن متعدد الخيارات، امسح الخيارات السابقة
        newSelection.clear();
        newSelection.add(option);
      }
    } else {
      newSelection.remove(option);
    }

    onSelectionChanged(newSelection);
  }
}

// Widget منفصل لاختيار أيام الأسبوع
class DaysSelector extends StatelessWidget {
  final List<String> selectedDays;
  final Function(List<String>) onDaysChanged;
  final String? errorText;

  const DaysSelector({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
    this.errorText,
  });

  static const List<String> weekDays = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أيام الدراسة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),

        // اختر الكل / إلغاء الكل
        Row(
          children: [
            TextButton.icon(
              onPressed: () => onDaysChanged(List<String>.from(weekDays)),
              icon: const Icon(Icons.select_all, size: 18),
              label: const Text('اختر الكل'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            TextButton.icon(
              onPressed: () => onDaysChanged([]),
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('إلغاء الكل'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.paddingSmall),

        // شبكة الأيام
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: AppDimensions.paddingSmall,
            mainAxisSpacing: AppDimensions.paddingSmall,
          ),
          itemCount: weekDays.length,
          itemBuilder: (context, index) {
            final day = weekDays[index];
            final isSelected = selectedDays.contains(day);

            return GestureDetector(
              onTap: () => _toggleDay(day),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.borderPrimary,
                    width: AppDimensions.borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // عرض الأيام المحددة كـ chips
        if (selectedDays.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          const Text(
            'الأيام المحددة:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingXSmall,
            children: selectedDays
                .map(
                  (day) => Chip(
                    label: Text(
                      day,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: AppColors.secondary,
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    onDeleted: () => _toggleDay(day),
                  ),
                )
                .toList(),
          ),
        ],

        // رسالة الخطأ
        if (errorText != null) ...[
          const SizedBox(height: AppDimensions.paddingXSmall),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  void _toggleDay(String day) {
    List<String> newSelection = List<String>.from(selectedDays);

    if (newSelection.contains(day)) {
      newSelection.remove(day);
    } else {
      newSelection.add(day);
    }

    onDaysChanged(newSelection);
  }
}
