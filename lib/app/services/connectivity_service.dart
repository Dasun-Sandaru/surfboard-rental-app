import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final RxBool isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = [ConnectivityResult.none];
    }
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    // Check if there is at least one active connection type
    bool hasConnection = result.any((r) => r != ConnectivityResult.none);

    // Only react if status changed
    if (hasConnection != isConnected.value) {
      isConnected.value = hasConnection;
      if (!hasConnection) {
        _showNoConnectionSnackbar();
      } else {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        _showRestoredSnackbar();
      }
    }
  }

  void _showNoConnectionSnackbar() {
    Get.rawSnackbar(
      messageText: const Text(
        'No Internet Connection',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      icon: const Icon(Iconsax.wifi_square, color: Colors.white),
      backgroundColor: Colors.red,
      isDismissible: false,
      duration: const Duration(days: 1), // Persistent until dismissed manually or restored
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  void _showRestoredSnackbar() {
    Get.snackbar(
      'Online',
      'Internet connection restored',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Iconsax.wifi, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
    );
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
