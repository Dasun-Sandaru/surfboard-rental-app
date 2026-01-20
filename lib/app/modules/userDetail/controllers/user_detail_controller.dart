import 'package:get/get.dart';

import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../../utils/common/app_snack_bar.dart';

class UserDetailController extends GetxController {
  static const String _logName = 'UserDetailController';
  final UserService _userService = Get.find();

  final Rx<UserModel?> user = Rx<UserModel?>(null);

  final RxBool isActive = true.obs;
  final RxBool isVerified = false.obs;

  String shopId = '0000';

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      shopId = await _userService.getShopIdFromStorage() ?? '0000';

      if (Get.arguments is UserModel) {
        user.value = Get.arguments as UserModel;
        isActive.value = user.value?.isActive ?? false;
        isVerified.value = user.value?.isVerified ?? false;
      }
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: 'Failed to load user: $e');
    }
  }

  /// UI ACTIONS
  Future<void> toggleActiveStatus(bool value) async {
    try {
      if (user.value == null) {
        AppSnackBar.error(title: 'Error', message: 'User data not available');
        return;
      }

      isActive.value = value;
      await _userService.updateUserStatus(
        userId: user.value!.uid,
        shopId: shopId,
        isActive: value,
      );
      AppSnackBar.success(
        title: 'Status Updated',
        message: 'User is now ${value ? 'Active' : 'Inactive'}',
      );
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: 'Failed to update status: $e');
    }
  }

  Future<void> toggleVerification() async {
    try {
      if (user.value == null) {
        AppSnackBar.error(title: 'Error', message: 'User data not available');
        return;
      }

      isVerified.value = !isVerified.value;
      await _userService.updateUserVerification(
        userId: user.value!.uid,
        shopId: shopId,
        verified: isVerified.value,
      );
      AppSnackBar.success(
        title: 'Verification Updated',
        message: 'User verification status changed.',
      );
    } catch (e) {
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to update verification: $e',
      );
    }
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
