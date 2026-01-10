import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../controllers/staff_home_controller.dart';

class StaffHomeView extends GetView<StaffHomeController> {
  const StaffHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authservice = Get.find<AuthService>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _authservice.signOut();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text('Staff Home'), centerTitle: true),
      body: const Center(child: Text('Staff Home')),
    );
  }
}
