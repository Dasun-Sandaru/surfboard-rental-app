import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String logName = 'AuthService';

  // ---------------------------------------------------------------------------
  // AUTH STATE GETTERS
  // ---------------------------------------------------------------------------
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // SIGN UP
  // ---------------------------------------------------------------------------
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      log('Signing up user: $email', name: logName);
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email after signup
      await credential.user?.sendEmailVerification();
      log('User signed up and verification email sent: $email', name: logName);

      return credential;
    } catch (e) {
      log('Error signing up: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN IN
  // ---------------------------------------------------------------------------
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      log('Signing in user: $email', name: logName);
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log('Error signing in: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN OUT
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      log('Signing out current user', name: logName);
      await _auth.signOut();
      log('User signed out successfully', name: logName);
    } catch (e) {
      log('Error signing out: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK EMAIL VERIFICATION STATUS
  // ---------------------------------------------------------------------------
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      final verified = _auth.currentUser?.emailVerified ?? false;
      log('Email verified status: $verified', name: logName);
      return verified;
    } catch (e) {
      log('Error checking email verification: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // RESEND VERIFICATION EMAIL
  // ---------------------------------------------------------------------------
  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        log('Verification email resent to: ${user.email}', name: logName);
      }
    } catch (e) {
      log('Error resending verification email: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SEND PASSWORD RESET EMAIL
  // ---------------------------------------------------------------------------
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      log('Sending password reset email to: $email', name: logName);
      await _auth.sendPasswordResetEmail(email: email);
      log('Password reset email sent: $email', name: logName);
    } catch (e) {
      log('Error sending password reset email: $e', name: logName);
      rethrow;
    }
  }
}
