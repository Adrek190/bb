import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';
import '../../providers/add_child_wizard_provider.dart';
import '../../widgets/children/step_indicator.dart';
import 'child_info_step.dart';
import 'school_info_step.dart';
import 'plan_selection_step.dart';

class AddChildWizardPage extends StatefulWidget {
  const AddChildWizardPage({super.key});

  @override
  State<AddChildWizardPage> createState() => _AddChildWizardPageState();
}

class _AddChildWizardPageState extends State<AddChildWizardPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(AddChildWizardProvider provider) {
    _pageController.animateToPage(
      provider.currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'إضافة ابن جديد',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _handleBackPressed(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: Consumer<AddChildWizardProvider>(
        builder: (context, provider, child) {
          // مزامنة PageController مع المزود
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients &&
                _pageController.page?.round() != provider.currentStep) {
              _onStepChanged(provider);
            }
          });

          return Stack(
            children: [
              Column(
                children: [
                  // Step Indicator
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    color: Colors.white,
                    child: StepIndicator(
                      currentStep: provider.currentStep,
                      totalSteps: 3,
                      stepLabels: const [
                        'معلومات الابن',
                        'معلومات المدرسة',
                        'خطة المواصلات',
                      ],
                    ),
                  ),

                  // Steps Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        ChildInfoStep(),
                        SchoolInfoStep(),
                        PlanSelectionStep(),
                      ],
                    ),
                  ),
                ],
              ),

              // Loading Overlay
              if (provider.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.paddingLarge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: AppDimensions.paddingMedium),
                            Text(
                              'جاري إرسال الطلب...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Error Display
              if (provider.errorMessage != null)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppDimensions.paddingLarge,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            Text(
                              provider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingLarge),
                            ElevatedButton(
                              onPressed: () {
                                provider.clearError();
                              },
                              child: const Text('موافق'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleBackPressed(BuildContext context) {
    final provider = Provider.of<AddChildWizardProvider>(
      context,
      listen: false,
    );

    if (provider.currentStep > 0) {
      provider.previousStep();
      _onStepChanged(provider);
    } else {
      _showExitDialog(context);
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'إلغاء إضافة الابن',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في إلغاء عملية إضافة الابن؟\nسيتم فقدان جميع البيانات المدخلة.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'الاستمرار',
                style: TextStyle(color: AppColors.primary, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close wizard
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.error, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
