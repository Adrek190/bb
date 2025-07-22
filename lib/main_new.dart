import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:student_transport_app/core/themes/app_theme.dart';
import 'package:student_transport_app/presentation/pages/main_navigation_page.dart';
import 'package:student_transport_app/presentation/pages/bills_page.dart';
import 'package:student_transport_app/presentation/pages/complaints_page.dart';
import 'package:student_transport_app/presentation/pages/new_complaint_page.dart';
import 'package:student_transport_app/presentation/pages/ratings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق النقل المدرسي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // دعم اللغة العربية
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'), // Arabic
        Locale('en'), // English
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // الصفحة الرئيسية
      home: const MainNavigationPage(),

      // المسارات
      routes: {
        '/home': (context) => const MainNavigationPage(),
        '/bills': (context) => const BillsPage(),
        '/complaints': (context) => const ComplaintsPage(),
        '/new-complaint': (context) => const NewComplaintPage(),
        '/ratings': (context) => const RatingsPage(),
      },
    );
  }
}
