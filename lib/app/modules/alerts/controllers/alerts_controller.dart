import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/firestore_fields.dart';

import '../../../models/activity_log_model.dart';
import '../../../services/user_service.dart';
import '../../../services/firestore_usage_service.dart';
import '../../../../utils/common/app_snack_bar.dart';

class AlertsController extends GetxController {
  static const String _logName = 'AlertsController';
  static const int _pageSize = 20;

  final UserService _userService = Get.find();

  String? shopId;

  final PagingController<DocumentSnapshot?, ActivityLogModel> pagingController =
      PagingController(firstPageKey: null);

  @override
  void onInit() {
    super.onInit();
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(DocumentSnapshot? pageKey) async {
    try {
      if (shopId == null) {
        shopId = await _userService.getShopIdFromStorage();
        if (shopId == null) {
          const errorMsg = 'Shop ID not found';
          log(errorMsg, name: _logName);
          AppSnackBar.error(title: 'Error', message: errorMsg);
          pagingController.error = errorMsg;
          return;
        }
        log('Initialized with shopId: $shopId', name: _logName);
      }

      log('Fetching page with key: ${pageKey?.id}', name: _logName);

      Query query = FirebaseFirestore.instance
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.activityLogs)
          .orderBy(FirestoreFields.timestamp, descending: true)
          .limit(_pageSize);

      if (pageKey != null) {
        query = query.startAfterDocument(pageKey);
      }

      final snapshot = await query.get();
      FirestoreUsageService.to.trackQuerySnapshot(snapshot);
      if (isClosed) return;
      final logs = snapshot.docs
          .map(
            (doc) => ActivityLogModel.fromSnapshot(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();

      final isLastPage = logs.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(logs);
      } else {
        final nextPageKey = snapshot.docs.last;
        pagingController.appendPage(logs, nextPageKey);
      }

      log('Fetched ${logs.length} logs', name: _logName);
    } catch (e) {
      log('Error fetching page: $e', name: _logName);
      pagingController.error = e;
      AppSnackBar.error(
        title: 'Load Error',
        message: 'Failed to load activity logs: $e',
      );
    }
  }

  void refreshLogs() {
    pagingController.refresh();
  }

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }
}
