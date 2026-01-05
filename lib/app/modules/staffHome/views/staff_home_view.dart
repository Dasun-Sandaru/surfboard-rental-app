import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/staff_home_controller.dart';

class StaffHomeView extends GetView<StaffHomeController> {
  const StaffHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StaffHomeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'StaffHomeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
