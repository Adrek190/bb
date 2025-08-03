import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

enum StudyDaysOption {
  weekdays, // السبت إلى الخميس (5 أيام)
  fullWeek, // كامل الأسبوع (7 أيام)
  custom, // تحديد يدوي
}

class WorkDaysSelector extends StatefulWidget {
  final List<String> selectedDays;
  final Function(List<String>) onDaysChanged;
  final String? errorText;

  const WorkDaysSelector({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
    this.errorText,
  });

  @override
  State<WorkDaysSelector> createState() => _WorkDaysSelectorState();
}

class _WorkDaysSelectorState extends State<WorkDaysSelector> {
  StudyDaysOption _selectedOption = StudyDaysOption.weekdays;
  List<String> _customSelectedDays = [];

  static const List<String> _allDays = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  static const List<String> _weekdaysOnly = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  @override
  void initState() {
    super.initState();
    _initializeSelectedOption();
  }

  void _initializeSelectedOption() {
    if (widget.selectedDays.isEmpty) {
      _selectedOption = StudyDaysOption.weekdays;
      _customSelectedDays = List.from(_weekdaysOnly);
    } else if (_listsEqual(widget.selectedDays, _weekdaysOnly)) {
      _selectedOption = StudyDaysOption.weekdays;
      _customSelectedDays = List.from(_weekdaysOnly);
    } else if (_listsEqual(widget.selectedDays, _allDays)) {
      _selectedOption = StudyDaysOption.fullWeek;
      _customSelectedDays = List.from(_allDays);
    } else {
      _selectedOption = StudyDaysOption.custom;
      _customSelectedDays = List.from(widget.selectedDays);
    }
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (String item in list1) {
      if (!list2.contains(item)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // التسمية
        const Text(
          'أيام الدراسة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),

        // خيارات سريعة
        _buildQuickOptions(),

        const SizedBox(height: AppDimensions.paddingMedium),

        // اختيار الأيام المخصص
        if (_selectedOption == StudyDaysOption.custom)
          _buildCustomDaysSelector(),

        // رسالة الخطأ
        if (widget.errorText != null) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            widget.errorText!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickOptions() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.errorText != null
              ? AppColors.error
              : AppColors.borderPrimary,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          _buildQuickOption(
            title: 'السبت إلى الخميس',
            subtitle: '5 أيام في الأسبوع',
            icon: Icons.calendar_view_week,
            option: StudyDaysOption.weekdays,
            isFirst: true,
          ),
          const Divider(height: 1, color: AppColors.borderPrimary),
          _buildQuickOption(
            title: 'كامل الأسبوع',
            subtitle: '7 أيام في الأسبوع',
            icon: Icons.calendar_month,
            option: StudyDaysOption.fullWeek,
          ),
          const Divider(height: 1, color: AppColors.borderPrimary),
          _buildQuickOption(
            title: 'تحديد مخصص',
            subtitle: 'اختر أيام محددة',
            icon: Icons.tune,
            option: StudyDaysOption.custom,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required StudyDaysOption option,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = _selectedOption == option;

    return InkWell(
      onTap: () => _selectOption(option),
      borderRadius: BorderRadius.vertical(
        top: isFirst
            ? const Radius.circular(AppDimensions.radiusMedium)
            : Radius.zero,
        bottom: isLast
            ? const Radius.circular(AppDimensions.radiusMedium)
            : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.borderSecondary,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppDimensions.paddingMedium),

            // أيقونة
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: AppDimensions.iconSize,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.textSecondary
                          : AppColors.textHint,
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

  Widget _buildCustomDaysSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              const Text(
                'اختر الأيام المطلوبة:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // شبكة الأيام
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: _allDays.map((day) => _buildDayChip(day)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayChip(String day) {
    final isSelected = _customSelectedDays.contains(day);

    return InkWell(
      onTap: () => _toggleCustomDay(day),
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderPrimary,
          ),
        ),
        child: Text(
          day,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _selectOption(StudyDaysOption option) {
    setState(() {
      _selectedOption = option;

      switch (option) {
        case StudyDaysOption.weekdays:
          _customSelectedDays = List.from(_weekdaysOnly);
          break;
        case StudyDaysOption.fullWeek:
          _customSelectedDays = List.from(_allDays);
          break;
        case StudyDaysOption.custom:
          if (_customSelectedDays.isEmpty) {
            _customSelectedDays = List.from(_weekdaysOnly);
          }
          break;
      }
    });

    widget.onDaysChanged(_customSelectedDays);
  }

  void _toggleCustomDay(String day) {
    setState(() {
      if (_customSelectedDays.contains(day)) {
        _customSelectedDays.remove(day);
      } else {
        _customSelectedDays.add(day);
      }
    });

    widget.onDaysChanged(_customSelectedDays);
  }
}
