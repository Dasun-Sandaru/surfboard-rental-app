import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<UserModel> streamUser(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => UserModel.fromMap(snap.data()!, uid));
  }

  Future<void> updateUserRole(String uid, String role) {
    return _db.collection('users').doc(uid).update({'role': role});
  }

  Stream<List<UserModel>> streamUsers() {
    return _db.collection('users').snapshots().map((snap) =>
        snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList());
  }
}
