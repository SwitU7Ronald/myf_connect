class AppUser {
  final String uid;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final DateTime? birthdate;
  final String? gender;
  final String? district;
  final String? church;
  final List<String> permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    required this.phone,
    this.firstName,
    this.lastName,
    this.nickname,
    this.birthdate,
    this.gender,
    this.district,
    this.church,
    this.permissions = const [], // No default permission
    this.createdAt,
    this.updatedAt,
  });

  bool get isProfileComplete =>
      firstName != null &&
          lastName != null &&
          birthdate != null &&
          gender != null &&
          district != null &&
          church != null;

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      phone: data['phone'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      nickname: data['nickname'],
      birthdate: data['birthdate'] != null
          ? DateTime.tryParse(data['birthdate'])
          : null,
      gender: data['gender'],
      district: data['district'],
      church: data['church'],
      permissions: (data['permissions'] as List?)?.cast<String>() ?? [],
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
      'nickname': nickname,
      'birthdate': birthdate?.toIso8601String(),
      'gender': gender,
      'district': district,
      'church': church,
      'permissions': permissions,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
