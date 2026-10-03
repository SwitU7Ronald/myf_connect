import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String? email;
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
    this.email,
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
      email: data['email'] as String?,
      phone: data['phone'] as String? ?? '',
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      nickname: data['nickname'] as String?,
      birthdate: _toDate(data['birthdate']),
      gender: data['gender'] as String?,
      district: data['district'] as String?,
      church: data['church'] as String?,
      permissions: (data['permissions'] as List?)?.cast<String>() ?? [],
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
      'birthdate': birthdate,
      'gender': gender,
      'district': district,
      'church': church,
      'permissions': permissions,
    };
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    phone,
    firstName,
    lastName,
    nickname,
    birthdate,
    gender,
    district,
    church,
    permissions,
    createdAt,
    updatedAt,
  ];
}
