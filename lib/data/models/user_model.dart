import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  admin;

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
          (e) => e.name == value,
      orElse: () => UserRole.student,
    );
  }
}

class UserModel {
  final String uid;
  final UserRole role;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String? hostelId;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.hostelId,
    required this.createdAt,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) =>
      UserModel.fromJson(doc.data() ?? {}, uid: doc.id);

  factory UserModel.fromJson(Map<String, dynamic> json, {String? uid}) {
    final created = json['createdAt'];
    return UserModel(
      uid: uid ?? json['uid'] ?? '',
      role: UserRole.fromString(json['role']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'],
      hostelId: json['hostelId'],
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'name': name,
    'email': email,
    'phone': phone,
    'photoUrl': photoUrl,
    'hostelId': hostelId,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    String? hostelId,
  }) {
    return UserModel(
      uid: uid,
      role: role,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      hostelId: hostelId ?? this.hostelId,
      createdAt: createdAt,
    );
  }

  bool get isAdmin => role == UserRole.admin;
}