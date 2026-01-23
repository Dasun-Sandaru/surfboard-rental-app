import 'package:get/get.dart';

import '../controllers/signature_pad_controller.dart';

class SignatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignaturePadController>(() => SignaturePadController());
  }
}
