import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String phoneNumber; // This is the ID
  final String role; // 'basicUser', 'researcher', 'admin'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? displayName;
  final bool isActive;

  UserModel({
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.displayName,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      phoneNumber: map['phoneNumber'] ?? '',
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
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'displayName': displayName,
      'isActive': isActive,
    };
  }
}
