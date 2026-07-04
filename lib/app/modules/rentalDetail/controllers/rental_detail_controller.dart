import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../models/damage_photo_model.dart';
import '../../../models/damage_report_model.dart';
import '../../../models/payment_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/damage_report_service.dart';
import '../../../services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/common/app_snack_bar.dart';

import '../../../models/rental_model.dart';
import '../../../services/rental_service.dart';
import '../../../services/user_service.dart';

class RentalDetailController extends GetxController {
  final Rxn<RentalModel> rental = Rxn<RentalModel>();
  final RxBool isLoading = true.obs;

  final RentalService _rentalService = Get.find();
  final UserService _userService = Get.find();
  final PaymentService _paymentService = Get.find();
  final DamageReportService _damageReportService = Get.find();

  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxList<DamageReportModel> damageReports = <DamageReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final args = Get.arguments;
    if (args is RentalModel) {
      rental.value = args;
      isLoading.value = false;
      _bindStreams();
    } else if (args is String) {
      await _fetchRental(args);
    } else {
      isLoading.value = false;
      AppSnackBar.error(title: 'error'.tr, message: 'invalid_nav_arguments'.tr);
    }
  }

  Future<void> _fetchRental(String rentalId) async {
    try {
      isLoading.value = true;
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        AppSnackBar.error(title: 'error'.tr, message: 'shop_id_not_found'.tr);
        return;
      }

      final doc = await _rentalService.getRentalOnce(shopId, rentalId);
      if (doc.exists) {
        rental.value = RentalModel.fromSnapshot(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
        _bindStreams();
      } else {
        AppSnackBar.error(title: 'error'.tr, message: 'rental_not_found'.tr);
      }
    } catch (e) {
      AppSnackBar.error(
        title: 'error'.tr,
        message: 'failed_load_rental_details'.trParams({'error': e.toString()}),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _bindStreams() {
    final currentRental = rental.value;
    if (currentRental != null && currentRental.id != null) {
      payments.bindStream(
        _paymentService.paymentStream(currentRental.shopId, currentRental.id!),
      );
      damageReports.bindStream(
        _damageReportService.getDamageReports(
          shopId: currentRental.shopId,
          rentalId: currentRental.id!,
        ),
      );
    }
  }

  Stream<List<DamagePhotoModel>> getDamagePhotos(String damageId) {
    final currentRental = rental.value;
    if (currentRental == null || currentRental.id == null) {
      return Stream.value([]);
    }
    return _damageReportService.getDamagePhotos(
      shopId: currentRental.shopId,
      rentalId: currentRental.id!,
      damageId: damageId,
    );
  }

  Future<void> openDocument(String? url) async {
    if (url == null || url.isEmpty) {
      AppSnackBar.error(title: 'error'.tr, message: 'doc_link_unavailable'.tr);
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      AppSnackBar.error(title: 'error'.tr, message: 'could_not_open_doc'.tr);
    }
  }

  void proceedToNextStep() {
    final currentRental = rental.value;
    if (currentRental == null) return;

    if (currentRental.status == RentalStatus.item_returned) {
      Get.toNamed(
        Routes.PAYMENTS,
        arguments: {
          'rentalId': currentRental.id,
          'shopId': currentRental.shopId,
        },
      );
    } else if (currentRental.status != RentalStatus.completed &&
        currentRental.status != RentalStatus.cancelled) {
      Get.toNamed(Routes.BOARD_INSPECTION, arguments: currentRental.id);
    }
  }
}
