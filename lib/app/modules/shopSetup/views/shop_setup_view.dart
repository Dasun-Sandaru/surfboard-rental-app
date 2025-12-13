import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/shop_setup_controller.dart';

class ShopSetupView extends GetView<ShopSetupController> {
  const ShopSetupView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShopSetupView'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Title
            Text(
              'Set Up Your Shop',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            /// Sub Title
            Text(
              'Tell us a little about your surf shop to get started.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            /// Shop Name
            /// Shop Location
            /// Shop Contact Number
            /// Shop Email
            /// Shop Logo
          ],
        ),
      ),
    );
  }
}
