import 'package:get/get.dart';

import '../controllers/board_inspection_controller.dart';

class BoardInspectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoardInspectionController>(
      () => BoardInspectionController(),
    );
  }
}
