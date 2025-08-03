import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildSteps(),
      ),
    );
  }

  List<Widget> _buildSteps() {
    List<Widget> widgets = [];

    for (int i = 0; i < totalSteps; i++) {
      // إضافة دائرة المرحلة
      widgets.add(_buildStepCircle(i));

      // إضافة خط الربط (عدا آخر مرحلة)
      if (i < totalSteps - 1) {
        widgets.add(_buildConnectingLine(i));
      }
    }

    return widgets;
  }

  Widget _buildStepCircle(int stepIndex) {
    final bool isCompleted = stepIndex < currentStep;
    final bool isActive = stepIndex == currentStep;
    final bool isInactive = stepIndex > currentStep;

    Color circleColor;
    Color textColor;
    Widget icon;

    if (isCompleted) {
      circleColor = AppColors.stepCompleted;
      textColor = Colors.white;
      icon = const Icon(Icons.check, color: Colors.white, size: 20);
    } else if (isActive) {
      circleColor = AppColors.stepActive;
      textColor = Colors.white;
      icon = Text(
        '${stepIndex + 1}',
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      circleColor = AppColors.stepInactive;
      textColor = AppColors.textSecondary;
      icon = Text(
        '${stepIndex + 1}',
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimensions.stepIndicatorSize,
          height: AppDimensions.stepIndicatorSize,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isInactive ? AppColors.borderPrimary : circleColor,
              width: AppDimensions.borderWidth,
            ),
          ),
          child: Center(child: icon),
        ),
        if (stepLabels != null && stepIndex < stepLabels!.length) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            stepLabels![stepIndex],
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.stepActive : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildConnectingLine(int stepIndex) {
    final bool isCompleted = stepIndex < currentStep;
    final Color lineColor = isCompleted
        ? AppColors.stepCompleted
        : AppColors.stepInactive;

    return Container(
      width: AppDimensions.stepIndicatorSpacing,
      height: AppDimensions.stepLineHeight,
      margin: const EdgeInsets.only(bottom: 20), // لرفع الخط عن النص
      decoration: BoxDecoration(
        color: lineColor,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
