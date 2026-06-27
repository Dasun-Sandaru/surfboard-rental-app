import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/firestore/firestore_collections.dart';
import '../../data/firestore/firestore_fields.dart';
import 'activity_log_service.dart';

import '../models/rental_model.dart';
import '../models/payment_model.dart';
import '../../utils/constants/a_enums.dart';
import '../../utils/helper/invoice_generator.dart';
import '../models/customer_model.dart';
import '../models/shop_model.dart';

class RentalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'RentalService';
  final supabase = Supabase.instance.client;
  final ActivityLogService _activityLogService = ActivityLogService();

  DocumentReference _shopRef(String shopId) {
    return _db.collection(FirestoreCollections.shops).doc(shopId);
  }

  Future<String> _uploadAgreementPdf(
    String shopId,
    String rentalId,
    Uint8List pdfData,
  ) async {
    try {
      log('Uploading agreement PDF for rental: $rentalId', name: logName);

      final filePath = 'shops/$shopId/rentals/$rentalId/agreement.pdf';

      await supabase.storage
          .from('agreements')
          .uploadBinary(
            filePath,
            pdfData,
            fileOptions: const FileOptions(contentType: 'application/pdf'),
          );

      final String publicUrl = supabase.storage
          .from('agreements')
          .getPublicUrl(filePath);

      log('Agreement PDF uploaded: $publicUrl', name: logName);
      return publicUrl;
    } catch (e) {
      log('Error uploading agreement PDF: $e', name: logName);
      rethrow;
    }
  }

  Future<String> _uploadInvoicePdf(
    String shopId,
    String rentalId,
    Uint8List pdfData,
  ) async {
    try {
      log('Uploading invoice PDF for rental: $rentalId', name: logName);

      final filePath = 'shops/$shopId/rentals/$rentalId/invoice.pdf';

      await supabase.storage
          .from('invoices')
          .uploadBinary(
            filePath,
            pdfData,
            fileOptions: const FileOptions(contentType: 'application/pdf'),
          );

      final String publicUrl = supabase.storage
          .from('invoices')
          .getPublicUrl(filePath);

      log('Invoice PDF uploaded: $publicUrl', name: logName);
      return publicUrl;
    } catch (e) {
      log('Error uploading invoice PDF: $e', name: logName);
      rethrow;
    }
  }

  Future<String> createRental(
    String shopId,
    RentalModel rentalData,
    Uint8List pdfData,
  ) async {
    try {
      log('Creating new rental for shop: $shopId', name: logName);

      // 1. Prepare Document References
      final rentalRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.rentals).doc();
      final rentalId = rentalRef.id;

      final inventoryRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.inventory).doc(rentalData.itemId);

      final customerRef = _shopRef(shopId)
          .collection(FirestoreCollections.customers)
          .doc(
            rentalData.customerId,
          ); // Assumes rentalData has customerId property

      // 2. Upload the agreement PDF (Outside Transaction)
      // Uploading files is slow and should not be done inside a transaction
      final agreementLink = await _uploadAgreementPdf(
        shopId,
        rentalId,
        pdfData,
      );

      // 3. Run Transaction
      await _db.runTransaction((transaction) async {
        final inventorySnap = await transaction.get(inventoryRef);
        final customerSnap = await transaction.get(customerRef);

        if (!inventorySnap.exists) {
          throw Exception("Inventory item does not exist!");
        }
        if (!customerSnap.exists) {
          throw Exception("Customer does not exist!");
        }

        final currentStatus = inventorySnap.get(FirestoreFields.status);
        if (currentStatus !=
            InventoryStatus.available.toString().split('.').last) {
          throw Exception(
            "Item is not available for rent! (Status: $currentStatus)",
          );
        }

        // Write Rental Data
        transaction.set(rentalRef, {
          ...rentalData.toMap(),
          FirestoreFields.id: rentalId,
          FirestoreFields.agreementLink: agreementLink,
          FirestoreFields.createdAt: FieldValue.serverTimestamp(),
        });

        // Update Inventory Status
        transaction.update(inventoryRef, {
          FirestoreFields.status: InventoryStatus.rented
              .toString()
              .split('.')
              .last,
        });

        // Update Customer Stats
        transaction.update(customerRef, {
          FirestoreFields.rentalsCount: FieldValue.increment(1),
          FirestoreFields.lastRentalDate: FieldValue.serverTimestamp(),
        });

        // --- LEDGER ENTRIES ---
        final paymentCollectionRef = rentalRef.collection(
          FirestoreCollections.payments,
        );

        // 1. Rental Charge (Debit)
        // amountExpected now only represents the base rental fee liability.
        final rentalFee = rentalData.amountExpected;
        if (rentalFee > 0) {
          final p = PaymentModel(
            rentalId: rentalId,
            amount: rentalFee,
            category: PaymentCategory.rental,
            method: PaymentMethod.cash,
            handledBy: 'System',
            timestamp: DateTime.now(),
            note: 'Base rental fee',
          );
          transaction.set(paymentCollectionRef.doc(), p.toMap());
        }

        // 2. Initial Security Deposit Payment (Credit)
        // This acts as the sole record of the deposit being handed over. We don't create a
        // 'charge' for it because it's tracked separately from the main rental liability.
        if (rentalData.securityDeposit.paid > 0) {
          final p = PaymentModel(
            rentalId: rentalId,
            amount: rentalData.securityDeposit.paid,
            category: PaymentCategory.deposit,
            method: PaymentMethod.cash,
            handledBy: rentalData.cachedStaffName ?? 'System',
            timestamp: DateTime.now(),
            note: 'Initial security deposit collected',
          );
          transaction.set(paymentCollectionRef.doc(), p.toMap());
        }

        // Log Activity
        await _activityLogService.logActivity(
          shopId: shopId,
          type: ActivityType.create_rental,
          description: "Created rental for ${rentalData.customerId}",
          entityId: rentalId,
          entityType: 'Rental',
          metadata: {
            'amountExpected': rentalData.amountExpected,
            'items': rentalData.itemId,
          },
          transaction: transaction,
        );

        // Send Email via Firebase Trigger Email Extension
        final customerEmail =
            customerSnap.data()?.containsKey(FirestoreFields.email) == true
            ? customerSnap.get(FirestoreFields.email)
            : null;
        final customerFirstName =
            customerSnap.data()?.containsKey(FirestoreFields.firstName) == true
            ? customerSnap.get(FirestoreFields.firstName)
            : 'Customer';

        if (customerEmail != null && customerEmail.toString().isNotEmpty) {
          final mailRef = _db.collection(FirestoreCollections.mail).doc();
          transaction.set(mailRef, {
            'to': customerEmail,
            'message': {
              'subject': 'Your Surfboard Rental Agreement',
              'html':
                  '''
                <h3>Hello $customerFirstName,</h3>
                <p>Thank you for renting with us!</p>
                <p>You can view and download your rental agreement using the link below:</p>
                <p><a href="$agreementLink">View Rental Agreement</a></p>
                <br>
                <p>Best regards,<br>The Surfboard Rental Team</p>
              ''',
            },
          });
        }

        // --- NOTIFICATION TRIGGER ---
        final triggerRef = _shopRef(shopId).collection('notification_triggers').doc(rentalId);
        transaction.set(triggerRef, {
          'rentalId': rentalId,
          'shopId': shopId,
          'expectedReturnTime': Timestamp.fromDate(rentalData.expectedReturnTime),
          'status': 'pending',
          'title': 'Rental Return Due',
          'body': 'Rental for ${rentalData.cachedItemName ?? "Item"} is due.',
        });
      });

      log('Rental created successfully: $rentalId', name: logName);
      return rentalId;
    } catch (e) {
      log('Error creating rental: $e', name: logName);
      // NOTE: If the transaction fails, the PDF is still uploaded.
      // In a production app, you might want to delete the orphaned file here.
      rethrow;
    }
  }

  // Stream rental by ID
  Stream<RentalModel> streamRentalById(String shopId, String rentalId) {
    final docRef = _shopRef(
      shopId,
    ).collection(FirestoreCollections.rentals).doc(rentalId);

    return docRef.snapshots().map((doc) {
      return RentalModel.fromSnapshot(doc);
    });
  }

  // Get rental once (for QR scanner and one-time fetches)
  Future<DocumentSnapshot> getRentalOnce(String shopId, String rentalId) async {
    try {
      log('Fetching rental once: $rentalId', name: logName);
      final docRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.rentals).doc(rentalId);

      return await docRef.get();
    } catch (e) {
      log('Error fetching rental: $e', name: logName);
      rethrow;
    }
  }

  Future<void> deleteRental(String shopId, String rentalId) async {
    try {
      log('Deleting rental: $rentalId', name: logName);

      final docRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.rentals).doc(rentalId);

      final triggerRef = _shopRef(shopId).collection('notification_triggers').doc(rentalId);

      await docRef.delete();
      await triggerRef.delete();

      log('Rental deleted: $rentalId', name: logName);
    } catch (e) {
      log('Error deleting rental: $e', name: logName);
      rethrow;
    }
  }

  Future<void> updateRental(String shopId, RentalModel rentalData) async {
    try {
      log('Updating rental: ${rentalData.id}', name: logName);

      final docRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.rentals).doc(rentalData.id);

      await docRef.update(rentalData.toMap());

      log('Rental updated: ${rentalData.id}', name: logName);
    } catch (e) {
      log('Error updating rental: $e', name: logName);
      rethrow;
    }
  }

  Future<void> finalizeReturn({
    required String shopId,
    required String rentalId,
    required String itemId,
    RentalStatus status = RentalStatus.completed,
    InventoryStatus inventoryStatus = InventoryStatus.available,
    String? overdueTime,
  }) async {
    try {
      log('Finalizing return for rental: $rentalId', name: logName);

      final shopRef = _shopRef(shopId);
      final rentalRef = shopRef
          .collection(FirestoreCollections.rentals)
          .doc(rentalId);
      final inventoryRef = shopRef
          .collection(FirestoreCollections.inventory)
          .doc(itemId);

      // 1. Fetch data for Invoice Generation (Only on final completion)
      String? invoiceLink;

      if (status == RentalStatus.completed) {
        final shopSnap =
            await shopRef.get() as DocumentSnapshot<Map<String, dynamic>>;
        final rentalSnap = await rentalRef.get();

        if (!shopSnap.exists || !rentalSnap.exists) {
          throw Exception("Shop or Rental data missing for invoice generation");
        }

        final shop = ShopModel.fromSnapshot(shopSnap);
        final rental = RentalModel.fromSnapshot(rentalSnap);

        final customerSnap = await shopRef
            .collection(FirestoreCollections.customers)
            .doc(rental.customerId)
            .get();
        if (!customerSnap.exists) {
          throw Exception("Customer data missing for invoice generation");
        }
        final customer = CustomerModel.fromSnapshot(customerSnap);

        final paymentsQuery = await rentalRef
            .collection(FirestoreCollections.payments)
            .get();
        final payments = paymentsQuery.docs
            .map((d) => PaymentModel.fromSnapshot(d))
            .toList();

        // 2. Generate PDF
        final pdfData = await InvoiceGenerator.generateInvoice(
          shop: shop,
          customer: customer,
          rental: rental,
          payments: payments,
        );

        // 3. Upload PDF
        invoiceLink = await _uploadInvoicePdf(shopId, rentalId, pdfData);
      }

      // 4. Transaction to update statuses and add invoiceLink
      await _db.runTransaction((transaction) async {
        final currentRentalSnap = await transaction.get(rentalRef);
        final hasActualReturnTime =
            currentRentalSnap.data()?[FirestoreFields.actualReturnTime] != null;

        transaction.update(rentalRef, {
          FirestoreFields.status: status.toString().split('.').last,
          if (!hasActualReturnTime)
            FirestoreFields.actualReturnTime: FieldValue.serverTimestamp(),
          if (invoiceLink != null) FirestoreFields.invoiceLink: invoiceLink,
          if (overdueTime != null) FirestoreFields.overdueTime: overdueTime,
        });

        transaction.update(inventoryRef, {
          FirestoreFields.status: inventoryStatus.toString().split('.').last,
        });

        await _activityLogService.logActivity(
          shopId: shopId,
          type: ActivityType.return_rental,
          description: "Returned rental $rentalId",
          entityId: rentalId,
          entityType: 'Rental',
          metadata: {
            'itemId': itemId,
            'inventoryStatus': inventoryStatus.toString().split('.').last,
            'invoiceLink': invoiceLink,
          },
          transaction: transaction,
        );

        // --- CANCEL NOTIFICATION TRIGGER ---
        final triggerRef = shopRef.collection('notification_triggers').doc(rentalId);
        final triggerSnap = await transaction.get(triggerRef);
        if (triggerSnap.exists) {
          transaction.update(triggerRef, {
            'status': 'completed',
          });
        }
      });

      log(
        'Return finalized for rental: $rentalId (Transaction Committed)',
        name: logName,
      );
    } catch (e) {
      log('Error finalizing return: $e', name: logName);
      rethrow;
    }
  }

  /// Settles the rental balance by applying the security deposit directly
  /// to the rental's amountPaid field. This is NOT recorded as a payment
  /// entry because no new cash is changing hands — it's an internal transfer.
  Future<void> settleRentalBalance({
    required String shopId,
    required String rentalId,
    required double depositApplied,
    required double refundedAmount,
  }) async {
    try {
      log(
        'Settling rental balance: $rentalId (depositApplied: $depositApplied, refunded: $refundedAmount)',
        name: logName,
      );
      final rentalRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.rentals).doc(rentalId);

      await _db.runTransaction((transaction) async {
        final rentalSnap = await transaction.get(rentalRef);
        if (!rentalSnap.exists) throw Exception("Rental not found!");

        final data = rentalSnap.data() as Map<String, dynamic>;
        final currentAmountPaid =
            (data[FirestoreFields.amountPaid] as num? ?? 0.0).toDouble();
        final amountExpected =
            (data[FirestoreFields.amountExpected] as num? ?? 0.0).toDouble();

        final newAmountPaid = currentAmountPaid + depositApplied;

        // Determine payment status
        PaymentStatus newStatus;
        if (newAmountPaid >= amountExpected && amountExpected > 0) {
          newStatus = PaymentStatus.paid;
        } else if (newAmountPaid > 0) {
          newStatus = PaymentStatus.partial;
        } else {
          newStatus = PaymentStatus.unpaid;
        }

        transaction.update(rentalRef, {
          FirestoreFields.amountPaid: newAmountPaid,
          FirestoreFields.paymentStatus: newStatus.name,
          '${FirestoreFields.securityDeposit}.refunded': refundedAmount,
        });
      });

      log('Rental balance settled for: $rentalId', name: logName);
    } catch (e) {
      log('Error settling rental balance: $e', name: logName);
      rethrow;
    }
  }

  Future<void> addLateFeeCharge({
    required String shopId,
    required String rentalId,
    required double amount,
    required String handledBy,
  }) async {
    try {
      log(
        'Adding late fee charge of $amount to rental: $rentalId',
        name: logName,
      );
      final rentalRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.rentals).doc(rentalId);

      // Create a unique ID for the payment record
      final paymentRef = rentalRef
          .collection(FirestoreCollections.payments)
          .doc();

      // Transaction to ensure atomicity
      await _db.runTransaction((transaction) async {
        // 1. Update Rental amountExpected
        transaction.update(rentalRef, {
          FirestoreFields.amountExpected: FieldValue.increment(amount),
        });

        // 2. Create Payment Record (for ledger audit)
        transaction.set(paymentRef, {
          FirestoreFields.rentalId: rentalId,
          FirestoreFields.amount: amount,
          FirestoreFields.category: PaymentCategory.lateFee.name,
          FirestoreFields.method: PaymentMethod.cash.name, // Charge placeholder
          FirestoreFields.handledBy: handledBy,
          FirestoreFields.timestamp: FieldValue.serverTimestamp(),
          FirestoreFields.note: "Automated Late Fee Calculation",
        });

        // 3. Log Activity
        await _activityLogService.logActivity(
          shopId: shopId,
          type: ActivityType.add_payment,
          description: "Applied late fee of $amount for rental $rentalId",
          entityId: paymentRef.id,
          entityType: 'Payment',
          metadata: {
            'rentalId': rentalId,
            'amount': amount,
            'category': 'lateFee',
          },
          transaction: transaction,
        );
      });

      log('Late fee charge added to rental: $rentalId', name: logName);
    } catch (e) {
      log('Error adding late fee charge: $e', name: logName);
      rethrow;
    }
  }

  Future<void> addDamageCharge({
    required String shopId,
    required String rentalId,
    required double amount,
    required String damageType,
    String? handledBy,
  }) async {
    try {
      log(
        'Adding $damageType charge of $amount to rental: $rentalId',
        name: logName,
      );
      final rentalRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.rentals).doc(rentalId);
      final paymentRef = rentalRef
          .collection(FirestoreCollections.payments)
          .doc();

      await _db.runTransaction((transaction) async {
        // 1. Increment Expected Amount
        transaction.update(rentalRef, {
          FirestoreFields.amountExpected: FieldValue.increment(amount),
        });

        // 2. Create Ledger Entry
        final p = PaymentModel(
          rentalId: rentalId,
          amount: amount,
          category: PaymentCategory.damageFee,
          method: PaymentMethod.cash,
          handledBy: handledBy ?? 'System',
          timestamp: DateTime.now(),
          note: 'Damage charge: $damageType',
        );
        transaction.set(paymentRef, p.toMap());

        // 3. Log Activity
        await _activityLogService.logActivity(
          shopId: shopId,
          type: ActivityType.report_damage,
          description: "Applied $damageType charge of $amount",
          entityId: rentalId,
          entityType: 'Rental',
          metadata: {'amount': amount, 'type': damageType},
          transaction: transaction,
        );
      });
      log('Damage charge added to rental: $rentalId', name: logName);
    } catch (e) {
      log('Error adding damage charge: $e', name: logName);
      rethrow;
    }
  }

  Future<void> updateRentalStatus({
    required String shopId,
    required String rentalId,
    required RentalStatus status,
  }) async {
    try {
      final docRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.rentals).doc(rentalId);
      await docRef.update({
        FirestoreFields.status: status.toString().split('.').last,
      });
    } catch (e) {
      log('Error updating rental status: $e', name: logName);
      rethrow;
    }
  }

  Future<void> updateInventoryStatus({
    required String shopId,
    required String itemId,
    required InventoryStatus status,
  }) async {
    try {
      final docRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.inventory).doc(itemId);
      await docRef.update({
        FirestoreFields.status: status.toString().split('.').last,
      });
    } catch (e) {
      log('Error updating inventory status: $e', name: logName);
      rethrow;
    }
  }

  Future<QuerySnapshot> getRentalsPage({
    required String shopId,
    required int limit,
    DocumentSnapshot? startAfter,
    String? searchTerm,
    RentalStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      log('Fetching rentals page for shop: $shopId', name: logName);
      Query query = _shopRef(shopId).collection(FirestoreCollections.rentals);

      if (status != null) {
        query = query.where(
          FirestoreFields.status,
          isEqualTo: status.toString().split('.').last,
        );
      }

      if (startDate != null && endDate != null) {
        query = query
            .where(FirestoreFields.createdAt, isGreaterThanOrEqualTo: startDate)
            .where(FirestoreFields.createdAt, isLessThanOrEqualTo: endDate);
      }

      if (searchTerm != null && searchTerm.isNotEmpty) {
        final searchLower = searchTerm.toLowerCase();
        // Since Firestore can't do OR queries with range filters effectively across different fields,
        // we'll prioritize Item Name search here, or we'd need a composite field if both are needed at once.
        // For now, let's allow searching by item name or customer name by checking both if possible,
        // but typically prefix search is best on one field.
        // I will implement search by item name lowercase as the primary search field for "active rentals"
        // or optimize it to check either if we can.
        // Actually, for multiple fields, we might need a combined lowercase field or search twice.
        // Let's settle for searching by itemName_lowercase for now as board identity is primary.

        query = query
            .where(
              FirestoreFields.itemNameLowercase,
              isGreaterThanOrEqualTo: searchLower,
            )
            .where(
              FirestoreFields.itemNameLowercase,
              isLessThan: '${searchLower}z',
            )
            .limit(limit);
      } else {
        query = query
            .orderBy(FirestoreFields.createdAt, descending: true)
            .limit(limit);

        if (startAfter != null) {
          query = query.startAfterDocument(startAfter);
        }
      }

      return await query.get();
    } catch (e) {
      log('Error fetching rentals page: $e', name: logName);
      rethrow;
    }
  }

  Future<int> getRentalCountByStatus(String shopId, String status) async {
    try {
      log(
        'Counting rentals with status $status for shop: $shopId',
        name: logName,
      );
      final aggregateQuery = await _shopRef(shopId)
          .collection(FirestoreCollections.rentals)
          .where(FirestoreFields.status, isEqualTo: status)
          .count()
          .get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      log('Error counting rentals: $e', name: logName);
      rethrow;
    }
  }

  Stream<int> streamRentalCountByStatus(String shopId, String status) {
    return _shopRef(shopId)
        .collection(FirestoreCollections.rentals)
        .where(FirestoreFields.status, isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ---------------------------------------------------------------------------
  // SAVE CUSTOMER RATING IN RENTAL
  // ---------------------------------------------------------------------------
  Future<void> saveCustomerRating({
    required String shopId,
    required String rentalId,
    required double rating,
    required String comment,
  }) async {
    try {
      log('Saving customer rating in rental: $rentalId', name: logName);
      final rentalRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.rentals).doc(rentalId);

      await rentalRef.update({
        FirestoreFields.customerRating: rating,
        FirestoreFields.customerRatingComment: comment,
      });

      log('Customer rating saved in rental: $rentalId', name: logName);
    } catch (e) {
      log('Error saving customer rating in rental: $e', name: logName);
      rethrow;
    }
  }
}
