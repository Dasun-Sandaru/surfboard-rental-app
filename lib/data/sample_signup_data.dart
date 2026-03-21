///
/// Dummy data sets for testing the sign up flows (Staff and Shop Owner).
/// This provides sample input data you can use to pre-fill forms or pass to controllers
/// during the authentication/sign-up implementation.
///
library;

class SampleSignupData {
  // ==========================================
  // SCENARIO 1: SETUP SHOP (Owner / Admin)
  // ==========================================
  // Data typically collected when a new user registers and creates a new shop.
  static final Map<String, dynamic> setupShopSignupData = {
    // User Account Info
    'email': 'owner@surfshopdemo.com',
    'password': 'Password123!',
    'name': 'John Doe',
    'phone': '+94771234567',

    // Shop Info
    'businessName': 'Ocean Waves Surf Shop',
    'location': 'Weligama, Sri Lanka',
    'contactNumber': '+94911234567',
    'currency': 'LKR',
    'defaultHourlyRate': 1500.0,
    'defaultDailyRate': 5000.0,
    'isTaxEnabled': true,
    'taxRate': 15.0, // Assuming 15% VAT or similar
  };

  // ==========================================
  // SCENARIO 2: JOIN AS STAFF
  // ==========================================
  // Data typically collected when a staff member registers using an existing shop code.
  static final Map<String, dynamic> joinAsStaffSignupData = {
    // User Account Info
    'email': 'staff@surfshopdemo.com',
    'password': 'Password123!',
    'name': 'Jane Smith',
    'phone': '+94719876543',

    // Linking to Shop
    // A dummy shop code referencing 'Ocean Waves Surf Shop'
    'shopCode': 'OW-8A3B9',
  };

  // ==========================================
  // PRE-BUILT MODEL DATA (If Models are needed directly)
  // ==========================================
  // If you need the raw maps that resemble Firestore documents after creation:

  static final Map<String, dynamic> dummyShopDocument = {
    'businessName': 'Ocean Waves Surf Shop',
    'location': 'Weligama, Sri Lanka',
    'contactNumber': '+94911234567',
    'shopCode': 'OW-8A3B9',
    'ownerAdminUid': 'dummy_owner_uid_123',
    'currency': 'LKR',
    'defaultDailyRate': 5000.0,
    'defaultHourlyRate': 1500.0,
    'isTaxEnabled': true,
    'taxRate': 15.0,
  };

  static final Map<String, dynamic> dummyAdminUserDocument = {
    'uid': 'dummy_owner_uid_123',
    'email': 'owner@surfshopdemo.com',
    'name': 'John Doe',
    'role': 'admin',
    'isActive': true,
    'verified': true,
    'phone': '+94771234567',
    'shopId': 'dummy_shop_id_456',
    'createdAt': DateTime.now().toUtc().toIso8601String(),
    'emailVerified': true,
  };

  static final Map<String, dynamic> dummyStaffUserDocument = {
    'uid': 'dummy_staff_uid_789',
    'email': 'staff@surfshopdemo.com',
    'name': 'Jane Smith',
    'role': 'staff',
    'isActive': true,
    'verified': false, // Might require admin approval depending on logic
    'phone': '+94719876543',
    'shopId': 'dummy_shop_id_456', // Linked to the same shop
    'createdAt': DateTime.now().toUtc().toIso8601String(),
    'emailVerified': true,
  };
}
