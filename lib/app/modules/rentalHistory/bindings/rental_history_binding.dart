import 'package:get/get.dart';
import '../controllers/rental_history_controller.dart';

class RentalHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalHistoryController>(() => RentalHistoryController());
  }
}
