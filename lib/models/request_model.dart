/// Request Model
class Request {
  final String id;
  final String ref;
  final String fullName;
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

  Request({
    required this.id,
    required this.ref,
    required this.fullName,
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
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['_id'] ?? json['id'] ?? '',
      ref: json['ref'] ?? '',
      fullName: json['fullName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      purpose: json['purpose'] ?? '',
      eduAttainment: json['eduAttainment'],
      eduCourse: json['eduCourse'],
      age: json['age'] ?? 0,
      maritalStatus: json['maritalStatus'] ?? '',
      docTypeId: json['docTypeId'] ?? '',
      idImageUrl: json['idImageUrl'],
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      releasedAt: json['releasedAt'] != null
          ? DateTime.parse(json['releasedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ref': ref,
      'fullName': fullName,
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
    };
  }
}
