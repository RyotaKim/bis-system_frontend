import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/requests_page.dart';
import '../pages/complaints_page.dart';
import '../pages/reports_analytics_page.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const RequestsPage(),
    const ComplaintsPage(),
    const ReportsAnalyticsPage(),
  ];

  void _onDestinationSelected(int index) {
    // Debug: log navigation changes to terminal / DevTools
    debugPrint('Navigation selected: $index');
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Debug: log which page index is currently rendered
    debugPrint('Layout build - current page index: $_selectedIndex');
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width >= 800,
            minExtendedWidth: 200,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.description),
                label: Text('Requests'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning),
                label: Text('Complaints'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Reports and Analytics'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
