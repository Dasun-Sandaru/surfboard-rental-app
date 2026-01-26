import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ConfigService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'ConfigService';

  final RxBool isMaintenanceMode = false.obs;
  final RxString maintenanceMessage =
      'App is currently under maintenance. Please try again later.'.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToMaintenanceConfig();
  }

  void _listenToMaintenanceConfig() {
    try {
      log('Listening to maintenance config', name: logName);
      _db
          .collection('config')
          .doc('maintenance')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.exists && snapshot.data() != null) {
                final data = snapshot.data()!;
                isMaintenanceMode.value = data['is_active'] ?? false;
                if (data['message'] != null) {
                  maintenanceMessage.value = data['message'];
                }
                log(
                  'Maintenance mode updated: ${isMaintenanceMode.value}',
                  name: logName,
                );
              }
            },
            onError: (e) {
              log('Error listening to maintenance config: $e', name: logName);
            },
          );
    } catch (e) {
      log('Error initializing maintenance listener: $e', name: logName);
    }
  }

  Future<ConfigService> init() async {
    return this;
  }
}
