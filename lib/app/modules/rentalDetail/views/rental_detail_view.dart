import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rental_detail_controller.dart';

class RentalDetailView extends GetView<RentalDetailController> {
  const RentalDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rental Details'),
      ),
      body: Center(
        child: Text('Rental ID: ${controller.rental.id}'),
      ),
    );
  }
}
