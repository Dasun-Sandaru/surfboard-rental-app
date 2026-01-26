import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/app/models/rental_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/constants/a_enums.dart';

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

      await supabase.storage
          .from('agreements')
          .uploadBinary(
            filePath,
            pdfData,
            fileOptions: const FileOptions(contentType: 'application/pdf'),
          );

      final String publicUrl = supabase.storage
          .from('agreements')
          .getPublicUrl(filePath);

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
          .update({'status': InventoryStatus.rented.name});

      log('Rental created: $rentalId', name: logName);
      return rentalId;
    } catch (e) {
      log('Error creating rental: $e', name: logName);
      rethrow;
    }
  }

  // Stream rental by ID
  Stream<RentalModel> streamRentalById(String shopId, String rentalId) {
    final docRef = _shopRef(shopId).collection('rentals').doc(rentalId);

    return docRef.snapshots().map((doc) {
      return RentalModel.fromSnapshot(doc);
    });
  }

  Future<void> deleteRental(String shopId, String rentalId) async {
    try {
      log('Deleting rental: $rentalId', name: logName);

      final docRef = _shopRef(shopId).collection('rentals').doc(rentalId);

      await docRef.delete();

      log('Rental deleted: $rentalId', name: logName);
    } catch (e) {
      log('Error deleting rental: $e', name: logName);
      rethrow;
    }
  }

  Future<void> updateRental(String shopId, RentalModel rentalData) async {
    try {
      log('Updating rental: ${rentalData.id}', name: logName);

      final docRef = _shopRef(shopId).collection('rentals').doc(rentalData.id);

      await docRef.update(rentalData.toMap());

      log('Rental updated: ${rentalData.id}', name: logName);
    } catch (e) {
      log('Error updating rental: $e', name: logName);
      rethrow;
    }
  }

  Future<void> finalizeReturn(
    String shopId,
    String rentalId,
    String itemId,
  ) async {
    try {
      log('Finalizing return for rental: $rentalId', name: logName);

      final rentalRef = _shopRef(shopId).collection('rentals').doc(rentalId);
      final inventoryRef = _shopRef(shopId).collection('inventory').doc(itemId);

      // Update rental status to 'completed'
      await rentalRef.update({
        'status': RentalStatus.completed.name,
        'returnedAt': FieldValue.serverTimestamp(),
      });

      // Update inventory item status to 'available'
      await inventoryRef.update({'status': InventoryStatus.available.name});

      log('Return finalized for rental: $rentalId', name: logName);
    } catch (e) {
      log('Error finalizing return: $e', name: logName);
      rethrow;
    }
  }

  Future<void> addDamageCharge({
    required String shopId,
    required String rentalId,
    required double amount,
  }) async {
    try {
      log(
        'Adding damage charge of $amount to rental: $rentalId',
        name: logName,
      );
      final rentalRef = _shopRef(shopId).collection('rentals').doc(rentalId);
      await rentalRef.update({'amountExpected': FieldValue.increment(amount)});
      log('Damage charge added to rental: $rentalId', name: logName);
    } catch (e) {
      log('Error adding damage charge: $e', name: logName);
      rethrow;
    }
  }
}
