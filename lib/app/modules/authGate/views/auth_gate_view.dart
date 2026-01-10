import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/auth_gate_controller.dart';

class AuthGateView extends GetView<AuthGateController> {
  const AuthGateView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuthGateView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AuthGateView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
