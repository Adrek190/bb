import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

class ChildImagePicker extends StatefulWidget {
  final File? selectedImage;
  final Function(File?) onImageSelected;
  final double size;

  const ChildImagePicker({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
    this.size = AppDimensions.avatarSize,
  });

  @override
  State<ChildImagePicker> createState() => _ChildImagePickerState();
}

class _ChildImagePickerState extends State<ChildImagePicker> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _showImagePickerOptions,
        child: Stack(
          children: [
            // الدائرة الرئيسية للصورة
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.borderPrimary,
                  width: AppDimensions.borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.size / 2),
                child: widget.selectedImage != null
                    ? Image.file(
                        widget.selectedImage!,
                        width: widget.size,
                        height: widget.size,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.person,
                        size: widget.size * 0.5,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
            // أيقونة الكاميرا الصفراء
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: widget.size * 0.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (widget.selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('حذف الصورة'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onImageSelected(null);
                },
              ),
            const SizedBox(height: AppDimensions.paddingMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        widget.onImageSelected(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصورة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
