import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/damage_report_model.dart';
import '../models/damage_photo_model.dart';
import '../models/payment_model.dart';
import '../../utils/constants/a_enums.dart';

class DamageReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // -----------------------------
  // Create Payment for Damage Fee
  // -----------------------------
  Future<void> createPayment({
    required String shopId,
    required String rentalId,
    required PaymentModel payment,
  }) async {
    final ref = _db
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .doc(rentalId)
        .collection('payments')
        .doc();

    await ref.set(payment.toMap());
  }

  // -----------------------------
  // Upload Photo (Firebase)
  // -----------------------------
  Future<String> uploadPhoto({required File file, required String path}) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload photo to Firebase: $e');
    }
  }

  // -----------------------------
  // Upload Photo (Supabase)
  // -----------------------------
  Future<String> uploadPhotoSupabase({
    required File file,
    required String path,
    String bucketName = 'damage_images',
  }) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.storage
          .from(bucketName)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      final publicUrl = supabase.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload photo to Supabase: $e');
    }
  }

  // -----------------------------
  // Create Damage Report
  // -----------------------------
  Future<String> createDamageReport({
    required String shopId,
    required String rentalId,
    required DamageReportModel report,
  }) async {
    final ref = _db
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .doc(rentalId)
        .collection('damage_reports')
        .doc();

    await ref.set(report.toMap());
    return ref.id;
  }

  // -----------------------------
  // Add Photo to Damage Report
  // -----------------------------
  Future<void> addDamagePhoto({
    required String shopId,
    required String rentalId,
    required String damageId,
    required DamagePhotoModel photo,
  }) async {
    final ref = _db
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .doc(rentalId)
        .collection('damage_reports')
        .doc(damageId)
        .collection('photos')
        .doc();

    await ref.set(photo.toMap());
  }

  // -----------------------------
  // Approve Damage (Manager)
  // -----------------------------
  Future<void> approveDamage({
    required String shopId,
    required String rentalId,
    required String damageId,
    required double estimatedCost,
  }) async {
    final ref = _db
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .doc(rentalId)
        .collection('damage_reports')
        .doc(damageId);

    await ref.update({
      'status': DamageStatus.approved.name,
      'estimatedCost': estimatedCost,
    });
  }

  // -----------------------------
  // Resolve Damage (After Payment)
  // -----------------------------
  Future<void> resolveDamage({
    required String shopId,
    required String rentalId,
    required String damageId,
    required double finalCost,
  }) async {
    final ref = _db
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .doc(rentalId)
        .collection('damage_reports')
        .doc(damageId);

    await ref.update({
      'status': DamageStatus.resolved.name,
      'finalCost': finalCost,
      'resolvedAt': Timestamp.now(),
    });
  }

  // -----------------------------
  // Fetch Damage Reports (Rental)
  // -----------------------------
  Stream<List<DamageReportModel>> getDamageReports({
    required String shopId,
    required String rentalId,
  }) {
    return _db
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .doc(rentalId)
        .collection('damage_reports')
        .orderBy('reportedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DamageReportModel.fromSnapshot(doc))
              .toList(),
        );
  }

  // -----------------------------
  // Fetch Photos (Damage)
  // -----------------------------
  Stream<List<DamagePhotoModel>> getDamagePhotos({
    required String shopId,
    required String rentalId,
    required String damageId,
  }) {
    return _db
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .doc(rentalId)
        .collection('damage_reports')
        .doc(damageId)
        .collection('photos')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DamagePhotoModel.fromSnapshot(doc))
              .toList(),
        );
  }
}
