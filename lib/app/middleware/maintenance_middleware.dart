import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';
import '../services/config_service.dart';

class MaintenanceMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (route == Routes.MAINTENANCE) {
      return null;
    }

    try {
      final configService = Get.find<ConfigService>();
      if (configService.isMaintenanceMode.value) {
        return const RouteSettings(name: Routes.MAINTENANCE);
      }
    } catch (_) {
      // Service not found? Ignore or log.
    }

    return null;
  }
}
