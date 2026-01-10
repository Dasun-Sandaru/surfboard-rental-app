import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../services/auth_service.dart';
import '../controllers/admin_home_controller.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});
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
      appBar: AppBar(title: const Text('AdminHomeView'), centerTitle: true),
      body: const Center(
        child: Text('AdminHomeView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
