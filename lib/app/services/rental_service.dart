import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/app/models/rental_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RentalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'RentalService';
  final supabase = Supabase.instance.client;

  DocumentReference _shopRef(String shopId) {
    return _db.collection('shops').doc(shopId);
  }

  Future<String> _uploadAgreementPdf(
    String shopId,
    String rentalId,
    Uint8List pdfData,
  ) async {
    try {
      log('Uploading agreement PDF for rental: $rentalId', name: logName);

      final filePath = 'shops/$shopId/rentals/$rentalId/agreement.pdf';

      await supabase.storage.from('agreements').uploadBinary(
            filePath,
            pdfData,
            fileOptions: const FileOptions(contentType: 'application/pdf'),
          );

      final String publicUrl =
          supabase.storage.from('agreements').getPublicUrl(filePath);

      log('Agreement PDF uploaded: $publicUrl', name: logName);
      return publicUrl;
    } catch (e) {
      log('Error uploading agreement PDF: $e', name: logName);
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

      // 1. Create the rental document to get an ID
      final docRef = _shopRef(shopId).collection('rentals').doc();
      final rentalId = docRef.id;

      // 2. Upload the agreement PDF
      final agreementLink = await _uploadAgreementPdf(
        shopId,
        rentalId,
        pdfData,
      );

      // 3. Set the full rental data including the agreement link
      await docRef.set({
        ...rentalData.toMap(),
        'id': rentalId,
        'agreementLink': agreementLink,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Update the inventory item status
      await _db
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(rentalData.itemId)
          .update({'status': 'Rented'});

      log('Rental created: $rentalId', name: logName);
      return rentalId;
    } catch (e) {
      log('Error creating rental: $e', name: logName);
      rethrow;
    }
  }
}