import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfboard_rental_app/utils/theme/app_material_theme.dart';

class AppSnackBar {
  static const String _logName = 'AppSnackBar';

  static StatusColors? get _statusColors {
    if (Get.context == null) return null;
    return Theme.of(Get.context!).extension<StatusColors>();
  }

  // Success Snackbar
  static void success({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
    void Function(GetSnackBar)? onTap,
  }) {
    log('[$title] $message', name: _logName);
    final color = _statusColors?.success ?? Colors.green;
    Get.snackbar(
      title,
      message,
      backgroundColor: color.withValues(alpha: 0.1),
      colorText: color,
      borderColor: color,
      borderWidth: 1,
      duration: duration,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(Icons.check_circle, color: color),
      onTap: onTap,
    );
  }

  // Error Snackbar
  static void error({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
    void Function(GetSnackBar)? onTap,
  }) {
    log('[$title] ERROR: $message', name: _logName);
    final color = _statusColors?.error ?? Colors.red;
    Get.snackbar(
      title,
      message,
      backgroundColor: color.withValues(alpha: 0.1),
      colorText: color,
      borderColor: color,
      borderWidth: 1,
      duration: duration,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(Icons.error_outline, color: color),
      onTap: onTap,
    );
  }

  // Warning Snackbar
  static void warning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
    void Function(GetSnackBar)? onTap,
  }) {
    log('[$title] WARNING: $message', name: _logName);
    final color = _statusColors?.warning ?? Colors.orange;
    Get.snackbar(
      title,
      message,
      backgroundColor: color.withValues(alpha: 0.1),
      colorText: color,
      borderColor: color,
      borderWidth: 1,
      duration: duration,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(Icons.warning_amber, color: color),
      onTap: onTap,
    );
  }

  // Info Snackbar
  static void info({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
    void Function(GetSnackBar)? onTap,
  }) {
    log('[$title] $message', name: _logName);
    final color = _statusColors?.info ?? Colors.blue;
    Get.snackbar(
      title,
      message,
      backgroundColor: color.withValues(alpha: 0.1),
      colorText: color,
      borderColor: color,
      borderWidth: 1,
      duration: duration,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(Icons.info_outline, color: color),
      onTap: onTap,
    );
  }
}
