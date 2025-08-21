class AppUser {
  final String uid;
  final String phone;
  final String? firstName;
  final String? lastName;
  final DateTime? birthdate;
  final String? gender;
  final String? state;
  final String? city;
  final List<String> permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    required this.phone,
    this.firstName,
    this.lastName,
    this.birthdate,
    this.gender,
    this.state,
    this.city,
    this.permissions = const ['general'],
    this.createdAt,
    this.updatedAt,
  });

  bool get isProfileComplete =>
      firstName != null &&
          lastName != null &&
          birthdate != null &&
          gender != null &&
          state != null &&
          city != null;

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      phone: data['phone'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      birthdate: data['birthdate'] != null
          ? DateTime.tryParse(data['birthdate'])
          : null,
      gender: data['gender'],
      state: data['state'],
      city: data['city'],
      permissions: (data['permissions'] as List?)?.cast<String>() ?? ['general'],
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'])
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'birthdate': birthdate?.toIso8601String(),
      'gender': gender,
      'state': state,
      'city': city,
      'permissions': permissions,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
