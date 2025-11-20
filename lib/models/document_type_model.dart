/// Document Type Model
class DocumentType {
  final String id;
  final String name;
  final String description;
  final List<String> requirements;
  final double? fee;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentType({
    required this.id,
    required this.name,
    required this.description,
    required this.requirements,
    this.fee,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentType.fromJson(Map<String, dynamic> json) {
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

    return DocumentType(
      id: getIdAsString(json['_id'] ?? json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : [],
      fee: json['fee']?.toDouble(),
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'requirements': requirements,
      'fee': fee,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
