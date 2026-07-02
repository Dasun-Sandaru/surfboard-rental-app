import 'package:get/get.dart';

import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../../utils/common/app_snack_bar.dart';
import '../../../../utils/common/a_app_dialogs.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/firestore_usage_service.dart';
import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/firestore_fields.dart';
import '../../../models/activity_log_model.dart';
import '../../../../utils/constants/a_enums.dart';
import '../widgets/user_qr_code_dialog.dart';

class UserDetailController extends GetxController {
  // static const String _logName = 'UserDetailController';
  final UserService _userService = Get.find();

  final Rx<UserModel?> user = Rx<UserModel?>(null);

  final RxBool isActive = true.obs;
  final RxBool isVerified = false.obs;

  final RxInt totalRentals = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxList<ActivityLogModel> recentActivities = <ActivityLogModel>[].obs;
  final RxBool isLoadingStats = false.obs;

  String shopId = '0000';

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final args = Get.arguments;
      if (args == null) return;

      shopId = await _userService.getShopIdFromStorage() ?? '0000';

      String? uid;
      if (args is UserModel) {
        user.value = args;
        uid = args.uid;
      } else if (args is String) {
        uid = args;
      } else if (args is Map && args.containsKey('userId')) {
        uid = args['userId'];
      }

      if (uid != null && user.value == null) {
        // Fetch user from database if only UID is passed or found in map
        final fetchedUser = await _userService.getUser(uid);
        if (fetchedUser != null) {
          user.value = fetchedUser;
        } else {
          AppSnackBar.error(title: 'Error', message: 'User not found');
          Get.back();
          return;
        }
      }

      // Initialize reactive status variables
      if (user.value != null) {
        isActive.value = user.value!.isActive;
        isVerified.value = user.value!.isVerified;
        _loadPerformanceStats(user.value!.uid);
      }
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: 'Failed to load user: $e');
    }
  }

  Future<void> _loadPerformanceStats(String uid) async {
    isLoadingStats.value = true;
    try {
      final db = FirebaseFirestore.instance;
      
      final logsSnapshot = await db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.activityLogs)
          .where(FirestoreFields.actorId, isEqualTo: uid)
          .orderBy(FirestoreFields.timestamp, descending: true)
          .get();

      FirestoreUsageService.to.trackQuerySnapshot(logsSnapshot);

      int count = 0;
      double revenue = 0.0;
      List<ActivityLogModel> recent = [];

      for (var doc in logsSnapshot.docs) {
        final logModel = ActivityLogModel.fromSnapshot(doc);
        
        if (logModel.activityType == ActivityType.create_rental) {
          count++;
          if (logModel.metadata != null && logModel.metadata!['amountExpected'] != null) {
            revenue += (logModel.metadata!['amountExpected'] as num).toDouble();
          }
        }
        
        if (recent.length < 3) {
          recent.add(logModel);
        }
      }

      totalRentals.value = count;
      totalRevenue.value = revenue;
      recentActivities.value = recent;
    } catch (e) {
      log('Error loading performance stats: $e');
    } finally {
      isLoadingStats.value = false;
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
    showAppConfirmation(
      context: Get.context!,
      title: "Delete User",
      message: "Are you sure? This action cannot be undone.",
      confirmText: "Delete",
      cancelText: "Cancel",
      onConfirm: () {
        // Delete logic
        Get.back(); // Go back to list
      },
    );
  }

  void showQR() {
    if (user.value == null) return;

    Get.dialog(UserQrCodeDialog(user: user.value!), barrierDismissible: true);
  }
}
