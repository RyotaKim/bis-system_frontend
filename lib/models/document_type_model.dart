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
    return DocumentType(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      fee: json['fee']?.toDouble(),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
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
