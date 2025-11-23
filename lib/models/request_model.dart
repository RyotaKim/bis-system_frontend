/// Request Model
class Request {
  final String id;
  final String ref;
  final String lastName;
  final String firstName;
  final String? middleInitial;
  final String contactNumber;
  final String address;
  final String purpose;
  final String? eduAttainment;
  final String? eduCourse;
  final int age;
  final String maritalStatus;
  final String docTypeId;
  final String? idImageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? releasedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final Map<String, dynamic>? approvedByUser;

  Request({
    required this.id,
    required this.ref,
    required this.lastName,
    required this.firstName,
    this.middleInitial,
    required this.contactNumber,
    required this.address,
    required this.purpose,
    this.eduAttainment,
    this.eduCourse,
    required this.age,
    required this.maritalStatus,
    required this.docTypeId,
    this.idImageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.releasedAt,
    this.approvedBy,
    this.approvedAt,
    this.approvedByUser,
  });

  // Helper getter for full name
  String get fullName {
    final middle = middleInitial != null && middleInitial!.isNotEmpty
        ? ' ${middleInitial!}. '
        : ' ';
    return '$firstName$middle$lastName';
  }

  factory Request.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert ObjectId to string
    String getIdAsString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        // Handle MongoDB ObjectId format: {"$oid": "..."}
        if (value.containsKey('\$oid')) {
          return value['\$oid'].toString();
        }
        // Handle nested _id format: {"_id": "..."}
        if (value.containsKey('_id')) {
          return getIdAsString(value['_id']);
        }
        // Handle id format: {"id": "..."}
        if (value.containsKey('id')) {
          return getIdAsString(value['id']);
        }
      }
      return value.toString();
    }

    // Helper function to safely parse integer
    int getIntValue(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Helper function to safely parse DateTime
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      if (value is Map && value.containsKey('\$date')) {
        try {
          return DateTime.parse(value['\$date']);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return Request(
      id: getIdAsString(json['_id'] ?? json['id']),
      ref: json['ref']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      middleInitial: json['middleInitial']?.toString(),
      contactNumber: json['contactNumber']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      eduAttainment: json['eduAttainment']?.toString(),
      eduCourse: json['eduCourse']?.toString(),
      age: getIntValue(json['age'], 0),
      maritalStatus: json['maritalStatus']?.toString() ?? '',
      docTypeId: getIdAsString(json['docTypeId']),
      idImageUrl: json['idImageUrl']?.toString() ??
          getIdAsString(json['uploadedFileId']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      releasedAt:
          json['releasedAt'] != null ? parseDateTime(json['releasedAt']) : null,
      approvedBy:
          json['approvedBy'] != null ? getIdAsString(json['approvedBy']) : null,
      approvedAt:
          json['approvedAt'] != null ? parseDateTime(json['approvedAt']) : null,
      approvedByUser: json['approvedByUser'] != null
          ? (json['approvedByUser'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(json['approvedByUser'])
              : null)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ref': ref,
      'lastName': lastName,
      'firstName': firstName,
      'middleInitial': middleInitial,
      'contactNumber': contactNumber,
      'address': address,
      'purpose': purpose,
      'eduAttainment': eduAttainment,
      'eduCourse': eduCourse,
      'age': age,
      'maritalStatus': maritalStatus,
      'docTypeId': docTypeId,
      'idImageUrl': idImageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'releasedAt': releasedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedByUser': approvedByUser,
    };
  }
}
