import 'package:get/get.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';
import 'inventory_controller.dart';

class AvailableInventoryController extends InventoryController {
  @override
  Future<void> onInit() async {
    // We do NOT call super.onInit() immediately because strictly speaking
    // we want to control when loadMore runs seamlessly,
    // but InventoryController.onInit calls loadMore().
    // We can just let it run, and then override the status.

    // Actually, to avoid double loading or incorrect loading,
    // we should override onInit carefully or just set the values before super if possible.
    // Dart doesn't let us run code before super.onInit() easily in this structure
    // unless we don't call super.onInit().

    // However, clean way:
    // Initialize the list first
    selectedStatuses.assignAll([InventoryStatus.available]);

    await super.onInit();
  }

  @override
  void toggleStatus(InventoryStatus status) {
    // Disable toggling status for this view
    // Or maybe just do nothing
  }
}
