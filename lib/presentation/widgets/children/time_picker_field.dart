import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

class TimePickerField extends StatefulWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay?) onTimeSelected;
  final IconData prefixIcon;
  final String? errorText;
  final bool enabled;

  const TimePickerField({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTimeSelected,
    this.prefixIcon = Icons.access_time,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // التسمية
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
        ],

        // حقل الوقت
        GestureDetector(
          onTap: widget.enabled ? _selectTime : null,
          child: Container(
            height: AppDimensions.inputHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : AppColors.background,
              border: Border.all(
                color: widget.errorText != null
                    ? AppColors.error
                    : AppColors.borderPrimary,
                width: AppDimensions.borderWidth,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(
              children: [
                // أيقونة الوقت
                Icon(
                  widget.prefixIcon,
                  size: AppDimensions.iconSize,
                  color: widget.selectedTime != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.paddingMedium),

                // النص المعروض
                Expanded(
                  child: Text(
                    widget.selectedTime != null
                        ? _formatTime(widget.selectedTime!)
                        : 'اختر ${widget.label.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.selectedTime != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),

                // أيقونة السهم
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconSize,
                ),
              ],
            ),
          ),
        ),

        // رسالة الخطأ
        if (widget.errorText != null) ...[
          const SizedBox(height: AppDimensions.paddingXSmall),
          Text(
            widget.errorText!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.selectedTime) {
      widget.onTimeSelected(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'مساءً' : 'صباحاً';

    return '$hour:$minute $period';
  }
}
