import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AppFirebaseException {
  final FirebaseException _exception;

  AppFirebaseException(this._exception);

  String get message {
    switch (_exception.code) {
      case 'unknown':
        return 'fb_unknown'.tr;
      case 'invalid-custom-token':
        return 'fb_invalid_custom_token'.tr;
      case 'custom-token-mismatch':
        return 'fb_custom_token_mismatch'.tr;
      case 'user-disabled':
        return 'fb_user_disabled'.tr;
      case 'user-not-found':
        return 'fb_user_not_found'.tr;
      case 'invalid-email':
        return 'fb_invalid_email'.tr;
      case 'email-already-in-use':
        return 'fb_email_already_in_use'.tr;
      case 'wrong-password':
        return 'fb_wrong_password'.tr;
      case 'weak-password':
        return 'fb_weak_password'.tr;
      case 'provider-already-linked':
        return 'fb_provider_already_linked'.tr;
      case 'needs-recent-login':
        return 'fb_needs_recent_login'.tr;
      case 'operation-not-allowed':
        return 'fb_operation_not_allowed'.tr;
      case 'invalid-credential':
        return 'fb_invalid_credential'.tr;
      case 'account-exists-with-different-credential':
        return 'fb_account_exists_with_different_credential'.tr;
      // Firestore Exceptions
      case 'cancelled':
        return 'fb_cancelled'.tr;
      case 'not-found':
        return 'fb_not_found'.tr;
      case 'permission-denied':
        return 'fb_permission_denied'.tr;
      case 'resource-exhausted':
        return 'fb_resource_exhausted'.tr;
      case 'unauthenticated':
        return 'fb_unauthenticated'.tr;
      case 'unavailable':
        return 'fb_unavailable'.tr;
      case 'deadline-exceeded':
        return 'fb_deadline_exceeded'.tr;
      default:
        return 'fb_unexpected'.tr;
    }
  }
}
