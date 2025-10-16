import 'package:flutter/material.dart';

class ComplaintsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data = List.generate(
    50,
    (index) => {
      'refNo': 'RN${1000 + index}',
      'name': 'Resident ${index + 1}',
      'type': 'Noise',
      'status': index % 2 == 0 ? 'Resolved' : 'Pending',
    },
  );

  @override
  DataRow getRow(int index) {
    final item = _data[index];
    final isResolved = item['status'] == 'Resolved';

    return DataRow(cells: [
      DataCell(Text(item['refNo'])),
      DataCell(Text(item['name'])),
      DataCell(Text(item['type'])),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isResolved ? Colors.green.shade100 : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item['status'],
            style: TextStyle(
              color: isResolved ? Colors.green.shade800 : Colors.orange.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      DataCell(
        Row(
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
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}