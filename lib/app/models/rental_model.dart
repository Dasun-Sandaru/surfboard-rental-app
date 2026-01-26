import 'package:cloud_firestore/cloud_firestore.dart';

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
    required this.createdAt,
  });

  /// -----------------------------
  /// From Firestore
  /// -----------------------------
  factory RentalModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return RentalModel(
      id: doc.id,
      shopId: data['shopId'] as String,
      customerId: data['customerId'] as String,
      itemId: data['itemId'] as String,
      staffId: data['staffId'] as String,

      startTime: (data['startTime'] as Timestamp).toDate(),
      expectedReturnTime: (data['expectedReturnTime'] as Timestamp).toDate(),
      actualReturnTime: data['actualReturnTime'] != null
          ? (data['actualReturnTime'] as Timestamp).toDate()
          : null,

      status: enumFromString(
        RentalStatus.values,
        data['status'],
        RentalStatus.active,
      ),

      rentType: enumFromString(
        RentType.values,
        data['rentType'],
        RentType.hourly,
      ),

      paymentStatus: enumFromString(
        PaymentStatus.values,
        data['paymentStatus'],
        PaymentStatus.unpaid,
      ),

      rate: (data['rate'] as num).toDouble(),
      amountExpected: (data['amountExpected'] as num).toDouble(),
      amountPaid: (data['amountPaid'] as num).toDouble(),

      securityDeposit: SecurityDepositModel.fromMap(data['securityDeposit']),

      agreementLink: data['agreementLink'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// -----------------------------
  /// To Firestore
  /// -----------------------------
  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'customerId': customerId,
      'itemId': itemId,
      'staffId': staffId,

      'startTime': Timestamp.fromDate(startTime),
      'expectedReturnTime': Timestamp.fromDate(expectedReturnTime),
      'actualReturnTime': actualReturnTime != null
          ? Timestamp.fromDate(actualReturnTime!)
          : null,

      'status': status.name,
      'rentType': rentType.name,
      'paymentStatus': paymentStatus.name,

      'rate': rate,
      'amountExpected': amountExpected,
      'amountPaid': amountPaid,

      'securityDeposit': securityDeposit.toMap(),

      'agreementLink': agreementLink,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
