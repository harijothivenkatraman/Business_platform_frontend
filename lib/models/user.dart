class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String businessId;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.businessId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'member',
      businessId: json['businessId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'businessId': businessId,
  };
}
