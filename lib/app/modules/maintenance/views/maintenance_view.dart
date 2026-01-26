import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/config_service.dart';

class MaintenanceView extends GetView<ConfigService> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    // We can access ConfigService via controller or Get.find
    // Since we extended GetView<ConfigService>, 'controller' refers to it if registered.
    // ConfigService is permanently registered in InitialBinding.

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.build_circle_outlined,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Under Maintenance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Text(
                  Get.find<ConfigService>().maintenanceMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
