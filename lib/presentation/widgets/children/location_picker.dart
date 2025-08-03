import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

class LocationPicker extends StatefulWidget {
  final String? currentLocation;
  final Function(String) onLocationSelected;
  final String? errorText;

  const LocationPicker({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
    this.errorText,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  bool _isLoadingLocation = false;
  String? _locationError;

  // إحداثيات وهمية لمنطقة الرياض للاختبار على الويب
  static const double _mockLatitude = 24.7136;
  static const double _mockLongitude = 46.6753;
  static const String _mockLocationName = "الرياض، حي العليا، طريق الملك فهد";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // التسمية
        const Text(
          'موقع الطفل',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),

        // بطاقة جلب الموقع
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.errorText != null
                  ? AppColors.error
                  : AppColors.borderPrimary,
              width: AppDimensions.borderWidth,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            color: AppColors.surface,
          ),
          child: InkWell(
            onTap: _isLoadingLocation ? null : _getCurrentLocation,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                children: [
                  // أيقونة الموقع
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: AppDimensions.iconSize,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),

                  // النص والحالة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentLocation ?? 'اضغط لجلب الموقع الحالي',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: widget.currentLocation != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (kIsWeb && widget.currentLocation == null) ...[
                          const SizedBox(height: 4),
                          const Text(
                            '(سيتم استخدام موقع تجريبي للاختبار)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.info,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (_locationError != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _locationError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // مؤشر التحميل أو أيقونة GPS
                  if (_isLoadingLocation)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  else
                    Icon(
                      kIsWeb ? Icons.pin_drop : Icons.gps_fixed,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                ],
              ),
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

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      if (kIsWeb) {
        // على الويب: استخدام موقع وهمي للاختبار
        await _getMockLocation();
      } else {
        // على المنصات الأخرى: جلب الموقع الحقيقي
        await _getRealLocation();
      }
    } catch (e) {
      setState(() {
        _locationError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _getMockLocation() async {
    // محاكاة التحميل للمظهر الطبيعي
    await Future.delayed(const Duration(seconds: 1));

    try {
      // محاولة جلب اسم المكان من الإحداثيات الوهمية
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _mockLatitude,
        _mockLongitude,
      );

      String address;
      if (placemarks.isNotEmpty) {
        address = _formatAddress(placemarks.first);
      } else {
        address = _mockLocationName;
      }

      widget.onLocationSelected(address);
    } catch (e) {
      // في حالة فشل geocoding، استخدم الاسم الثابت
      widget.onLocationSelected(_mockLocationName);
    }
  }

  Future<void> _getRealLocation() async {
    // التحقق من الأذونات
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض إذن الموقع');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('تم رفض إذن الموقع نهائياً. يرجى تفعيله من الإعدادات');
    }

    // التحقق من تفعيل خدمة الموقع
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمة الموقع غير مفعلة. يرجى تفعيلها');
    }

    // جلب الموقع الحالي
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    // تحويل الإحداثيات إلى عنوان
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String address = _formatAddress(place);
      widget.onLocationSelected(address);
    } else {
      widget.onLocationSelected('${position.latitude}, ${position.longitude}');
    }
  }

  String _formatAddress(Placemark place) {
    List<String> addressParts = [];

    if (place.street?.isNotEmpty == true) {
      addressParts.add(place.street!);
    }

    if (place.subLocality?.isNotEmpty == true) {
      addressParts.add(place.subLocality!);
    }

    if (place.locality?.isNotEmpty == true) {
      addressParts.add(place.locality!);
    }

    if (place.administrativeArea?.isNotEmpty == true) {
      addressParts.add(place.administrativeArea!);
    }

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : place.name ?? 'موقع غير محدد';
  }
}
