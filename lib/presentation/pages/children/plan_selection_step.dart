import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';
import '../../widgets/children/wizard_buttons.dart';
import '../../providers/add_child_wizard_provider.dart';

class PlanSelectionStep extends StatefulWidget {
  const PlanSelectionStep({super.key});

  @override
  State<PlanSelectionStep> createState() => _PlanSelectionStepState();
}

class _PlanSelectionStepState extends State<PlanSelectionStep> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddChildWizardProvider>(
      builder: (context, wizardProvider, child) {
        final transportProvider = wizardProvider.transportPlanProvider;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان والوصف
              _buildHeader(),
              const SizedBox(height: AppDimensions.sectionSpacing),

              // نوع الرحلة
              _buildTripTypeSection(wizardProvider),
              const SizedBox(height: AppDimensions.sectionSpacing),

              // نوع الاشتراك
              _buildSubscriptionSection(wizardProvider),
              const SizedBox(height: AppDimensions.sectionSpacing),

              // معاينة نهائية
              if (transportProvider.isSelectionComplete)
                _buildFinalPreview(wizardProvider),

              const SizedBox(height: AppDimensions.paddingLarge),

              // معاينة نهائية
              if (wizardProvider.validateAllSteps())
                _buildFinalPreview(wizardProvider),

              const SizedBox(height: AppDimensions.paddingLarge),

              // أزرار التنقل
              WizardButtons(
                canGoNext: wizardProvider.canGoNext,
                canGoPrevious: wizardProvider.canGoPrevious,
                isLastStep: wizardProvider.isLastStep,
                isLoading: wizardProvider.isLoading,
                onNext: () => wizardProvider.nextStep(),
                onPrevious: () => wizardProvider.previousStep(),
                onSubmit: () async {
                  await wizardProvider.submitRequest();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختيار الخطة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          'اختر نوع الرحلة ونوع الاشتراك المناسب لاحتياجاتك',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTripTypeSection(AddChildWizardProvider wizardProvider) {
    final transportProvider = wizardProvider.transportPlanProvider;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderPrimary,
          width: AppDimensions.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_bus,
                color: AppColors.primary,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              const Text(
                'نوع الرحلة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          ...transportProvider.transportPlans.map((plan) {
            return _buildTripTypeOption(
              plan.planNameArabic,
              transportProvider.selectedTripTypes.contains(plan.planNameArabic),
              () {
                // اختيار خطة واحدة فقط
                wizardProvider.updateTransportPlan(plan.planId);
                wizardProvider.updateTripTypes([plan.planNameArabic]);
              },
            );
          }),

          // معلومة عن أنواع الرحلات
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.paddingMedium),
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 16),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: Text(
                    'اختر نوع الخدمة المناسب لاحتياجاتك - يمكنك اختيار خيار واحد فقط',
                    style: TextStyle(fontSize: 12, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeOption(
    String tripType,
    bool isSelected,
    VoidCallback onTap,
  ) {
    IconData icon;
    String description;

    switch (tripType) {
      case 'ذهاب':
        icon = Icons.arrow_forward;
        description = 'من المنزل إلى المدرسة';
        break;
      case 'عودة':
        icon = Icons.arrow_back;
        description = 'من المدرسة إلى المنزل';
        break;
      case 'ذهاب وعودة':
        icon = Icons.sync_alt;
        description = 'خدمة شاملة - ذهاب وعودة';
        break;
      default:
        icon = Icons.directions_bus;
        description = tripType;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderPrimary,
          width: isSelected
              ? AppDimensions.borderWidthThick
              : AppDimensions.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingMedium,
          ),
          child: Row(
            children: [
              // Radio button
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (value) => onTap(),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              // Icon
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXSmall),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(AddChildWizardProvider wizardProvider) {
    final transportProvider = wizardProvider.transportPlanProvider;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderPrimary,
          width: AppDimensions.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: AppColors.secondary,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              const Text(
                'نوع الاشتراك',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          ...['شهري', 'فصلي', 'سنوي'].map((subType) {
            return _buildSubscriptionOption(
              subType,
              transportProvider.subscriptionType == subType,
              wizardProvider,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOption(
    String subscriptionType,
    bool isSelected,
    AddChildWizardProvider wizardProvider,
  ) {
    IconData icon;
    String description;
    String discount = '';

    switch (subscriptionType) {
      case 'شهري':
        icon = Icons.calendar_view_month;
        description = 'دفع شهري';
        break;
      case 'ترم':
        icon = Icons.calendar_view_week;
        description = 'دفع كل فصل دراسي';
        discount = 'وفر 10%';
        break;
      case 'سنوي':
        icon = Icons.calendar_view_day;
        description = 'دفع سنوي';
        discount = 'وفر 20%';
        break;
      default:
        icon = Icons.payment;
        description = subscriptionType;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.secondary.withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.secondary : AppColors.borderPrimary,
          width: isSelected
              ? AppDimensions.borderWidthThick
              : AppDimensions.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: RadioListTile<String>(
        value: subscriptionType,
        groupValue: wizardProvider.transportPlanProvider.subscriptionType,
        onChanged: (value) {
          if (value != null) {
            wizardProvider.updateSubscriptionType(value);
          }
        },
        title: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.secondary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              subscriptionType,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.secondary : AppColors.textPrimary,
              ),
            ),
            if (discount.isNotEmpty) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: AppDimensions.paddingXSmall / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Text(
                  discount,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        activeColor: AppColors.secondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingXSmall,
        ),
      ),
    );
  }

  Widget _buildFinalPreview(AddChildWizardProvider wizardProvider) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: AppDimensions.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: AppDimensions.iconSize,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              const Text(
                'جاهز للإرسال!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          Text(
            'تم إكمال جميع البيانات المطلوبة. اضغط "إرسال الطلب" لتقديم طلب إضافة ${wizardProvider.childInfo.name} للنقل المدرسي.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.success.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
