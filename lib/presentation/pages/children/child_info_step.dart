import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/gender.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';
import '../../widgets/children/child_image_picker.dart';
import '../../widgets/children/gender_selector.dart';
import '../../widgets/children/custom_dropdown_field.dart';
import '../../widgets/children/location_picker.dart';
import '../../widgets/children/wizard_buttons.dart';
import '../../providers/add_child_wizard_provider.dart';

class ChildInfoStep extends StatefulWidget {
  const ChildInfoStep({super.key});

  @override
  State<ChildInfoStep> createState() => _ChildInfoStepState();
}

class _ChildInfoStepState extends State<ChildInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تحميل البيانات المحفوظة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AddChildWizardProvider>(
        context,
        listen: false,
      );
      _nameController.text = provider.childInfo.name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddChildWizardProvider>(
      builder: (context, provider, child) {
        final childInfo = provider.childInfo;

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان والوصف
                _buildHeader(),
                const SizedBox(height: AppDimensions.sectionSpacing),

                // عرض رسالة خطأ إن وجدت
                if (provider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: AppDimensions.paddingLarge,
                    ),
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                // اختيار صورة الطفل
                ChildImagePicker(
                  selectedImage: childInfo.profileImageFile,
                  onImageSelected: (imageFile) {
                    provider.updateChildImageFile(imageFile);
                  },
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),

                // اختيار الجنس
                GenderSelector(
                  selectedGender:
                      childInfo.gender?.key, // استخدام key بدلاً من name
                  onGenderChanged: (genderString) {
                    if (genderString != null) {
                      final gender = Gender.values.firstWhere(
                        (g) =>
                            g.key == genderString, // استخدام key بدلاً من name
                        orElse: () => Gender.male,
                      );
                      provider.updateChildGender(gender);
                    }
                  },
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),

                // اسم الطفل
                _buildNameField(provider),
                const SizedBox(height: AppDimensions.paddingLarge),

                // موقع الطفل - ويدجت جديد لجلب الموقع
                LocationPicker(
                  currentLocation: childInfo.currentLocation,
                  onLocationSelected: (location) {
                    provider.updateChildCurrentLocation(location);
                  },
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                // المرحلة الدراسية - تم التحديث
                CustomDropdownField(
                  label: 'المرحلة الدراسية',
                  hint: 'اختر المرحلة الدراسية',
                  items: provider.educationLevels
                      .map((level) => level.name)
                      .toList(),
                  selectedValue:
                      provider.educationLevels
                          .where(
                            (level) => level.id == childInfo.educationLevelId,
                          )
                          .isNotEmpty
                      ? provider.educationLevels
                            .firstWhere(
                              (level) => level.id == childInfo.educationLevelId,
                            )
                            .name
                      : null,
                  onChanged: (levelName) {
                    final selectedLevel = provider.educationLevels.firstWhere(
                      (level) => level.name == levelName,
                    );
                    provider.updateChildEducationLevel(selectedLevel.id);
                  },
                  prefixIcon: Icons.school,
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),

                // معلومات إضافية
                _buildInfoCard(),

                const SizedBox(height: AppDimensions.paddingLarge),

                // أزرار التنقل
                WizardButtons(
                  canGoNext: provider.canGoNext,
                  canGoPrevious: provider.canGoPrevious,
                  isLastStep: provider.isLastStep,
                  isLoading: provider.isLoading,
                  onNext: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      provider.nextStep();
                    }
                  },
                  onPrevious: () => provider.previousStep(),
                ),
              ],
            ),
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
          'معلومات الابن',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          'يرجى إدخال المعلومات الأساسية للابن لبدء عملية التسجيل',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(AddChildWizardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اسم الابن',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextFormField(
          controller: _nameController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'أدخل اسم الابن كاملاً',
            hintStyle: const TextStyle(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.person, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.borderPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: AppDimensions.borderWidthThick,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.borderPrimary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingMedium,
            ),
          ),
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال اسم الابن';
            }
            if (value.trim().length < 2) {
              return 'اسم الابن يجب أن يكون أكثر من حرفين';
            }
            return null;
          },
          onChanged: (value) {
            provider.updateChildName(value.trim());
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: AppDimensions.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: AppDimensions.iconSize,
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'معلومة مهمة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXSmall),
                Text(
                  'تأكد من إدخال جميع البيانات بدقة. سيتم استخدام هذه المعلومات في عملية النقل المدرسي.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.info.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
