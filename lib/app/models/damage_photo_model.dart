import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/firestore/firestore_fields.dart';

class DamagePhotoModel {
  final String? id;
  final String damageId;
  final String photoUrl;

  final String uploadedBy;
  final DateTime uploadedAt;

  const DamagePhotoModel({
    this.id,
    required this.damageId,
    required this.photoUrl,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  factory DamagePhotoModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return DamagePhotoModel(
      id: doc.id,
      damageId: data[FirestoreFields.damageId],
      photoUrl: data[FirestoreFields.photoUrl],
      uploadedBy: data[FirestoreFields.uploadedBy],
      uploadedAt: (data[FirestoreFields.uploadedAt] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.damageId: damageId,
      FirestoreFields.photoUrl: photoUrl,
      FirestoreFields.uploadedBy: uploadedBy,
      FirestoreFields.uploadedAt: Timestamp.fromDate(uploadedAt),
    };
  }
}