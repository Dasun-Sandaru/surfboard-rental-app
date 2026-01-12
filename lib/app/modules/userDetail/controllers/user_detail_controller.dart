import 'package:get/get.dart';

class UserDetailController extends GetxController {
  
  // In a real app, you would pass the User Object via arguments
  // For now, we initialize with the data you provided
  final user = {
    "id": "12345",
    "created_at": "10 January 2026", 
    "email": "asusvivobook15datalib@gmail.com",
    "is_active": true,
    "name": "John",
    "phone": "0757546437",
    "role": "staff",
    "verified": false,
  }.obs;

  // Reactive variables for the UI toggles
  final RxBool isActive = true.obs;
  final RxBool isVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize reactive variables from the passed user data
    isActive.value = user['is_active'] as bool;
    isVerified.value = user['verified'] as bool;
  }

  void toggleActiveStatus(bool value) {
    isActive.value = value;
    // TODO: Call Firestore update here
    Get.snackbar("Status Updated", "User is now ${value ? 'Active' : 'Inactive'}");
  }

  void toggleVerification() {
    isVerified.value = !isVerified.value;
    // TODO: Call Firestore update here
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
      }
    );
  }
}