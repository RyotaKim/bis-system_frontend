import 'package:flutter/material.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  // In-memory complaints list including date (ISO string)
  final List<Map<String, dynamic>> _data = List.generate(
    50,
    (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      return {
        'refNo': 'RN${1000 + index}',
        'name': 'Resident ${index + 1}',
        'type': 'Noise',
        'status': index % 2 == 0 ? 'Resolved' : 'Pending',
        'date': date.toIso8601String(),
      };
    },
  );

  // Form controllers for encoding new complaint
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  String _selectedType = 'Noise';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make the whole page scrollable to avoid RenderFlex overflow
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complaints Management',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Encode New Complaint section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Encode New Complaint',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Complainant Name Field (added)
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Complainant Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.green.shade300, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Complaint Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Complaint Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.green.shade300, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  items: <String>[
                    'Noise',
                    'Illegal Parking',
                    'Stray Animals',
                    'Other'
                  ]
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedType = value);
                  },
                  isExpanded: true,
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.green.shade300, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle submit complaint and encode current date
                      if (_formKey.currentState == null) {
                        // use a short inline form validation & submission
                        if ((_nameCtrl.text.isEmpty) ||
                            (_descriptionCtrl.text.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill required fields'),
                                backgroundColor: Colors.orange),
                          );
                          return;
                        }
                      }
                      if (_formKey.currentState?.validate() ?? true) {
                        final isoDate = DateTime.now().toIso8601String();
                        setState(() {
                          _data.insert(0, {
                            'refNo': 'RN${1000 + _data.length}',
                            'name': _nameCtrl.text.isNotEmpty
                                ? _nameCtrl.text
                                : 'Anonymous',
                            'type': _selectedType,
                            'status': 'Pending',
                            'description': _descriptionCtrl.text,
                            'date': isoDate,
                          });
                        });

                        // Clear form
                        _nameCtrl.clear();
                        _descriptionCtrl.clear();
                        _selectedType = 'Noise';

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Complaint submitted successfully on ${DateTime.parse(isoDate).toLocal().toString().split('.').first}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Complaint',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Complaints Table — give it a bounded height and let the outer scroll view handle overflow
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  source: ComplaintsDataSource(_data),
                  columns: const [
                    DataColumn(
                        label: Text('Ref. No.',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Resident Name',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Type',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Date',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  columnSpacing: 24,
                  horizontalMargin: 24,
                  rowsPerPage: 5,
                  showFirstLastButtons: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ComplaintsDataSource now accepts data from parent state and displays date
class ComplaintsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  ComplaintsDataSource(this._data);

  @override
  DataRow getRow(int index) {
    final item = _data[index];
    final dateStr = item['date'] ?? '';
    final formattedDate = dateStr.isNotEmpty
        ? DateTime.parse(dateStr).toLocal().toString().split('.').first
        : 'Unknown';

    return DataRow(cells: [
      DataCell(Text(item['refNo'] ?? '-')),
      DataCell(Text(item['name'] ?? '-')),
      DataCell(Text(item['type'] ?? '-')),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: item['status'] == 'Resolved'
                ? Colors.green.shade100
                : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item['status'] ?? '-',
            style: TextStyle(
              color: item['status'] == 'Resolved'
                  ? Colors.green.shade800
                  : Colors.orange.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      DataCell(Text(formattedDate)), // show formatted date
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
