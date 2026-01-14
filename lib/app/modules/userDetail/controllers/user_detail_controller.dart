import 'package:get/get.dart';

import '../../../services/user_service.dart';

class UserDetailController extends GetxController {
  final UserService _userService = Get.find();

  final user = <String, dynamic>{}.obs;

  final RxBool isActive = true.obs;
  final RxBool isVerified = false.obs;

  String shopId = '0000';

  @override
  Future<void> onInit() async {
    super.onInit();
    shopId = await _userService.getShopIdFromStorage() ?? '0000';

    if (Get.arguments is Map) {
      user.assignAll(Map<String, dynamic>.from(Get.arguments));
    }

    // Initialize status values
    isActive.value = user['is_active'] as bool? ?? false;
    isVerified.value = user['verified'] as bool? ?? false;
  }

  /// UI ACTIONS
  Future<void> toggleActiveStatus(bool value) async {
    isActive.value = value;
    await _userService.updateUserStatus(
      userId: user['id'],
      shopId: shopId,
      isActive: value,
    );
    Get.snackbar(
      "Status Updated",
      "User is now ${value ? 'Active' : 'Inactive'}",
    );
  }

  Future<void> toggleVerification() async {
    isVerified.value = !isVerified.value;
    await _userService.updateUserVerification(
      userId: user['id'],
      shopId: shopId,
      verified: isVerified.value,
    );
    Get.snackbar("Verification Updated", "User verification status changed.");
  }

  void deleteUser() {
    Get.defaultDialog(
      title: "Delete User",
      middleText: "Are you sure? This action cannot be undone.",
      textConfirm: "Delete",
      confirmTextColor: Get.theme.scaffoldBackgroundColor,
      onConfirm: () {
        // Delete logic
        Get.back(); // Close dialog
        Get.back(); // Go back to list
      },
    );
  }
}
