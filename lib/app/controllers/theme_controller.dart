import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Singleton Access
  static ThemeController get to => Get.find<ThemeController>();

  final themeMode = ThemeMode.system.obs;
  final themeData = ThemeData.dark().obs;
}
