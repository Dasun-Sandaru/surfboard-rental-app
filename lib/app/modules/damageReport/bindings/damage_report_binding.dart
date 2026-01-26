import 'package:get/get.dart';

import '../controllers/damage_report_controller.dart';

class DamageReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DamageReportController>(
      () => DamageReportController(),
    );
  }
}
