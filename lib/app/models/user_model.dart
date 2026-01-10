import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? name;
  final String role; // 'admin' or 'staff'
  final bool isActive;
  final String? phone;
  final String? shopId;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final bool emailVerified;

  UserModel({
    required this.uid,
    this.email,
    this.name,
    required this.role,
    this.isActive = true,
    this.phone,
    this.shopId,
    this.createdAt,
    this.updatedAt,
    this.emailVerified = false,
  });

  /// Create UserModel from Firestore map
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] as String?,
      name: data['name'] as String?,
      role: data['role'] as String? ?? 'staff',
      isActive: data['is_active'] as bool? ?? true,
      phone: data['phone'] as String?,
      shopId: data['shop_id'] as String?,
      createdAt: data['created_at'] as Timestamp?,
      updatedAt: data['updated_at'] as Timestamp?,
      emailVerified: data['email_verified'] as bool? ?? false,
    );
  }

  /// Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'is_active': isActive,
      'phone': phone,
      'shop_id': shopId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'email_verified': emailVerified,
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    String? phone,
    String? shopId,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? emailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  /// Check if user is admin
  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Check if user is staff
  bool get isStaff => role.toLowerCase() == 'staff';

  @override
  String toString() =>
      'UserModel(uid: $uid, email: $email, name: $name, role: $role, isActive: $isActive,)';
}
