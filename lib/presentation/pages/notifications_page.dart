import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_drawer.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'الاشعارات'),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          'لا توجد اشعارات جديدة',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
