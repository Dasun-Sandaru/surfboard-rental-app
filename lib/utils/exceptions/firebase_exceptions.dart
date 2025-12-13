import 'package:firebase_auth/firebase_auth.dart';

class AppFirebaseException {
  final FirebaseException _exception;

  AppFirebaseException(this._exception);

  String get message {
    switch (_exception.code) {
      case 'unknown':
        return 'An unknown Firebase error occurred. Please try again.';
      case 'invalid-custom-token':
        return 'The custom token format is incorrect. Please check your token.';
      case 'custom-token-mismatch':
        return 'The custom token corresponds to a different audience.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found for the given email or UID.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'provider-already-linked':
        return 'The account is already linked with another provider.';
      case 'needs-recent-login':
        return 'This operation is sensitive and requires recent authentication. Please sign in again.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'invalid-credential':
        return 'The credential provided is malformed or has expired.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      // Firestore Exceptions
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'not-found':
        return 'The requested document was not found.';
      case 'permission-denied':
        return 'You do not have permission to perform this operation.';
      case 'resource-exhausted':
        return 'The project has exhausted its quota. Please check your Firebase project plan.';
      case 'unauthenticated':
        return 'You are unauthenticated. Please sign in to continue.';
      case 'unavailable':
        return 'The service is currently unavailable. Please try again later.';
      case 'deadline-exceeded':
        return 'The deadline for the operation has been exceeded. Please try again.';
      default:
        return 'An unexpected Firebase error occurred. Please try again.';
    }
  }
}
