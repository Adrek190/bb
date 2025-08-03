import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_drawer.dart';
import '../providers/notifications_provider.dart';
import 'home_page.dart';
import 'children_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import '../../core/themes/app_colors.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _notificationsTimer;

  List<Widget> get _pages => [
    const HomePage(),
    const ChildrenPage(),
    NotificationsPage(
      onNavigateToChildren: () {
        setState(() {
          _currentIndex = 1; // الانتقال لتبويب الأطفال
        });
      },
    ),
    const ProfilePage(),
  ];

  final List<String> _titles = [
    'الرئيسية',
    'الأبناء',
    'الإشعارات',
    'الملف الشخصي',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // تحميل الإشعارات عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications();
    });

    // تحديث دوري للإشعارات كل 30 ثانية
    _notificationsTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<NotificationsProvider>().loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notificationsTimer?.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_currentIndex],
        showUserIcon: true,
        showMenuButton: true, // إظهار زر القائمة في الشريط العلوي
      ),
      drawer: const AppDrawer(), // إضافة القائمة الجانبية
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.normal,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_add_outlined),
              activeIcon: Icon(Icons.person_add),
              label: 'إضافة ابن',
            ),
            BottomNavigationBarItem(
              icon: Consumer<NotificationsProvider>(
                builder: (context, notificationsProvider, child) {
                  return Badge(
                    isLabelVisible: notificationsProvider.unreadCount > 0,
                    label: Text(
                      '${notificationsProvider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.notifications_outlined),
                  );
                },
              ),
              activeIcon: Consumer<NotificationsProvider>(
                builder: (context, notificationsProvider, child) {
                  return Badge(
                    isLabelVisible: notificationsProvider.unreadCount > 0,
                    label: Text(
                      '${notificationsProvider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.notifications),
                  );
                },
              ),
              label: 'الإشعارات',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'الملف الشخصي',
            ),
          ],
        ),
      ),
    );
  }
}
