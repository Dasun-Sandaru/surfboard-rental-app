import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/exceptions/firebase_exceptions.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class SignInController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isObscure = true.obs;
  RxBool isLoading = false.obs;
  final AuthService _authService = Get.find();

  @override
  void onInit() {
    super.onInit();
  }

  // sign in user
  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;
      final userCredential = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user creation failed');
      }

      if (!firebaseUser.emailVerified) {
        Get.snackbar(
          'Email not verified',
          'Please verify your email to access the app.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );

        // sign them out and they don't access data
        await FirebaseAuth.instance.signOut();
      }

      // fetch role and navigate to home screen

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users_global')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;
        final String role = userData['role'];

        if (role == 'admin') {
          Get.offAllNamed(Routes.HOME);
        } else if (role == 'staff') {
          Get.offAllNamed(Routes.HOME);
        } else {
          Get.snackbar('Error', 'User role not defined. Contact support.');
          await FirebaseAuth.instance.signOut();
        }
      } else {
        Get.snackbar('Error', 'User data not found. Contact support.');
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(AppFirebaseException(e).message);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint(e.toString());
        debugPrint(stack.toString());
      }
      Get.snackbar('error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void goToForgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  void goToSignUpStaff() {
    Get.toNamed(Routes.SIGN_UP, arguments: {'role': 'staff'});
  }

  void goToSignUpAdmin() {
    Get.toNamed(Routes.SIGN_UP, arguments: {'role': 'admin'});
  }

  @override
  void onClose() {
    super.onClose();
    emailController.dispose();
    passwordController.dispose();
  }
}
