import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/exceptions/firebase_exceptions.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class SignUpController extends GetxController {
  final GlobalKey<FormState> staffFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shopFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> ownerFormKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController shopCodeController = TextEditingController();

  RxBool isObscurePassword = true.obs;
  RxBool isObscureConfirmPassword = true.obs;
  RxBool isLoading = false.obs;
  // for admin
  TextEditingController shopNameController = TextEditingController();
  TextEditingController shopLocationController = TextEditingController();
  TextEditingController shopContactController = TextEditingController();

  RxInt currentStep = 0.obs;

  RxString role = 'staff'.obs; // 'staff' or 'admin'

  final AuthService _authService = Get.find();

  @override
  void onInit() {
    super.onInit();
    // get arguments to set role
    final args = Get.arguments;
    if (args != null && args['role'] != null) {
      role.value = args['role'];
    }
  }

  // register shop owner
  Future<void> registerShopOwner() async {
    if (!(ownerFormKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      // create firebase auth user
      final userCredential = await _authService.registerWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user creation failed');
      }

      // prepare IDs
      final String userId = firebaseUser.uid;
      final String shopId = FirebaseFirestore.instance
          .collection('shops')
          .doc()
          .id;
      final String shopCode = _generateShopCode();

      // prepare firestore references
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final shopRef = firestore.collection('shops').doc(shopId);
      final globalUserRef = firestore.collection('users_global').doc(userId);
      final shopUserRef = shopRef.collection('users').doc(userId);

      // prepare data maps
      final shopData = {
        'name': shopNameController.text.trim(),
        'location': shopLocationController.text.trim(),
        'contact_number': shopContactController.text.trim(),
        'created_date': FieldValue.serverTimestamp(),
        'owner_admin_uid': userId,
        'shop_code': shopCode,
      };

      final globalUserData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'admin',
        'shop_id': shopId,
        'phone': phoneController.text.trim(),
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      };

      final shopUserData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'admin',
        'phone': phoneController.text.trim(),
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      };

      // debug logs
      if (kDebugMode) {
        debugPrint('--- Firestore Batch Data ---');
        debugPrint('Shop: ${jsonEncode(shopData)}');
        debugPrint('Global User: ${jsonEncode(globalUserData)}');
        debugPrint('Shop User: ${jsonEncode(shopUserData)}');
      }

      // batch writes
      batch.set(shopRef, shopData);
      batch.set(globalUserRef, globalUserData);
      batch.set(shopUserRef, shopUserData);

      await batch.commit();

      // send email verification
      await firebaseUser.sendEmailVerification();

      // success feedback
      Get.snackbar(
        'Account Created',
        'Please check your email (${emailController.text}) to verify your account.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 5),
      );

      Get.offAllNamed(Routes.VERIFY_EMAIL);
    } on FirebaseAuthException catch (e) {
      throw Exception(AppFirebaseException(e).message);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('registerShopOwner error: $e');
        debugPrintStack(stackTrace: stack);
      }
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // register shop staff
  Future<void> registerShopStaff() async {
    // validate staff form
    if (!(staffFormKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      // create firebase auth user
      final userCredential = await _authService.registerWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('firebase user creation failed');
      }

      // prepare ids
      final String userId = firebaseUser.uid;
      final String shopId = shopCodeController.text.trim();

      // prepare firestore
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // prepare references
      final globalUserRef = firestore.collection('users_global').doc(userId);

      final shopUserRef = firestore
          .collection('shops')
          .doc(shopId)
          .collection('users')
          .doc(userId);

      // prepare global user data
      final globalUserData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'staff',
        'shop_id': shopId,
        'phone': phoneController.text.trim(),
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      };

      // prepare shop user data
      final shopUserData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'staff',
        'verified': false,
        'phone': phoneController.text.trim(),
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      };

      // debug logs
      if (kDebugMode) {
        debugPrint('global user: ${jsonEncode(globalUserData)}');
        debugPrint('shop user: ${jsonEncode(shopUserData)}');
      }

      // batch writes
      batch.set(globalUserRef, globalUserData);
      batch.set(shopUserRef, shopUserData);

      await batch.commit();

      // send email verification
      await firebaseUser.sendEmailVerification();

      // success message
      Get.snackbar(
        'account created',
        'please check your email (${emailController.text}) to verify your account.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 5),
      );

      // go to verify screen
      Get.offAllNamed(Routes.VERIFY_EMAIL);
    } on FirebaseAuthException catch (e) {
      throw Exception(AppFirebaseException(e).message);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('registerShopStaff error: $e');
        debugPrintStack(stackTrace: stack);
      }
      Get.snackbar('error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // generate random shop code
  String _generateShopCode() {
    // generates a code like "SURF-8492"
    int randomNum = DateTime.now().millisecondsSinceEpoch % 10000;
    return "SURF-$randomNum";
  }

  void nextStep() {
    if (currentStep.value < 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    shopCodeController.dispose();
    shopNameController.dispose();
    shopLocationController.dispose();
    shopContactController.dispose();
    super.onClose();
  }
}
