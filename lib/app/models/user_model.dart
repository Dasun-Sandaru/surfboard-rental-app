class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String role;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'],
      displayName: data['displayName'],
      role: data['role'] ?? 'Staff',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
    };
  }
}
