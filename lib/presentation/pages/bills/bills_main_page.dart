import 'package:flutter/material.dart';
import 'unpaid_bills_page.dart';
import 'under_review_bills_page.dart';
import 'paid_bills_page.dart';

class BillsMainPage extends StatefulWidget {
  const BillsMainPage({super.key});

  @override
  State<BillsMainPage> createState() => _BillsMainPageState();
}

class _BillsMainPageState extends State<BillsMainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفواتير'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.payment), text: 'غير مدفوعة'),
            Tab(icon: Icon(Icons.hourglass_empty), text: 'تحت المراجعة'),
            Tab(icon: Icon(Icons.check_circle), text: 'مدفوعة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UnpaidBillsPage(),
          UnderReviewBillsPage(),
          PaidBillsPage(),
        ],
      ),
    );
  }
}
