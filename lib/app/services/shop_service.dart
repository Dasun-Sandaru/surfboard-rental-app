import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// CREATE SHOP + OWNER MEMBERSHIP

  Future<String> createShopWithOwner({
    required String shopName,
    required String location,
    required String contactNumber,
  }) async {
    final uid = _auth.currentUser!.uid;
    final shopRef = _db.collection('shops').doc();

    final batch = _db.batch();

    batch.set(shopRef, {
      'name': shopName,
      'location': location,
      'contact_number': contactNumber,
      'created_date': FieldValue.serverTimestamp(),
      'owner_admin_uid': uid,
      'shop_code': _generateShopCode(),
    });

    // batch.set(shopRef.collection('members').doc(uid), {
    //   'role': 'admin',
    //   'added_at': FieldValue.serverTimestamp(),
    // });

    await batch.commit();
    return shopRef.id;
  }

  String _generateShopCode() {
    final num = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'SURF-$num';
  }
}
