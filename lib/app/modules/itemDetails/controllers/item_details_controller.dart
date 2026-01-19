import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/a_enums.dart';
import '../../../routes/app_pages.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_service.dart';

class ItemDetailsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();

  late final String itemId;
  late final String shopId;

  Stream<DocumentSnapshot>? itemStream;

  @override
  void onInit() {
    super.onInit();
    itemId = Get.arguments as String;
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    shopId = await _userService.getShopIdFromStorage() ?? '0000';

    itemStream = _firestoreService.getInventoryItem(
      shopId: shopId,
      itemId: itemId,
    );

    update();
  }

  void editItem() {
    Get.toNamed(
      Routes.ADD_INVENTORY,
      arguments: {'mode': InventoryFormMode.edit, 'itemId': itemId},
    );
  }

  void deleteItem() {
    Get.snackbar("Action", "Delete Item Clicked");
  }

  void shareItem() {
    Get.snackbar("Action", "Share Item Clicked");
  }

  void markAsRepair() {
    Get.snackbar("Action", "Mark as Repair Clicked");
  }

  void viewDamageFees() {
    Get.snackbar("Action", "View Damage Fees Clicked");
  }
}
