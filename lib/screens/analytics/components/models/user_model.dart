import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // This is the ID
  final String role; // 'basicUser', 'researcher', 'admin'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? displayName;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.displayName,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      role: map['role'] ?? 'basicUser',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin:
          map['lastLogin'] != null
              ? (map['lastLogin'] as Timestamp).toDate()
              : null,
      displayName: map['displayName'],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'displayName': displayName,
      'isActive': isActive,
    };
  }
}
