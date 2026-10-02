class UserProfile {
  final String name;
  final String email;
  final String gender;
  final String status;
  final List<UserRole> roles;
  final String? organization;

  UserProfile({
    required this.name,
    required this.email,
    required this.gender,
    required this.status,
    required this.roles,
    this.organization,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profileData = json.containsKey('profile') ? json['profile'] : json;
    
    return UserProfile(
      name: profileData['name'] ?? '',
      email: profileData['email'] ?? '',
      gender: profileData['gender'] ?? '',
      status: profileData['status']?.toString() ?? '',
      organization: json['organization']?.toString() ?? '',
      roles: (profileData['roles'] as List<dynamic>?)
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
