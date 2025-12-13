import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SplashView'), centerTitle: true),
      body: Center(
        child: Obx(
          () => Text("This is spalsh view ${controller.updateStatus.value}"),
        ),
      ),
    );
  }
}
