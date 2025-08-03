import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';
import '../../widgets/children/custom_dropdown_field.dart';
import '../../widgets/children/time_picker_field.dart';
import '../../widgets/children/work_days_selector.dart';
import '../../widgets/children/wizard_buttons.dart';
import '../../providers/add_child_wizard_provider.dart';

class SchoolInfoStep extends StatefulWidget {
  const SchoolInfoStep({super.key});

  @override
  State<SchoolInfoStep> createState() => _SchoolInfoStepState();
}

class _SchoolInfoStepState extends State<SchoolInfoStep> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddChildWizardProvider>(
      builder: (context, provider, child) {
        final schoolInfo = provider.schoolInfo;

        return SingleChildScrollView(
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

              // مؤشر التحميل العام
              if (provider.isLoading && provider.cities.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Text(
                        'جاري تحميل البيانات...',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

              // اختيار المدينة
              CustomDropdownField(
                label: 'المدينة',
                hint: provider.isLoading
                    ? 'جاري تحميل المدن...'
                    : provider.cities.isEmpty
                    ? 'لا توجد مدن متاحة'
                    : 'اختر المدينة',
                items: provider.cities.map((city) => city.cityName).toList(),
                selectedValue:
                    provider.cities
                        .where((city) => city.cityId == schoolInfo.cityId)
                        .isNotEmpty
                    ? provider.cities
                          .firstWhere(
                            (city) => city.cityId == schoolInfo.cityId,
                          )
                          .cityName
                    : null,
                onChanged: (cityName) {
                  if (!provider.isLoading && cityName != null) {
                    final selectedCity = provider.cities.firstWhere(
                      (city) => city.cityName == cityName,
                    );
                    provider.updateSchoolCity(selectedCity.cityId);
                    provider.updateDistrictsForCity(selectedCity.cityId);
                  }
                },
                prefixIcon: Icons.location_city,
                enabled: !provider.isLoading && provider.cities.isNotEmpty,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // اختيار الحي
              CustomDropdownField(
                label: 'الحي',
                hint: schoolInfo.cityId == null
                    ? 'يرجى اختيار المدينة أولاً'
                    : provider.isLoading
                    ? 'جاري تحميل الأحياء...'
                    : provider.districts.isEmpty
                    ? 'لا توجد أحياء متاحة'
                    : 'اختر الحي',
                items: provider.districts
                    .map((district) => district.districtName)
                    .toList(),
                selectedValue:
                    provider.districts
                        .where(
                          (district) =>
                              district.districtId == schoolInfo.districtId,
                        )
                        .isNotEmpty
                    ? provider.districts
                          .firstWhere(
                            (district) =>
                                district.districtId == schoolInfo.districtId,
                          )
                          .districtName
                    : null,
                onChanged: (districtName) {
                  if (schoolInfo.cityId != null &&
                      !provider.isLoading &&
                      districtName != null) {
                    final selectedDistrict = provider.districts.firstWhere(
                      (district) => district.districtName == districtName,
                    );
                    provider.updateSchoolDistrict(selectedDistrict.districtId);
                    provider.updateSchoolsForDistrict(
                      selectedDistrict.districtId,
                    );
                  }
                },
                prefixIcon: Icons.place,
                enabled:
                    schoolInfo.cityId != null &&
                    !provider.isLoading &&
                    provider.districts.isNotEmpty,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // اختيار المدرسة
              CustomDropdownField(
                label: 'المدرسة',
                hint: schoolInfo.districtId == null
                    ? 'يرجى اختيار الحي أولاً'
                    : provider.isLoading
                    ? 'جاري تحميل المدارس...'
                    : provider.schools.isEmpty
                    ? 'لا توجد مدارس متاحة'
                    : 'اختر المدرسة',
                items: provider.schools
                    .map((school) => school.schoolName)
                    .toList(),
                selectedValue:
                    provider.schools
                        .where(
                          (school) => school.schoolId == schoolInfo.schoolId,
                        )
                        .isNotEmpty
                    ? provider.schools
                          .firstWhere(
                            (school) => school.schoolId == schoolInfo.schoolId,
                          )
                          .schoolName
                    : null,
                onChanged: (schoolName) {
                  if (schoolInfo.districtId != null &&
                      !provider.isLoading &&
                      schoolName != null) {
                    final selectedSchool = provider.schools.firstWhere(
                      (school) => school.schoolName == schoolName,
                    );
                    provider.updateSchoolName(selectedSchool.schoolId);
                  }
                },
                prefixIcon: Icons.school,
                enabled:
                    schoolInfo.districtId != null &&
                    !provider.isLoading &&
                    provider.schools.isNotEmpty,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // أوقات الدراسة
              _buildTimeSection(provider),
              const SizedBox(height: AppDimensions.sectionSpacing),

              // أيام الدراسة
              WorkDaysSelector(
                selectedDays: schoolInfo.studyDays,
                onDaysChanged: (days) {
                  provider.updateStudyDays(days);
                },
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),

              // معلومات إضافية
              _buildSchedulePreview(provider),
              const SizedBox(height: AppDimensions.sectionSpacing),

              // أزرار التنقل
              WizardButtons(
                canGoNext: provider.canGoNext,
                canGoPrevious: provider.canGoPrevious,
                onNext: provider.canGoNext ? provider.nextStep : null,
                onPrevious: provider.canGoPrevious
                    ? provider.previousStep
                    : null,
                isLastStep: provider.isLastStep,
                isLoading: provider.isLoading,
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
        Text(
          'معلومات المدرسة',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          'أدخل تفاصيل المدرسة وأوقات الدراسة',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTimeSection(AddChildWizardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أوقات الدراسة',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Row(
          children: [
            Expanded(
              child: TimePickerField(
                label: 'وقت الذهاب',
                selectedTime: provider.schoolInfo.entryTime,
                onTimeSelected: (time) {
                  if (time != null) {
                    provider.updateEntryTime(time);
                  }
                },
                prefixIcon: Icons.access_time,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: TimePickerField(
                label: 'وقت العودة',
                selectedTime: provider.schoolInfo.exitTime,
                onTimeSelected: (time) {
                  if (time != null) {
                    provider.updateExitTime(time);
                  }
                },
                prefixIcon: Icons.access_time_filled,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSchedulePreview(AddChildWizardProvider provider) {
    final schoolInfo = provider.schoolInfo;

    if (!schoolInfo.isComplete) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الجدولة',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildPreviewRow(
            'المدينة',
            _getCityName(provider, schoolInfo.cityId),
          ),
          _buildPreviewRow(
            'الحي',
            _getDistrictName(provider, schoolInfo.districtId),
          ),
          _buildPreviewRow(
            'المدرسة',
            _getSchoolName(provider, schoolInfo.schoolId),
          ),
          _buildPreviewRow(
            'الأوقات',
            '${_formatTime(schoolInfo.entryTime)} - ${_formatTime(schoolInfo.exitTime)}',
          ),
          _buildPreviewRow('أيام الدراسة', schoolInfo.studyDays.join('، ')),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingXSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getCityName(AddChildWizardProvider provider, String? cityId) {
    if (cityId == null) return '';
    try {
      return provider.cities
          .firstWhere((city) => city.cityId == cityId)
          .cityName;
    } catch (e) {
      return '';
    }
  }

  String _getDistrictName(AddChildWizardProvider provider, String? districtId) {
    if (districtId == null) return '';
    try {
      return provider.districts
          .firstWhere((district) => district.districtId == districtId)
          .districtName;
    } catch (e) {
      return '';
    }
  }

  String _getSchoolName(AddChildWizardProvider provider, String? schoolId) {
    if (schoolId == null) return '';
    try {
      return provider.schools
          .firstWhere((school) => school.schoolId == schoolId)
          .schoolName;
    } catch (e) {
      return '';
    }
  }
}
