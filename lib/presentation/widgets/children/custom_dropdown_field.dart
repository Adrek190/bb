import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;
  final IconData? prefixIcon;
  final bool enabled;
  final String? errorText;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.prefixIcon,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
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

        // Dropdown Field
        Container(
          height: AppDimensions.inputHeight,
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: widget.selectedValue,
              hint: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(
                      widget.prefixIcon,
                      size: AppDimensions.iconSize,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.paddingMedium),
                  ],
                  Text(
                    widget.hint,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              icon: const Padding(
                padding: EdgeInsets.only(left: AppDimensions.paddingMedium),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ),
              items: widget.items
                  .where((item) => item.isNotEmpty) // تجنب القيم الفارغة
                  .toSet() // إزالة المكررات
                  .map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Row(
                        children: [
                          if (widget.prefixIcon != null) ...[
                            Icon(
                              widget.prefixIcon,
                              size: AppDimensions.iconSize,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppDimensions.paddingMedium),
                          ],
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(),
              onChanged: widget.enabled ? widget.onChanged : null,
              selectedItemBuilder: (BuildContext context) {
                return widget.items
                    .where((item) => item.isNotEmpty) // تجنب القيم الفارغة
                    .toSet() // إزالة المكررات
                    .map((String item) {
                      return Row(
                        children: [
                          if (widget.prefixIcon != null) ...[
                            const SizedBox(width: AppDimensions.paddingMedium),
                            Icon(
                              widget.prefixIcon,
                              size: AppDimensions.iconSize,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppDimensions.paddingMedium),
                          ] else ...[
                            const SizedBox(width: AppDimensions.paddingMedium),
                          ],
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      );
                    })
                    .toList();
              },
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              elevation: 8,
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
}
