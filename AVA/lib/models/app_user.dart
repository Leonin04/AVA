import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = AppConstants.roleUser,
    this.createdAt,
  });

  bool get isAdmin => role == AppConstants.roleAdmin;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      role: map['role'] as String? ?? AppConstants.roleUser,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
