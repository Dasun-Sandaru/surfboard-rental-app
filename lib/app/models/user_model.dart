import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/firestore/firestore_fields.dart';
import '../../utils/constants/a_enums.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? name;
  final UserRole role; // 'admin' or 'staff'
  final bool isActive;
  final bool isVerified;
  final String? phone;
  final String? shopId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool emailVerified;

  const UserModel({
    required this.uid,
    this.email,
    this.name,
    required this.role,
    this.isActive = true,
    this.isVerified = false,
    this.phone,
    this.shopId,
    this.createdAt,
    this.updatedAt,
    this.emailVerified = false,
  });

  /// Create UserModel from Firestore map
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    final roleString = data[FirestoreFields.role] as String? ?? 'staff';
    final role = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.staff,
    );

    return UserModel(
      uid: documentId,
      email: data[FirestoreFields.email] as String?,
      name: data[FirestoreFields.name] as String?,
      role: role,
      isActive: data[FirestoreFields.isActive] as bool? ?? true,
      isVerified: data[FirestoreFields.verified] as bool? ?? false,
      phone: data[FirestoreFields.phone] as String?,
      shopId: data[FirestoreFields.shopId] as String?,
      createdAt: data[FirestoreFields.createdAt] is Timestamp
          ? (data[FirestoreFields.createdAt] as Timestamp).toDate()
          : null,
      updatedAt: data[FirestoreFields.updatedAt] is Timestamp
          ? (data[FirestoreFields.updatedAt] as Timestamp).toDate()
          : null,
      emailVerified: data[FirestoreFields.emailVerified] as bool? ?? false,
    );
  }

  /// Create UserModel from Firestore snapshot
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel.fromMap(data, doc.id);
  }

  /// Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.email: email,
      FirestoreFields.name: name,
      FirestoreFields.role: role.name,
      FirestoreFields.isActive: isActive,
      FirestoreFields.verified: isVerified,
      FirestoreFields.phone: phone,
      FirestoreFields.shopId: shopId,
      FirestoreFields.createdAt: createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null,
      FirestoreFields.updatedAt: updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : null,
      FirestoreFields.emailVerified: emailVerified,
      FirestoreFields.nameLowercase: name?.toLowerCase(),
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    bool? isActive,
    bool? isVerified,
    String? phone,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      phone: phone ?? this.phone,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is staff
  bool get isStaff => role == UserRole.staff;

  @override
  String toString() =>
      'UserModel(uid: $uid, email: $email, name: $name, role: $role, isActive: $isActive,)';
}
