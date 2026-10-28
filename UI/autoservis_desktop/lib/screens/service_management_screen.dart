import 'package:flutter/material.dart';
import '../layouts/master_screen.dart';
import 'category_list_tab.dart';
import 'part_list_tab.dart';
import 'service_list_tab.dart';

// Service catalog management: services, their categories and the parts they usually need.
class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Upravljanje uslugama',
      section: AppSection.serviceManagement,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Usluge'),
                Tab(text: 'Kategorije'),
                Tab(text: 'Dijelovi'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ServiceListTab(),
                CategoryListTab(),
                PartListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
