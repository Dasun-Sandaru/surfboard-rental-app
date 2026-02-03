import 'package:get/get.dart';
import '../../../models/damage_photo_model.dart';
import '../../../models/damage_report_model.dart';
import '../../../models/payment_model.dart';
import '../../../services/damage_report_service.dart';
import '../../../services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/rental_model.dart';

class RentalDetailController extends GetxController {
  final RentalModel rental = Get.arguments;

  final PaymentService _paymentService = Get.find();
  final DamageReportService _damageReportService = Get.find();

  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxList<DamageReportModel> damageReports = <DamageReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (rental.id != null) {
      payments.bindStream(
        _paymentService.paymentStream(rental.shopId, rental.id!),
      );
      damageReports.bindStream(
        _damageReportService.getDamageReports(
          shopId: rental.shopId,
          rentalId: rental.id!,
        ),
      );
    }
  }

  Stream<List<DamagePhotoModel>> getDamagePhotos(String damageId) {
    if (rental.id == null) return Stream.value([]);
    return _damageReportService.getDamagePhotos(
      shopId: rental.shopId,
      rentalId: rental.id!,
      damageId: damageId,
    );
  }

  Future<void> openDocument(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar('Error', 'Document link is not available.');
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open document.');
    }
  }
}