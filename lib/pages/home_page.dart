import 'package:flutter/material.dart';
import 'complaints_page.dart';
import 'requests_page.dart';
import 'dashboard_page.dart';
import 'reports_analytics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Updated to include RequestsPage in the navigation
  final List<String> _navItems = [
    'Dashboard',
    'Requests',
    'Complaints',
    'Reports and Analytics',
  ];

  // Get current page based on selected index
  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1: // Requests tab
        return const RequestsPage();
      case 2: // Complaints tab
        return const ComplaintsPage();
      case 3: // Reports and Analytics tab
        return const ReportsAnalyticsPage();
      default:
        return Center(child: Text('Coming Soon: ${_navItems[_selectedIndex]}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Column(
        children: [
          // Top banner
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade900, Colors.green.shade700],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Barangay Information System',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    clipBehavior: Clip.hardEdge,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    child: Image.asset(
                      'assets/images/barangay_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.account_balance,
                            color: Colors.green.shade300, size: 48);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body with left nav and main content
          Expanded(
            child: Row(
              children: [
                // Left navigation panel - slightly wider so text fits comfortably
                SizedBox(
                  width: 220, // increased from 180 so long labels don't wrap
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade400],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6)
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final selected = _selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            selected: selected,
                            selectedTileColor:
                                Colors.green.shade900.withOpacity(0.25),
                            leading: Icon(
                              index == 0
                                  ? Icons.dashboard
                                  : index == 1
                                      ? Icons.request_page
                                      : index == 2
                                          ? Icons.report_problem
                                          : Icons.analytics,
                              color: selected ? Colors.white : Colors.white70,
                              size: 24, // increased from 20
                            ),
                            title: Text(
                              _navItems[index],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18, // text larger only
                                color: selected ? Colors.white : Colors.white70,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('${_navItems[index]} selected')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Main content area
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.only(
                        right: 16, top: 16, bottom: 16, left: 8),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8)
                      ],
                    ),
                    child: _getCurrentPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
