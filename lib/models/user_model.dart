/// User Model
class User {
  final String id;
  final String username;
  final String name;
  final String contactNumber;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.contactNumber,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      role: json['role'] ?? 'admin',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'name': name,
      'contactNumber': contactNumber,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
