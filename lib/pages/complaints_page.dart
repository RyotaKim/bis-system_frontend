import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final ComplaintService _complaintService = ComplaintService();

  // State variables
  List<Complaint> _allComplaints = [];
  List<Complaint> _filteredComplaints = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter variables
  String _statusFilter = 'All';
  String _typeFilter = 'All';
  String _dateFilter = 'All';
  String _searchQuery = '';

  // Form controllers for encoding new complaint
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  String _selectedType = 'Noise';

  // Complaint types
  final List<String> _complaintTypes = [
    'Noise',
    'Garbage',
    'Vandalism',
    'Animal',
    'Property',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  /// Load complaints from backend
  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _complaintService.getComplaints();
      final complaints =
          (response as List).map((json) => Complaint.fromJson(json)).toList();

      setState(() {
        _allComplaints = complaints;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Apply filters to complaints list
  void _applyFilters() {
    List<Complaint> filtered = List.from(_allComplaints);

    // Status filter
    if (_statusFilter != 'All') {
      filtered = filtered
          .where((c) => c.status.toLowerCase() == _statusFilter.toLowerCase())
          .toList();
    }

    // Type filter
    if (_typeFilter != 'All') {
      filtered = filtered
          .where(
              (c) => c.complaintType.toLowerCase() == _typeFilter.toLowerCase())
          .toList();
    }

    // Date filter
    if (_dateFilter != 'All') {
      final now = DateTime.now();
      filtered = filtered.where((c) {
        switch (_dateFilter) {
          case 'Today':
            return c.createdAt.year == now.year &&
                c.createdAt.month == now.month &&
                c.createdAt.day == now.day;
          case 'This Week':
            final weekAgo = now.subtract(const Duration(days: 7));
            return c.createdAt.isAfter(weekAgo);
          case 'This Month':
            return c.createdAt.year == now.year &&
                c.createdAt.month == now.month;
          default:
            return true;
        }
      }).toList();
    }

    // Search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        return c.ref.toLowerCase().contains(query) ||
            c.reporterName.toLowerCase().contains(query) ||
            c.complaintType.toLowerCase().contains(query) ||
            c.description.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _filteredComplaints = filtered;
    });
  }

  /// Encode new complaint
  Future<void> _encodeComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final complaintData = {
        'reporterName': _nameCtrl.text.trim(),
        'contactNumber': _contactCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'complaintType': _selectedType,
        'description': _descriptionCtrl.text.trim(),
      };

      await _complaintService.createComplaint(complaintData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint encoded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        _nameCtrl.clear();
        _contactCtrl.clear();
        _addressCtrl.clear();
        _descriptionCtrl.clear();
        setState(() {
          _selectedType = 'Noise';
        });

        // Reload complaints
        _loadComplaints();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to encode complaint: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// View complaint details
  void _viewComplaint(Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Complaint Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Reference Number', complaint.ref),
                          _buildDetailRow(
                              'Reporter Name', complaint.reporterName),
                          _buildDetailRow(
                              'Contact Number', complaint.contactNumber),
                          _buildDetailRow('Address', complaint.address),
                          _buildDetailRow(
                              'Complaint Type', complaint.complaintType),
                          _buildDetailRow('Status', complaint.status,
                              valueColor: _getStatusColor(complaint.status)),
                          _buildDetailRow(
                            'Date Filed',
                            DateFormat('MMM dd, yyyy - hh:mm a')
                                .format(complaint.createdAt),
                          ),
                          if (complaint.resolvedAt != null)
                            _buildDetailRow(
                              'Date Resolved',
                              DateFormat('MMM dd, yyyy - hh:mm a')
                                  .format(complaint.resolvedAt!),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Description:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              complaint.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Edit complaint status
  void _editComplaintStatus(Complaint complaint) {
    String selectedStatus = complaint.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Complaint Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reference: ${complaint.ref}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['pending', 'in_progress', 'resolved']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _complaintService.updateComplaintStatus(
                    complaint.id,
                    selectedStatus,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadComplaints();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update status: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  /// Delete complaint
  void _deleteComplaint(Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Complaint'),
        content:
            Text('Are you sure you want to delete complaint ${complaint.ref}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _complaintService.deleteComplaint(complaint.id);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complaint deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadComplaints();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete complaint: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
                fontWeight:
                    valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Complaints Management',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadComplaints,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Encode New Complaint Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Encode New Complaint',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Complainant Name Field
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Complainant Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Contact Number Field
                  TextFormField(
                    controller: _contactCtrl,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Contact number is required'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Address Field
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Complaint Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Complaint Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _complaintTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Description Field
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 4,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _encodeComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Encode Complaint',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // View Complaints Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'View Complaints',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Filters Row
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Search
                    SizedBox(
                      width: 250,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),

                    // Status Filter
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: ['All', 'Pending', 'In_Progress', 'Resolved']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.replaceAll('_', ' ')),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),

                    // Type Filter
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: _typeFilter,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: ['All', ..._complaintTypes]
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _typeFilter = value!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),

                    // Date Filter
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: _dateFilter,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: ['All', 'Today', 'This Week', 'This Month']
                            .map((date) => DropdownMenuItem(
                                  value: date,
                                  child: Text(date),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _dateFilter = value!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Results count
                Text(
                  'Showing ${_filteredComplaints.length} of ${_allComplaints.length} complaints',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),

                // Complaints Table
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Error: $_errorMessage',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadComplaints,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                else if (_filteredComplaints.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        'No complaints found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 250,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.green.shade50,
                          ),
                          columnSpacing: 24,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 64,
                          columns: const [
                            DataColumn(label: Text('Reference No.')),
                            DataColumn(label: Text('Reporter Name')),
                            DataColumn(label: Text('Complaint Type')),
                            DataColumn(label: Text('Date Filed')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _filteredComplaints
                              .map((complaint) => _buildComplaintRow(complaint))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildComplaintRow(Complaint complaint) {
    return DataRow(
      cells: [
        DataCell(Text(complaint.ref)),
        DataCell(Text(complaint.reporterName)),
        DataCell(Text(complaint.complaintType)),
        DataCell(Text(DateFormat('MMM dd, yyyy').format(complaint.createdAt))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(complaint.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(complaint.status),
                width: 1,
              ),
            ),
            child: Text(
              complaint.status.toUpperCase().replaceAll('_', ' '),
              style: TextStyle(
                color: _getStatusColor(complaint.status),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () => _viewComplaint(complaint),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => _editComplaintStatus(complaint),
                tooltip: 'Edit Status',
              ),
              if (complaint.status.toLowerCase() == 'resolved')
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteComplaint(complaint),
                  tooltip: 'Delete',
                ),
            ],
          ),
        ),
      ],
    );
  }
}
