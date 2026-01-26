import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import '../../utils/constants/a_enums.dart';

class PaymentModel {
  final String? id;
  final String rentalId;
  final double amount;

  /// Only store category – debit/credit is derived
  final PaymentCategory category;

  final PaymentMethod method;
  final String handledBy;
  final DateTime timestamp;
  final String? note;

  const PaymentModel({
    this.id,
    required this.rentalId,
    required this.amount,
    required this.category,
    required this.method,
    required this.handledBy,
    required this.timestamp,
    this.note,
  });

  factory PaymentModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PaymentModel(
      id: doc.id,
      rentalId: data[FirestoreFields.rentalId],
      amount: (data[FirestoreFields.amount] as num).toDouble(),
      category: PaymentCategory.values.byName(data[FirestoreFields.category]),
      method: PaymentMethod.values.byName(data[FirestoreFields.method]),
      handledBy: data[FirestoreFields.handledBy],
      timestamp: (data[FirestoreFields.timestamp] as Timestamp).toDate(),
      note: data[FirestoreFields.note],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.rentalId: rentalId,
      FirestoreFields.amount: amount,
      FirestoreFields.category: category.name,
      FirestoreFields.method: method.name,
      FirestoreFields.handledBy: handledBy,
      FirestoreFields.timestamp: Timestamp.fromDate(timestamp),
      FirestoreFields.note: note,
    };
  }
}
