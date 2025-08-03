import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

class WizardButtons extends StatelessWidget {
  final bool canGoNext;
  final bool canGoPrevious;
  final bool isLastStep;
  final bool isLoading;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSubmit;

  const WizardButtons({
    super.key,
    required this.canGoNext,
    required this.canGoPrevious,
    required this.isLastStep,
    this.isLoading = false,
    this.onNext,
    this.onPrevious,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // زر الرجوع
            if (canGoPrevious) ...[
              Expanded(
                flex: 1,
                child: _buildSecondaryButton(
                  text: 'السابق',
                  icon: Icons.arrow_back,
                  onPressed: isLoading ? null : onPrevious,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
            ],

            // زر التالي/الإرسال
            Expanded(
              flex: canGoPrevious ? 2 : 1,
              child: _buildPrimaryButton(
                text: isLastStep ? 'إرسال الطلب' : 'التالي',
                icon: isLastStep ? Icons.send : Icons.arrow_forward,
                onPressed: _getPrimaryButtonAction(),
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? _getPrimaryButtonAction() {
    if (isLoading) return null;

    if (isLastStep) {
      // في الخطوة الأخيرة، يجب أن نسمح بالإرسال إذا كان onSubmit متاح
      // بدلاً من التحقق من canGoNext
      return onSubmit;
    } else {
      return canGoNext ? onNext : null;
    }
  }

  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        elevation: 0,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 20),
      label: Text(
        isLoading ? 'جاري الإرسال...' : text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderPrimary),
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        backgroundColor: Colors.white,
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Widget مبسط للأزرار العادية
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? (isPrimary ? AppColors.primary : Colors.white);
    final textColor = isPrimary ? Colors.white : AppColors.textPrimary;

    Widget buttonContent = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: textColor),
                const SizedBox(width: AppDimensions.paddingSmall),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          );

    if (isPrimary) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          elevation: 0,
          disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
        ),
        child: buttonContent,
      );
    } else {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: color ?? AppColors.borderPrimary),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          backgroundColor: buttonColor,
        ),
        child: buttonContent,
      );
    }
  }
}
