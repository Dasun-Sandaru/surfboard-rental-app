import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/rental_detail_controller.dart';

class RentalDetailView extends GetView<RentalDetailController> {
  const RentalDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Rental Details'),
        actions: [
          IconButton(
            onPressed: controller.showQR,
            icon: Icon(Iconsax.scan_barcode, color: colorScheme.onSurface),
            tooltip: 'Show QR Code',
          ),
        ],
      ),
      body: Center(child: Text('Rental ID: ${controller.rental.id}')),
    );
  }
}
