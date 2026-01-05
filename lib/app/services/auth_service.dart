import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/exceptions/firebase_exceptions.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    try {
      return _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(AppFirebaseException(e).message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        role: 'Staff',
      );
      await _db
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());
    }
    return userCredential;
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<User> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user;
    }
    throw Exception('No user signed in');
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.reload();
        return user.emailVerified;
      } catch (e) {
        // If reload fails (e.g., user signed out), return false
        return false;
      }
    }
    return false;
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Check if a user exists by email
  Future<bool> userExistsByEmail(String email) async {
    try {
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Send password reset email to the provided email address
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(AppFirebaseException(e).message);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }
}
