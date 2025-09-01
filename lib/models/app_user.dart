import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.permissions = const [],
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

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    if (v is DateTime) return v;
    return null;
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      phone: data['phone'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      nickname: data['nickname'],
      birthdate: _toDate(data['birthdate']),
      gender: data['gender'],
      district: data['district'],
      church: data['church'],
      permissions: (data['permissions'] as List?)?.cast<String>() ?? [],
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
      // Let Firestore serialize DateTime to Timestamp
      'birthdate': birthdate,
      'gender': gender,
      'district': district,
      'church': church,
      'permissions': permissions,
      // omit createdAt/updatedAt; service supplies serverTimestamp
    };
  }
}
