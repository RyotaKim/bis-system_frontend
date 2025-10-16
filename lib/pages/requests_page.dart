import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // added for kDebugMode

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // removed debug print to avoid noise in the console
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the existing content in a Scaffold to provide app chrome and navigation.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        backgroundColor: Colors.green,
        actions: [
          // Debug-only info button to explain the DevTools messages shown during hot-reload/hot-restart.
          if (kDebugMode)
            IconButton(
              tooltip: 'DevTools info',
              icon: const Icon(Icons.info_outline, color: Colors.yellow),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('DevTools / VM service info'),
                      content: const Text(
                        'The development console messages about DevTools / VM service are emitted by Flutter tooling. '
                        'They indicate the debugger/DevTools deep-link was not set in this session and are usually '
                        'benign for web builds or certain runtime configurations. '
                        'If you need deep links for DevTools, run the app with a supported debug configuration or '
                        'use flutter run with proper VM service enabled.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home),
            onPressed: () {
              // Navigate to the resident main page (adjust route if different)
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        // ...existing code...
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters / search row
            Row(
              children: [
                // Status Dropdown
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      hint: const Text('Status'),
                      isExpanded: true,
                      items: ['All', 'Pending', 'Approved', 'Released']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Type Dropdown
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      hint: const Text('Type'),
                      isExpanded: true,
                      items: [
                        'All',
                        'Barangay Clearance',
                        'Business Permit',
                        'Certificate of Indigency'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Date Dropdown
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      hint: const Text('Date'),
                      isExpanded: true,
                      items: ['All', 'Today', 'This Week', 'This Month']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Search Field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search request...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Requests list/table expands to fill available vertical space
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity, // stretch horizontally
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('REFERENCE NUMBER')),
                      DataColumn(label: Text('RESIDENT NAME')),
                      DataColumn(label: Text('REQUEST TYPE')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: [
                      _buildRequestRow(
                        '2023-000012',
                        'Jules Santo Reyes',
                        'Barangay Clearance',
                        'PENDING',
                      ),
                      _buildRequestRow(
                        '2024-000001',
                        'Ashley Prieto',
                        'Certificate of Indigency',
                        'APPROVED',
                      ),
                      _buildRequestRow(
                        '2024-000002',
                        'Mark Abilug',
                        'Business Permit',
                        'RELEASED',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildRequestRow(
    String refNumber,
    String name,
    String type,
    String status,
  ) {
    Color statusColor;
    switch (status) {
      case 'PENDING':
        statusColor = Colors.amber;
        break;
      case 'APPROVED':
        statusColor = Colors.green;
        break;
      case 'RELEASED':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return DataRow(
      cells: [
        DataCell(Text(refNumber)),
        DataCell(Text(name)),
        DataCell(Text(type)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.green),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.green),
              onPressed: () {},
            ),
          ],
        )),
      ],
    );
  }
}
