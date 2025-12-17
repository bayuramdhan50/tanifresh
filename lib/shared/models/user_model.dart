/// User model for TaniFresh app
class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'client' or 'admin'
  final bool isActive;
  final String? address;
  final String? phone;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.address,
    this.phone,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      isActive: (json['is_active'] ?? json['isActive']) is bool
          ? (json['is_active'] ?? json['isActive'] ?? false)
          : ((json['is_active'] ?? json['isActive'] ?? 0) == 1),
      address: json['address'],
      phone: json['phone'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
      'address': address,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
