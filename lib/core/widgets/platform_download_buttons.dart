import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import '../config/app_config.dart';

class PlatformDownloadButtons extends StatelessWidget {
  const PlatformDownloadButtons({super.key});

  // دالة تحميل APK للأندرويد
  Future<void> _downloadAndroidAPK(BuildContext context) async {
    if (kIsWeb) {
      try {
        const String apkUrl = AppConfig.androidAPKUrl;
        
        final html.AnchorElement anchor = html.AnchorElement(href: apkUrl);
        anchor.download = 'msarat-app.apk';
        anchor.target = '_blank'; // فتح في تبويب جديد
        anchor.click();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConfig.androidDownloadMessage),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل التطبيق: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // دالة للتطبيق قريباً على iOS
  void _showIOSComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConfig.iosComingSoonMessage),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // أيقونات التحميل
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // زر Gmail
            _buildGmailButton(context),

            if (kIsWeb) ...[
              const SizedBox(width: 20),
              // زر تحميل Android
              _buildAndroidButton(context),

              const SizedBox(width: 20),
              // زر iOS (معطل)
              _buildIOSButton(context),
            ],
          ],
        ),

        // النصوص التوضيحية
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // نص Gmail
            const SizedBox(
              width: 80,
              child: Text(
                'تسجيل دخول\nبـ Gmail',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            if (kIsWeb) ...[
              const SizedBox(width: 20),
              // نص Android
              const SizedBox(
                width: 80,
                child: Text(
                  'تحميل\nAndroid',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              const SizedBox(width: 20),
              // نص iOS
              const SizedBox(
                width: 80,
                child: Text(
                  'قريباً\niOS',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildGmailButton(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('سيتم تنفيذ هذه الميزة قريباً')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: const CircleBorder(),
          elevation: 4,
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF4285F4), // Google Blue
                Color(0xFFEA4335), // Google Red
                Color(0xFFFBBC05), // Google Yellow
                Color(0xFF34A853), // Google Green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              'G',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidButton(BuildContext context) {
    return Tooltip(
      message: 'تحميل تطبيق Android',
      child: SizedBox(
        width: 80,
        height: 80,
        child: ElevatedButton(
          onPressed: () => _downloadAndroidAPK(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3DDC84), // Android Green
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
          ),
          child: ClipOval(
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/icons/android_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSButton(BuildContext context) {
    return Tooltip(
      message: 'تطبيق iOS قادم قريباً',
      child: SizedBox(
        width: 80,
        height: 80,
        child: ElevatedButton(
          onPressed: () => _showIOSComingSoon(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.grey[600],
            shape: const CircleBorder(),
            elevation: 2,
          ),
          child: ClipOval(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.grey[600]!,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/apple_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
