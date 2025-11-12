/// Complaint Model
class Complaint {
  final String id;
  final String ref;
  final String reporterName;
  final String contactNumber;
  final String address;
  final String complaintType;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  Complaint({
    required this.id,
    required this.ref,
    required this.reporterName,
    required this.contactNumber,
    required this.address,
    required this.complaintType,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['_id'] ?? json['id'] ?? '',
      ref: json['ref'] ?? '',
      reporterName: json['reporterName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      complaintType: json['complaintType'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ref': ref,
      'reporterName': reporterName,
      'contactNumber': contactNumber,
      'address': address,
      'complaintType': complaintType,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
}
