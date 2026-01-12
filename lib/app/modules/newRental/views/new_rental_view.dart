import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/new_rental_controller.dart';

class NewRentalView extends GetView<NewRentalController> {
  const NewRentalView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NewRentalView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'NewRentalView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
