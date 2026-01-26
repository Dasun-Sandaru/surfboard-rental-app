import 'package:cloud_firestore/cloud_firestore.dart';
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

  PaymentModel({
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
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PaymentModel(
      id: doc.id,
      rentalId: data['rentalId'],
      amount: (data['amount'] as num).toDouble(),
      category: PaymentCategory.values.byName(data['category']),
      method: PaymentMethod.values.byName(data['method']),
      handledBy: data['handledBy'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      note: data['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rentalId': rentalId,
      'amount': amount,
      'category': category.name,
      'method': method.name,
      'handledBy': handledBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
    };
  }
}
