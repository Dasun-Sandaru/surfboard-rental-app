import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/alerts_controller.dart';

class AlertsView extends GetView<AlertsController> {
  const AlertsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AlertsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AlertsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
