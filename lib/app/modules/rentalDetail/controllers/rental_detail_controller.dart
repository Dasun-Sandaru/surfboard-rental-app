import 'package:get/get.dart';
import 'package:surfboard_rental_app/app/models/damage_photo_model.dart';
import 'package:surfboard_rental_app/app/models/damage_report_model.dart';
import 'package:surfboard_rental_app/app/models/payment_model.dart';
import 'package:surfboard_rental_app/app/services/damage_report_service.dart';
import 'package:surfboard_rental_app/app/services/payment_service.dart';
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
}
