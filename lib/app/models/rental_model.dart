import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/firestore/firestore_fields.dart';

import '../../utils/constants/a_enums.dart';
import 'security_deposit_model.dart';

/// -----------------------------
/// Rental Model (Cleaned & Consistent)
/// -----------------------------
class RentalModel {
  final String? id;

  // Ownership
  final String shopId;
  final String customerId;
  final String itemId;
  final String staffId;

  // Time
  final DateTime startTime;
  final DateTime expectedReturnTime;
  final DateTime? actualReturnTime;

  // Status
  final RentalStatus status;
  final RentType rentType;
  final PaymentStatus paymentStatus;

  // Pricing snapshot
  final double rate; // hourly or daily rate
  final double amountExpected; // final rent amount
  final double amountPaid; // calculated from payments

  // Security deposit
  final SecurityDepositModel securityDeposit;

  // Agreement
  final String? agreementLink;
  final String? invoiceLink;
  final String? overdueTime;
  final String? cachedCustomerName;
  final String? cachedItemName;
  final String? cachedStaffName;

  // Meta
  final DateTime createdAt;

  const RentalModel({
    this.id,
    required this.shopId,
    required this.customerId,
    required this.itemId,
    required this.staffId,
    required this.startTime,
    required this.expectedReturnTime,
    this.actualReturnTime,
    required this.status,
    required this.rentType,
    required this.paymentStatus,
    required this.rate,
    required this.amountExpected,
    required this.amountPaid,
    required this.securityDeposit,
    this.agreementLink,
    this.invoiceLink,
    this.overdueTime,
    this.cachedCustomerName,
    this.cachedItemName,
    this.cachedStaffName,
    required this.createdAt,
  });

  /// -----------------------------
  /// From Firestore
  /// -----------------------------
  factory RentalModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return RentalModel(
      id: doc.id,
      shopId: data[FirestoreFields.shopId] as String,
      customerId: data[FirestoreFields.customerId] as String,
      itemId: data[FirestoreFields.itemId] as String,
      staffId: data[FirestoreFields.staffId] as String,

      startTime: (data[FirestoreFields.startTime] as Timestamp).toDate(),
      expectedReturnTime:
          (data[FirestoreFields.expectedReturnTime] as Timestamp).toDate(),
      actualReturnTime: data[FirestoreFields.actualReturnTime] != null
          ? (data[FirestoreFields.actualReturnTime] as Timestamp).toDate()
          : null,

      status: enumFromString(
        RentalStatus.values,
        data[FirestoreFields.status],
        RentalStatus.active,
      ),

      rentType: enumFromString(
        RentType.values,
        data[FirestoreFields.rentType],
        RentType.hourly,
      ),

      paymentStatus: enumFromString(
        PaymentStatus.values,
        data[FirestoreFields.paymentStatus],
        PaymentStatus.unpaid,
      ),

      rate: (data[FirestoreFields.rate] as num).toDouble(),
      amountExpected: (data[FirestoreFields.amountExpected] as num).toDouble(),
      amountPaid: (data[FirestoreFields.amountPaid] as num).toDouble(),

      securityDeposit: SecurityDepositModel.fromMap(
        data[FirestoreFields.securityDeposit],
      ),

      agreementLink: data[FirestoreFields.agreementLink],
      invoiceLink: data[FirestoreFields.invoiceLink],
      overdueTime: data[FirestoreFields.overdueTime],
      cachedCustomerName: data[FirestoreFields.cachedCustomerName],
      cachedItemName: data[FirestoreFields.cachedItemName],
      cachedStaffName: data[FirestoreFields.cachedStaffName],
      createdAt: (data[FirestoreFields.createdAt] as Timestamp).toDate(),
    );
  }

  /// -----------------------------
  /// To Firestore
  /// -----------------------------
  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.shopId: shopId,
      FirestoreFields.customerId: customerId,
      FirestoreFields.itemId: itemId,
      FirestoreFields.staffId: staffId,

      FirestoreFields.startTime: Timestamp.fromDate(startTime),
      FirestoreFields.expectedReturnTime: Timestamp.fromDate(
        expectedReturnTime,
      ),
      FirestoreFields.actualReturnTime: actualReturnTime != null
          ? Timestamp.fromDate(actualReturnTime!)
          : null,

      FirestoreFields.status: status.name,
      FirestoreFields.rentType: rentType.name,
      FirestoreFields.paymentStatus: paymentStatus.name,

      FirestoreFields.rate: rate,
      FirestoreFields.amountExpected: amountExpected,
      FirestoreFields.amountPaid: amountPaid,

      FirestoreFields.securityDeposit: securityDeposit.toMap(),

      FirestoreFields.agreementLink: agreementLink,
      FirestoreFields.invoiceLink: invoiceLink,
      FirestoreFields.overdueTime: overdueTime,
      FirestoreFields.cachedCustomerName: cachedCustomerName,
      FirestoreFields.cachedItemName: cachedItemName,
      FirestoreFields.cachedStaffName: cachedStaffName,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      FirestoreFields.itemNameLowercase: cachedItemName?.toLowerCase() ?? '',
      FirestoreFields.customerNameLowercase:
          cachedCustomerName?.toLowerCase() ?? '',
    };
  }
}