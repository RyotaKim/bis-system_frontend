import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../models/document_type_model.dart';
import '../services/request_service.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  final RequestService _requestService = RequestService();

  // State variables
  List<Request> _allRequests = [];
  List<Request> _filteredRequests = [];
  Map<String, DocumentType> _documentTypes = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Filter values
  String _selectedStatus = 'All';
  String _selectedType = 'All';
  String _selectedDate = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch requests and document types in parallel
      final results = await Future.wait([
        _requestService.getRequests(),
        _requestService.getDocumentTypes(),
      ]);

      final requestsData = results[0];
      final docTypesData = results[1];

      // Debug: Print response structure
      print('=== DEBUG INFO ===');
      print('Requests data type: ${requestsData.runtimeType}');
      print('Requests data length: ${requestsData.length}');
      print('Requests raw data: $requestsData');
      print('DocTypes data type: ${docTypesData.runtimeType}');
      print('DocTypes data length: ${docTypesData.length}');
      print('DocTypes raw data: $docTypesData');
      print('=================');

      // Convert to models
      final requests = <Request>[];
      for (var json in requestsData) {
        try {
          requests.add(Request.fromJson(json));
        } catch (e) {
          print('Error parsing request: $e');
          print('Request data: $json');
        }
      }

      final docTypes = <DocumentType>[];
      for (var json in docTypesData) {
        try {
          docTypes.add(DocumentType.fromJson(json));
        } catch (e) {
          print('Error parsing document type: $e');
          print('DocType data: $json');
        }
      }

      print('Parsed requests count: ${requests.length}');
      print('Parsed docTypes count: ${docTypes.length}');

      // Debug: Print IDs for matching
      if (requests.isNotEmpty) {
        print('Sample request docTypeId: ${requests.first.docTypeId}');
      }
      if (docTypes.isNotEmpty) {
        print('Sample docType id: ${docTypes.first.id}');
        print('All docType IDs: ${docTypes.map((dt) => dt.id).toList()}');
      }

      // Create a map for quick lookup
      final docTypeMap = {for (var dt in docTypes) dt.id: dt};

      setState(() {
        _allRequests = requests;
        _filteredRequests = requests;
        _documentTypes = docTypeMap;
        _isLoading = false;
      });

      // Show info message if no data
      if (requests.isEmpty && !mounted) return;
      if (requests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No requests found in database. Try creating some requests first.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      final errorMsg = e.toString();
      print('Load data error: $errorMsg');

      setState(() {
        if (errorMsg.contains('Cannot GET') || errorMsg.contains('Not Found')) {
          _errorMessage = 'Backend endpoint not found.\n\n'
              'Please verify:\n'
              '1. Backend is running on http://localhost:3000\n'
              '2. Endpoint /api/admin/requests exists\n'
              '3. You are logged in as admin\n\n'
              'Error: $errorMsg';
        } else if (errorMsg.contains('Unauthorized')) {
          _errorMessage = 'Authentication required.\n\n'
              'Please log in as an admin user to view requests.\n\n'
              'Error: $errorMsg';
        } else {
          _errorMessage = 'Failed to load requests:\n$errorMsg';
        }
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredRequests = _allRequests.where((request) {
        // Status filter
        if (_selectedStatus != 'All') {
          final statusMatch =
              request.status.toLowerCase() == _selectedStatus.toLowerCase();
          if (!statusMatch) return false;
        }

        // Type filter
        if (_selectedType != 'All') {
          final docType = _documentTypes[request.docTypeId];
          if (docType == null || docType.name != _selectedType) {
            return false;
          }
        }

        // Date filter
        if (_selectedDate != 'All') {
          final now = DateTime.now();
          final requestDate = request.createdAt;

          switch (_selectedDate) {
            case 'Today':
              if (!_isSameDay(requestDate, now)) return false;
              break;
            case 'This Week':
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              if (requestDate.isBefore(weekStart)) return false;
              break;
            case 'This Month':
              if (requestDate.month != now.month ||
                  requestDate.year != now.year) {
                return false;
              }
              break;
          }
        }

        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        if (searchQuery.isNotEmpty) {
          final matchesSearch =
              request.ref.toLowerCase().contains(searchQuery) ||
                  request.fullName.toLowerCase().contains(searchQuery) ||
                  request.contactNumber.contains(searchQuery);
          if (!matchesSearch) return false;
        }

        return true;
      }).toList();
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Requests'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                value: _selectedStatus,
                                isExpanded: true,
                                items: [
                                  'All',
                                  'Pending',
                                  'Approved',
                                  'Rejected'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatus = value ?? 'All';
                                    _applyFilters();
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Type Dropdown
                          Container(
                            width: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                value: _selectedType,
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem(
                                    value: 'All',
                                    child: Text('All Types'),
                                  ),
                                  ..._documentTypes.values.map((docType) {
                                    return DropdownMenuItem(
                                      value: docType.name,
                                      child: Text(docType.name),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value ?? 'All';
                                    _applyFilters();
                                  });
                                },
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                value: _selectedDate,
                                isExpanded: true,
                                items: [
                                  'All',
                                  'Today',
                                  'This Week',
                                  'This Month'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDate = value ?? 'All';
                                    _applyFilters();
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Search Field
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search by ref, name, or contact...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onChanged: (value) => _applyFilters(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Results count
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Showing ${_filteredRequests.length} of ${_allRequests.length} requests',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Requests list/table expands to fill available vertical space
                      Expanded(
                        child: _filteredRequests.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No requests found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(
                                          label: Text('REFERENCE NUMBER')),
                                      DataColumn(label: Text('RESIDENT NAME')),
                                      DataColumn(label: Text('REQUEST TYPE')),
                                      DataColumn(label: Text('DATE')),
                                      DataColumn(label: Text('STATUS')),
                                      DataColumn(label: Text('ACTIONS')),
                                    ],
                                    rows: _filteredRequests
                                        .map((request) =>
                                            _buildRequestRow(request))
                                        .toList(),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  DataRow _buildRequestRow(Request request) {
    // Get document type name
    final docType = _documentTypes[request.docTypeId];
    final docTypeName = docType?.name ?? 'Unknown';

    // Determine status color
    Color statusColor;
    String statusText = request.status.toUpperCase();

    switch (request.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.amber;
        statusText = 'PENDING';
        break;
      case 'approved':
        statusColor = Colors.green;
        statusText = 'APPROVED';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'REJECTED';
        break;
      default:
        statusColor = Colors.grey;
    }

    // Format date
    final formattedDate = '${request.createdAt.year}-'
        '${request.createdAt.month.toString().padLeft(2, '0')}-'
        '${request.createdAt.day.toString().padLeft(2, '0')} '
        '${request.createdAt.hour.toString().padLeft(2, '0')}:'
        '${request.createdAt.minute.toString().padLeft(2, '0')}';

    return DataRow(
      cells: [
        DataCell(Text(request.ref)),
        DataCell(Text(request.fullName)),
        DataCell(Text(docTypeName)),
        DataCell(Text(formattedDate)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _viewRequest(request),
              tooltip: 'View',
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _editRequest(request),
              tooltip: 'Edit Status',
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRequest(request),
              tooltip: 'Delete',
              iconSize: 20,
            ),
          ],
        )),
      ],
    );
  }

  void _viewRequest(Request request) {
    final docType = _documentTypes[request.docTypeId];
    final hasImage =
        request.idImageUrl != null && request.idImageUrl!.isNotEmpty;
    final imageUrl =
        hasImage ? 'http://localhost:3000${request.idImageUrl}' : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Details - ${request.ref}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Full Name', request.fullName),
              _buildDetailRow('Contact Number', request.contactNumber),
              _buildDetailRow('Address', request.address),
              _buildDetailRow('Purpose', request.purpose),
              _buildDetailRow('Age', request.age.toString()),
              _buildDetailRow('Marital Status', request.maritalStatus),
              if (request.eduAttainment != null &&
                  request.eduAttainment!.isNotEmpty)
                _buildDetailRow('Education', request.eduAttainment!),
              if (request.eduCourse != null && request.eduCourse!.isNotEmpty)
                _buildDetailRow('Course', request.eduCourse!),
              _buildDetailRow('Document Type', docType?.name ?? 'Unknown'),
              _buildDetailRow('Status', request.status.toUpperCase()),
              _buildDetailRow(
                'Created',
                request.createdAt.toString().split('.').first,
              ),
              _buildDetailRow(
                'Last Updated',
                request.updatedAt.toString().split('.').first,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              // Uploaded ID Image Section
              Row(
                children: [
                  const Text(
                    'Uploaded ID:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (hasImage)
                    TextButton.icon(
                      onPressed: () => _viewImage(imageUrl!),
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text('View Image'),
                    )
                  else
                    const Text(
                      'No image uploaded',
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
              if (hasImage) ...[
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          padding: const EdgeInsets.all(32),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (hasImage)
            TextButton.icon(
              onPressed: () => _downloadImage(imageUrl!),
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Uploaded ID Image'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadImage(imageUrl),
                  tooltip: 'Download',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      padding: const EdgeInsets.all(64),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadImage(String imageUrl) {
    // For web, open in new tab
    // For mobile, would need to save to device
    try {
      // Import dart:html for web or use url_launcher package
      // For now, just open in new tab
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Opening image in new tab...'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      // You can use url_launcher package: launch(imageUrl)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editRequest(Request request) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus = request.status;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Update Request Status - ${request.ref}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Status: ${request.status.toUpperCase()}'),
                const SizedBox(height: 16),
                const Text('Select New Status:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ['pending', 'approved', 'rejected']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value ?? selectedStatus;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _updateRequestStatus(request.id, selectedStatus);
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _requestService.updateRequestStatus(requestId, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request status updated to ${newStatus.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload data
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteRequest(Request request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this request?'),
            const SizedBox(height: 8),
            Text(
              'Reference: ${request.ref}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Name: ${request.fullName}'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performDelete(request);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Request request) async {
    try {
      await _requestService.deleteRequest(request.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request ${request.ref} deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload data
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
