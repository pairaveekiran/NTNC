class UserProfile {
  final String name;
  final String email;
  final String gender;
  final String status;
  final List<UserRole> roles;

  UserProfile({
    required this.name,
    required this.email,
    required this.gender,
    required this.status,
    required this.roles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      status: json['status'] ?? '',
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => UserRole.fromJson(role))
              .toList() ??
          [],
    );
  }
}

class UserRole {
  final String name;
  final String description;

  UserRole({
    required this.name,
    required this.description,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
