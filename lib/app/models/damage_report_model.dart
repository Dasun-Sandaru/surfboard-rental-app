import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants/a_enums.dart';

class DamageReportModel {
  final String? id;

  // Relations
  final String rentalId;
  final String itemId;

  // Damage info
  final String damageType;
  final String? note;

  // Workflow
  final DamageStatus status;

  // Costing
  final double? estimatedCost;
  final double? finalCost;

  // Audit
  final String reportedBy; // staffId
  final DateTime reportedAt;
  final DateTime? resolvedAt;

  const DamageReportModel({
    this.id,
    required this.rentalId,
    required this.itemId,
    required this.damageType,
    this.note,
    required this.status,
    this.estimatedCost,
    this.finalCost,
    required this.reportedBy,
    required this.reportedAt,
    this.resolvedAt,
  });

  // -----------------------------
  // From Firestore
  // -----------------------------
  factory DamageReportModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return DamageReportModel(
      id: doc.id,
      rentalId: data['rentalId'],
      itemId: data['itemId'],
      damageType: data['damageType'] ?? 'Unknown',
      note: data['note'],
      status: enumFromString(
        DamageStatus.values,
        data['status'],
        DamageStatus.reported,
      ),
      estimatedCost: (data['estimatedCost'] as num?)?.toDouble(),
      finalCost: (data['finalCost'] as num?)?.toDouble(),
      reportedBy: data['reportedBy'],
      reportedAt: (data['reportedAt'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // -----------------------------
  // To Firestore
  // -----------------------------
  Map<String, dynamic> toMap() {
    return {
      'rentalId': rentalId,
      'itemId': itemId,
      'damageType': damageType,
      'note': note,
      'status': status.name,
      'estimatedCost': estimatedCost,
      'finalCost': finalCost,
      'reportedBy': reportedBy,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }
}
