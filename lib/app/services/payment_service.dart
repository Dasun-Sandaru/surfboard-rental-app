import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_collections.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:surfboard_rental_app/app/services/activity_log_service.dart';

import '../../utils/constants/a_enums.dart';
import '../models/payment_model.dart';
import '../models/rental_model.dart'; // Import RentalModel for status checks

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'PaymentService';
  final ActivityLogService _activityLogService = ActivityLogService();

  // Helper to get Rental Doc Ref
  DocumentReference _rentalRef(String shopId, String rentalId) {
    return _db
        .collection(FirestoreCollections.shops)
        .doc(shopId)
        .collection(FirestoreCollections.rentals)
        .doc(rentalId);
  }

  // Helper to get Payment Colection Ref
  CollectionReference _paymentCollectionRef(String shopId, String rentalId) {
    return _rentalRef(
      shopId,
      rentalId,
    ).collection(FirestoreCollections.payments);
  }

  // ---------------- ADD PAYMENT (TRANSACTION) ----------------
  Future<void> addPayment({
    required String shopId,
    required String rentalId,
    required PaymentCategory category,
    required double amount,
    String? handledBy,
    PaymentMethod method = PaymentMethod.cash,
    String? note,
  }) async {
    try {
      final rentalDocRef = _rentalRef(shopId, rentalId);
      final paymentDocRef = _paymentCollectionRef(shopId, rentalId).doc();

      final payment = PaymentModel(
        id: paymentDocRef.id,
        rentalId: rentalId,
        amount: amount,
        category: category,
        method: method,
        handledBy: handledBy ?? 'System',
        timestamp: DateTime.now(),
        note: note,
      );

      await _db.runTransaction((transaction) async {
        // 1. Read Rental Document
        final rentalSnap = await transaction.get(rentalDocRef);
        if (!rentalSnap.exists) {
          throw Exception("Rental not found!");
        }

        // 2. Calculate New Totals
        final currentAmountPaid =
            (rentalSnap.data()
                    as Map<String, dynamic>)[FirestoreFields.amountPaid]
                as num? ??
            0.0;
        final amountExpected =
            (rentalSnap.data()
                    as Map<String, dynamic>)[FirestoreFields.amountExpected]
                as num? ??
            0.0;

        final newAmountPaid = currentAmountPaid + amount;

        // 3. Determine New Status
        PaymentStatus newStatus;
        if (newAmountPaid >= amountExpected) {
          newStatus = PaymentStatus.paid; // Or overpaid
        } else if (newAmountPaid > 0) {
          newStatus = PaymentStatus.partial;
        } else {
          newStatus = PaymentStatus.unpaid;
        }

        // 4. Write Payment
        transaction.set(paymentDocRef, payment.toMap());

        // 5. Update Rental
        transaction.update(rentalDocRef, {
          FirestoreFields.amountPaid: newAmountPaid,
          FirestoreFields.paymentStatus: newStatus.name,
        });

        // 6. Log Activity
        await _activityLogService.logActivity(
          shopId: shopId,
          type: ActivityType.add_payment,
          description: "Added payment of $amount for rental $rentalId",
          entityId: paymentDocRef.id,
          entityType: 'Payment',
          metadata: {
            'rentalId': rentalId,
            'amount': amount,
            'category': category.name,
          },
          transaction: transaction,
        );
      });

      log("Payment added: ${category.name} | $amount", name: logName);
    } catch (e) {
      log("Add payment failed: $e", name: logName);
      rethrow;
    }
  }

  // ---------------- STREAM PAYMENTS ----------------
  Stream<List<PaymentModel>> paymentStream(String shopId, String rentalId) {
    return _paymentCollectionRef(
      shopId,
      rentalId,
    ).orderBy(FirestoreFields.timestamp).snapshots().map((snapshot) {
      log("Payments fetched: ${snapshot.docs.length}", name: logName);
      return snapshot.docs
          .map(
            (d) => PaymentModel.fromSnapshot(
              d as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    });
  }

  // ---------------- ONE-TIME FETCH ----------------
  Future<List<PaymentModel>> getPayments(String shopId, String rentalId) async {
    try {
      final snapshot = await _paymentCollectionRef(
        shopId,
        rentalId,
      ).orderBy(FirestoreFields.timestamp).get();

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

  // ---------------- DELETE PAYMENT (TRANSACTION) ----------------
  Future<void> deletePayment({
    required String shopId,
    required String rentalId,
    required String paymentId,
  }) async {
    try {
      final rentalDocRef = _rentalRef(shopId, rentalId);
      final paymentDocRef = _paymentCollectionRef(
        shopId,
        rentalId,
      ).doc(paymentId);

      await _db.runTransaction((transaction) async {
        // 1. Read Payment Doc (to know amount to subtract)
        final paymentSnap = await transaction.get(paymentDocRef);
        if (!paymentSnap.exists) {
          throw Exception("Payment not found!");
        }
        final amountToReverse =
            (paymentSnap.data() as Map<String, dynamic>)[FirestoreFields.amount]
                as num;

        // 2. Read Rental Doc
        final rentalSnap = await transaction.get(rentalDocRef);
        if (!rentalSnap.exists) {
          // If rental doesn't exist, just delete the payment? Rigid consistency says throw error.
          throw Exception("Rental not found!");
        }

        // 3. Calculate New Totals
        final currentAmountPaid =
            (rentalSnap.data()
                    as Map<String, dynamic>)[FirestoreFields.amountPaid]
                as num? ??
            0.0;
        final amountExpected =
            (rentalSnap.data()
                    as Map<String, dynamic>)[FirestoreFields.amountExpected]
                as num? ??
            0.0;

        final newAmountPaid = currentAmountPaid - amountToReverse;

        // 4. Determine New Status
        PaymentStatus newStatus;
        if (newAmountPaid >= amountExpected) {
          newStatus = PaymentStatus.paid;
        } else if (newAmountPaid > 0) {
          newStatus = PaymentStatus.partial;
        } else {
          newStatus = PaymentStatus.unpaid;
        }

        // 5. Delete Payment
        transaction.delete(paymentDocRef);

        // 6. Update Rental
        transaction.update(rentalDocRef, {
          FirestoreFields.amountPaid: newAmountPaid,
          FirestoreFields.paymentStatus: newStatus.name,
        });

        // 7. Log Activity
        await _activityLogService.logActivity(
          shopId: shopId,
          type: ActivityType.delete_payment,
          description: "Deleted payment $paymentId ($amountToReverse)",
          entityId: paymentId,
          entityType: 'Payment',
          metadata: {'rentalId': rentalId, 'amountReversed': amountToReverse},
          transaction: transaction,
        );
      });

      log("Payment deleted: $paymentId", name: logName);
    } catch (e) {
      log("Delete payment failed: $e", name: logName);
      rethrow;
    }
  }
}
