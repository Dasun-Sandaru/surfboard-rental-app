import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../exceptions/firebase_exceptions.dart';

class AppErrorHandler {
  static void handleError(Object e) {
    if (kDebugMode) debugPrint(e.toString());

    String message;
    if (e is FirebaseAuthException) {
      message = AppFirebaseException(e).message;
    } else if (e is PlatformException) {
      // You might want to create a specific handler for PlatformExceptions
      message = e.message ?? 'A platform error occurred.';
    } else {
      message = e.toString();
    }

    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }
}
