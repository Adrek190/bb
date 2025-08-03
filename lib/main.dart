import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_transport_app/core/themes/app_theme.dart';
import 'package:student_transport_app/core/config/supabase_config.dart';
import 'package:student_transport_app/core/services/auth_service.dart';
import 'package:student_transport_app/presentation/pages/main_navigation_page.dart';
import 'package:student_transport_app/presentation/pages/auth/login_page.dart';
import 'package:student_transport_app/presentation/pages/requests_page.dart';
import 'package:student_transport_app/presentation/pages/bills/bills_main_page.dart';
import 'package:student_transport_app/presentation/providers/parent_profile_provider.dart';
import 'package:student_transport_app/presentation/providers/add_child_wizard_provider.dart';
import 'package:student_transport_app/presentation/providers/notifications_provider.dart';
import 'package:student_transport_app/presentation/providers/requests_provider.dart';
import 'package:student_transport_app/presentation/providers/bills_provider.dart';
import 'package:student_transport_app/presentation/providers/subscriptions_provider.dart';
import 'package:student_transport_app/presentation/pages/subscriptions_page.dart';
import 'package:student_transport_app/data/repositories/parent_repository_impl.dart';
import 'package:student_transport_app/data/repositories/notifications_repository_impl.dart';
import 'package:student_transport_app/data/repositories/requests_repository_impl.dart';
import 'package:student_transport_app/data/repositories/bills_repository_impl.dart';

// Global Supabase client للوصول السهل
final supabase = Supabase.instance.client;

Future<void> main() async {
  // تأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  print('🚀 تهيئة Supabase...');
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    print('✅ تم تهيئة Supabase بنجاح');
  } catch (e) {
    print('❌ فشل تهيئة Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Service Provider
        Provider(create: (context) => AuthService()),

        // Parent Profile Provider
        ChangeNotifierProvider(
          create: (context) => ParentProfileProvider(ParentRepositoryImpl()),
        ),

        // Add Child Wizard Provider
        ChangeNotifierProvider(create: (context) => AddChildWizardProvider()),

        // Notifications Provider
        ChangeNotifierProvider(
          create: (context) =>
              NotificationsProvider(NotificationsRepositoryImpl()),
        ),

        // Requests Provider
        ChangeNotifierProvider(
          create: (context) =>
              RequestsProvider(RequestsRepositoryImpl(supabase)),
        ),

        // Bills Provider
        ChangeNotifierProvider(
          create: (context) => BillsProvider(
            billsRepository: BillsRepositoryImpl(),
            authService: context.read<AuthService>(),
          ),
        ),

        // Subscriptions Provider
        ChangeNotifierProvider(create: (context) => SubscriptionsProvider()),
      ],
      child: MaterialApp(
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

        // التحقق من حالة المصادقة والتوجه للصفحة المناسبة
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            return StreamBuilder<AuthState>(
              stream: authService.authStateChanges,
              builder: (context, snapshot) {
                // إذا كان المستخدم مسجل دخول
                if (authService.isSignedIn) {
                  return const MainNavigationPage();
                }
                // إذا لم يكن مسجل دخول
                return const LoginPage();
              },
            );
          },
        ),

        // المسارات
        routes: {
          '/login': (context) => const LoginPage(),
          '/main': (context) => const MainNavigationPage(),
          '/home': (context) => const MainNavigationPage(),
          '/requests': (context) => const RequestsPage(),
          '/bills': (context) => const BillsMainPage(),
          '/subscriptions': (context) => const SubscriptionsPage(),
          '/children': (context) =>
              const MainNavigationPage(), // سيتم توجيه المستخدم لصفحة الأبناء
          '/payment_history': (context) =>
              const BillsMainPage(), // سيتم توجيه المستخدم لصفحة تاريخ المدفوعات
        },
      ),
    );
  }
}
