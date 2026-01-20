import 'package:get/get.dart';

import '../controllers/agreement_template_controller.dart';

class AgreementTemplateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgreementTemplateController>(
      () => AgreementTemplateController(),
    );
  }
}
