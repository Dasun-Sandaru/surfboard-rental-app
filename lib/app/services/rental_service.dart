import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:surfboard_rental_app/app/models/rental_model.dart';

class RentalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String logName = 'RentalService';

  DocumentReference _shopRef(String shopId) {
    return _db.collection('shops').doc(shopId);
  }

  Future<String> _uploadAgreementPdf(
      String shopId, String rentalId, Uint8List pdfData) async {
    try {
      log('Uploading agreement PDF for rental: $rentalId', name: logName);
      final ref = _storage
          .ref('shops/$shopId/rentals/$rentalId/agreement.pdf');
      final uploadTask = ref.putData(pdfData, SettableMetadata(contentType: 'application/pdf'));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      log('Agreement PDF uploaded: $downloadUrl', name: logName);
      return downloadUrl;
    } catch (e) {
      log('Error uploading agreement PDF: $e', name: logName);
      rethrow;
    }
  }

  Future<String> createRental(String shopId, RentalModel rentalData, Uint8List pdfData) async {
    try {
      log('Creating new rental for shop: $shopId', name: logName);

      // 1. Create the rental document to get an ID
      final docRef = _shopRef(shopId).collection('rentals').doc();
      final rentalId = docRef.id;

      // 2. Upload the agreement PDF
      final agreementLink = await _uploadAgreementPdf(shopId, rentalId, pdfData);

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
