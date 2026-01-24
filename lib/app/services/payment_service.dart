import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/constants/a_enums.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'PaymentService';

  CollectionReference _paymentRef(String shopId, String rentalId) {
    return _db
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .doc(rentalId)
        .collection('payments');
  }

  // ---------------- ADD PAYMENT ----------------
  Future<void> addPayment({
    required String shopId,
    required String rentalId,
    required PaymentCategory category,
    required double amount,
    String? handledBy,
    PaymentMethod method = PaymentMethod.cash,
  }) async {
    try {
      final docRef = _paymentRef(shopId, rentalId).doc();

      final payment = PaymentModel(
        id: docRef.id,
        rentalId: rentalId,
        amount: amount,
        category: category,
        method: method,
        handledBy: handledBy!,
        timestamp: DateTime.now(),
      );

      await docRef.set(payment.toMap());

      log("Payment added: ${category.name} | $amount", name: logName);
    } catch (e) {
      log("Add payment failed: $e", name: logName);
      rethrow;
    }
  }

  // ---------------- STREAM PAYMENTS ----------------
  Stream<List<PaymentModel>> paymentStream(String shopId, String rentalId) {
    return _paymentRef(shopId, rentalId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (d) => PaymentModel.fromSnapshot(
                  d as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
        );
  }

  // ---------------- ONE-TIME FETCH ----------------
  Future<List<PaymentModel>> getPayments(String shopId, String rentalId) async {
    try {
      final snapshot = await _paymentRef(
        shopId,
        rentalId,
      ).orderBy('createdAt').get();

      return snapshot.docs
          .map(
            (doc) => PaymentModel.fromSnapshot(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    } catch (e) {
      log("Fetch payments failed: $e", name: logName);
      rethrow;
    }
  }

  // ---------------- DELETE PAYMENT (ADMIN) ----------------
  Future<void> deletePayment({
    required String shopId,
    required String rentalId,
    required String paymentId,
  }) async {
    try {
      await _paymentRef(shopId, rentalId).doc(paymentId).delete();
      log("Payment deleted: $paymentId", name: logName);
    } catch (e) {
      log("Delete payment failed: $e", name: logName);
      rethrow;
    }
  }
}
