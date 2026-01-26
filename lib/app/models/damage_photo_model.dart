import 'package:cloud_firestore/cloud_firestore.dart';

class DamagePhotoModel {
  final String? id;
  final String damageId;
  final String photoUrl;

  final String uploadedBy;
  final DateTime uploadedAt;

  DamagePhotoModel({
    this.id,
    required this.damageId,
    required this.photoUrl,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  factory DamagePhotoModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return DamagePhotoModel(
      id: doc.id,
      damageId: data['damageId'],
      photoUrl: data['photoUrl'],
      uploadedBy: data['uploadedBy'],
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'damageId': damageId,
      'photoUrl': photoUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}
