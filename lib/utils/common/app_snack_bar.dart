import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackBar {
  static const String _logName = 'AppSnackBar';

  // Success Snackbar
  static void success({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    log('[$title] $message', name: _logName);
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
      borderColor: Colors.green,
      borderWidth: 1,
      duration: duration,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  // Error Snackbar
  static void error({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    log('[$title] ERROR: $message', name: _logName);
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      borderColor: Colors.red,
      borderWidth: 1,
      duration: duration,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  // Warning Snackbar
  static void warning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    log('[$title] WARNING: $message', name: _logName);
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orange.withOpacity(0.1),
      colorText: Colors.orange,
      borderColor: Colors.orange,
      borderWidth: 1,
      duration: duration,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.warning_amber, color: Colors.orange),
    );
  }

  // Info Snackbar
  static void info({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    log('[$title] $message', name: _logName);
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
      borderColor: Colors.blue,
      borderWidth: 1,
      duration: duration,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.info_outline, color: Colors.blue),
    );
  }
}
