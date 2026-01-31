import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:surfboard_rental_app/app/models/customer_model.dart';
import 'package:surfboard_rental_app/app/models/inventory_model.dart';
import 'package:surfboard_rental_app/app/models/rental_model.dart';
import 'package:surfboard_rental_app/app/models/payment_model.dart';
import 'package:surfboard_rental_app/app/models/security_deposit_model.dart';
import 'package:surfboard_rental_app/app/models/user_model.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_collections.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';

class SampleDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'SampleDataService';

  /// Master method to seed everything
  Future<void> seedAll(String shopId, String adminUid) async {
    try {
      log('--- Starting Complete Data Seeding ---', name: logName);

      // 1. Seed Users (Staff)
      final seededStaff = await seedUsers(shopId);
      final primaryStaffId = seededStaff.isNotEmpty
          ? seededStaff.first
          : adminUid;
      final primaryStaffName = "Sample Staff";

      // 2. Seed Customers
      final customerIds = await seedCustomers(shopId);

      // 3. Seed Inventory (Categorized)
      final inventoryIds = await seedInventory(shopId);

      // 4. Seed Rentals (Various scenarios)
      await seedRentals(
        shopId: shopId,
        customerIds: customerIds,
        inventoryIds: inventoryIds,
        staffId: primaryStaffId,
        staffName: primaryStaffName,
      );

      log('--- Complete Data Seeding Finished ---', name: logName);
    } catch (e) {
      log('Error during master seeding: $e', name: logName, error: e);
      rethrow;
    }
  }

  // ===========================================================================
  // SECTION 1: USERS
  // ===========================================================================

  Future<List<String>> seedUsers(String shopId) async {
    try {
      log('Seeding Users...', name: logName);
      final List<String> staffIds = [];
      final usersCollection = _db.collection(FirestoreCollections.users);

      final List<UserModel> sampleUsers = [
        UserModel(
          uid: 'sample_staff_1_${shopId.substring(0, 5)}',
          name: "Samantha Staff",
          email: "samantha@surfshop.com",
          role: UserRole.staff,
          shopId: shopId,
          isActive: true,
          isVerified: true,
        ),
        UserModel(
          uid: 'sample_staff_2_${shopId.substring(0, 5)}',
          name: "Steve Surfer",
          email: "steve@surfshop.com",
          role: UserRole.staff,
          shopId: shopId,
          isActive: true,
          isVerified: true,
        ),
      ];

      for (var user in sampleUsers) {
        await usersCollection.doc(user.uid).set(user.toMap());
        staffIds.add(user.uid);
      }
      return staffIds;
    } catch (e) {
      log('Error seeding users: $e', name: logName, error: e);
      rethrow;
    }
  }

  // ===========================================================================
  // SECTION 2: CUSTOMERS
  // ===========================================================================

  Future<List<String>> seedCustomers(String shopId) async {
    try {
      log('Seeding Customers...', name: logName);
      final List<String> customerIds = [];
      final customersCollection = _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.customers);

      final List<CustomerModel> sampleCustomers = [
        CustomerModel(
          firstName: "John",
          lastName: "Doe",
          phone: "+94771112222",
          nic: "901234567V",
          email: "john.doe@gmail.com",
          notes: "Regular vacationer, likes longboards.",
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        CustomerModel(
          firstName: "Emma",
          lastName: "Watson",
          phone: "+94773334444",
          nic: "958765432V",
          email: "emma.w@outlook.com",
          notes: "Intermediate level, visiting for the season.",
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        CustomerModel(
          firstName: "Robert",
          lastName: "Brown",
          phone: "+94775556666",
          nic: "881230987V",
          email: "rob.brown@yahoo.com",
          notes: "Advanced surfer, brings his own wax.",
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        CustomerModel(
          firstName: "Sophia",
          lastName: "Garcia",
          phone: "+94777778888",
          nic: "982345671V",
          email: "sophia.g@protonmail.com",
          notes: "Beginner, needs soft tops/funboards.",
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      for (var customer in sampleCustomers) {
        final docRef = customersCollection.doc();
        await docRef.set(
          customer.toMap()..addAll({FirestoreFields.id: docRef.id}),
        );
        customerIds.add(docRef.id);
      }
      return customerIds;
    } catch (e) {
      log('Error seeding customers: $e', name: logName, error: e);
      rethrow;
    }
  }

  // ===========================================================================
  // SECTION 3: INVENTORY
  // ===========================================================================

  Future<List<String>> seedInventory(String shopId) async {
    try {
      log('Seeding Inventory by Types...', name: logName);
      final List<String> inventoryIds = [];
      final inventoryCollection = _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory);

      // Sub-seeder lists
      final List<InventoryModel> shortboards = [
        _createBoard(
          name: "Pro Ripper 6'0",
          type: SurfBoardType.shortboard.name,
          brand: "JS Industries",
          size: [6, 0],
          vol: 28,
          cost: 750,
          rates: [10, 45],
        ),
        _createBoard(
          name: "Wave Ripper 6'2",
          type: SurfBoardType.shortboard.name,
          brand: "Al Merrick",
          size: [6, 2],
          vol: 32,
          cost: 800,
          rates: [10, 48],
        ),
      ];

      final List<InventoryModel> longboards = [
        _createBoard(
          name: "Log Master 9'2",
          type: SurfBoardType.longboard.name,
          brand: "Donald Takayama",
          size: [9, 2],
          vol: 78,
          cost: 1200,
          rates: [12, 55],
        ),
        _createBoard(
          name: "Ocean Glide 9'0",
          type: SurfBoardType.longboard.name,
          brand: "NSP",
          size: [9, 0],
          vol: 72,
          cost: 650,
          rates: [8, 35],
        ),
      ];

      final List<InventoryModel> funboards = [
        _createBoard(
          name: "Easy Ride 7'6",
          type: SurfBoardType.funboard.name,
          brand: "Torq",
          size: [7, 6],
          vol: 52,
          cost: 500,
          rates: [7, 30],
        ),
        _createBoard(
          name: "Summer Mal 8'0",
          type: SurfBoardType.funboard.name,
          brand: "Bic Surf",
          size: [8, 0],
          vol: 58,
          cost: 450,
          rates: [6, 25],
        ),
      ];

      final List<InventoryModel> fishBoards = [
        _createBoard(
          name: "Classic Fish 5'8",
          type: SurfBoardType.fish.name,
          brand: "Lost",
          size: [5, 8],
          vol: 31,
          cost: 700,
          rates: [10, 40],
        ),
      ];

      final allBoards = [
        ...shortboards,
        ...longboards,
        ...funboards,
        ...fishBoards,
      ];

      for (var board in allBoards) {
        final docRef = inventoryCollection.doc();
        await docRef.set(
          board.toMap()..addAll({FirestoreFields.id: docRef.id}),
        );
        inventoryIds.add(docRef.id);
      }
      return inventoryIds;
    } catch (e) {
      log('Error seeding inventory: $e', name: logName, error: e);
      rethrow;
    }
  }

  InventoryModel _createBoard({
    required String name,
    required String type,
    required String brand,
    required List<int> size,
    required int vol,
    required int cost,
    required List<int> rates,
  }) {
    return InventoryModel(
      id: '',
      imageUrl:
          "https://images.unsplash.com/photo-1528150177508-7cc0c36cda5c?w=500",
      name: name,
      type: type,
      brand: brand,
      sizeFeet: size[0],
      sizeInches: size[1],
      sizeTotalInches: (size[0] * 12) + size[1],
      volume: vol,
      color: "Blue/White",
      purchaseCost: cost,
      damageFeeRule: "standard",
      rentalRateHour: rates[0],
      rentalRateDay: rates[1],
      note: "Sample $type seeder data",
      status: InventoryStatus.available,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    );
  }

  // ===========================================================================
  // SECTION 4: RENTALS
  // ===========================================================================

  Future<void> seedRentals({
    required String shopId,
    required List<String> customerIds,
    required List<String> inventoryIds,
    required String staffId,
    required String staffName,
  }) async {
    try {
      log('Seeding Variety of Rental Scenarios...', name: logName);
      final now = DateTime.now();

      if (customerIds.length < 4 || inventoryIds.length < 6) {
        log("Not enough data to seed diverse rentals", name: logName);
        return;
      }

      // 1. Active Rental (Current)
      await _createSampleRental(
        shopId: shopId,
        customerId: customerIds[0],
        customerName: "John Doe",
        itemId: inventoryIds[0],
        itemName: "Pro Ripper 6'0",
        staffId: staffId,
        staffName: staffName,
        startTime: now.subtract(const Duration(hours: 1)),
        expectedReturnTime: now.add(const Duration(hours: 3)),
        status: RentalStatus.active,
        rate: 10,
        amountExpected: 40,
        amountPaid: 0,
      );

      // 2. Overdue Rental
      await _createSampleRental(
        shopId: shopId,
        customerId: customerIds[1],
        customerName: "Emma Watson",
        itemId: inventoryIds[2],
        itemName: "Log Master 9'2",
        staffId: staffId,
        staffName: staffName,
        startTime: now.subtract(const Duration(hours: 6)),
        expectedReturnTime: now.subtract(const Duration(hours: 2)),
        status: RentalStatus.active,
        rate: 12,
        amountExpected: 48,
        amountPaid: 0,
      );

      // 3. Completed Rental (Fully Paid)
      await _createSampleRental(
        shopId: shopId,
        customerId: customerIds[2],
        customerName: "Robert Brown",
        itemId: inventoryIds[4],
        itemName: "Easy Ride 7'6",
        staffId: staffId,
        staffName: staffName,
        startTime: now.subtract(const Duration(days: 1, hours: 2)),
        expectedReturnTime: now.subtract(const Duration(days: 1)),
        actualReturnTime: now.subtract(const Duration(days: 1)),
        status: RentalStatus.completed,
        rate: 7,
        amountExpected: 14,
        amountPaid: 14,
      );

      // 4. Damaged Item Scenario
      await _createSampleRental(
        shopId: shopId,
        customerId: customerIds[3],
        customerName: "Sophia Garcia",
        itemId: inventoryIds[1],
        itemName: "The Fish 5'8",
        staffId: staffId,
        staffName: staffName,
        startTime: now.subtract(const Duration(days: 2, hours: 4)),
        expectedReturnTime: now.subtract(const Duration(days: 2)),
        actualReturnTime: now.subtract(const Duration(days: 1, hours: 22)),
        status: RentalStatus.mark_as_damaged,
        rate: 10,
        amountExpected: 40,
        amountPaid: 40,
      );

      // 5. Cancelled Rental
      await _createSampleRental(
        shopId: shopId,
        customerId: customerIds[0],
        customerName: "John Doe",
        itemId: inventoryIds[3],
        itemName: "Ocean Glide 9'0",
        staffId: staffId,
        staffName: staffName,
        startTime: now.subtract(const Duration(days: 3)),
        expectedReturnTime: now.subtract(const Duration(days: 3, hours: -4)),
        status: RentalStatus.cancelled,
        rate: 8,
        amountExpected: 32,
        amountPaid: 0,
      );
    } catch (e) {
      log('Error seeding rentals: $e', name: logName, error: e);
      rethrow;
    }
  }

  // Helper from old code updated for better logic
  Future<void> _createSampleRental({
    required String shopId,
    required String customerId,
    required String customerName,
    required String itemId,
    required String itemName,
    required String staffId,
    required String staffName,
    required DateTime startTime,
    required DateTime expectedReturnTime,
    DateTime? actualReturnTime,
    required RentalStatus status,
    required double rate,
    required double amountExpected,
    required double amountPaid,
  }) async {
    final rentalRef = _db
        .collection(FirestoreCollections.shops)
        .doc(shopId)
        .collection(FirestoreCollections.rentals)
        .doc();

    final rentalId = rentalRef.id;

    final rental = RentalModel(
      id: rentalId,
      shopId: shopId,
      customerId: customerId,
      itemId: itemId,
      staffId: staffId,
      startTime: startTime,
      expectedReturnTime: expectedReturnTime,
      actualReturnTime: actualReturnTime,
      status: status,
      rentType: RentType.hourly,
      paymentStatus: (amountPaid >= amountExpected && amountExpected > 0)
          ? PaymentStatus.paid
          : (amountPaid > 0 ? PaymentStatus.partial : PaymentStatus.unpaid),
      rate: rate,
      amountExpected: amountExpected,
      amountPaid: amountPaid,
      securityDeposit: SecurityDepositModel(
        enabled: true,
        amount: 50.0,
        paid: 50.0,
        refunded:
            (actualReturnTime != null && status != RentalStatus.mark_as_damaged)
            ? 50.0
            : 0.0,
      ),
      cachedCustomerName: customerName,
      cachedItemName: itemName,
      cachedStaffName: staffName,
      createdAt: startTime,
    );

    await rentalRef.set(rental.toMap());

    // Add a payment record if paid
    if (amountPaid > 0) {
      final paymentRef = rentalRef
          .collection(FirestoreCollections.payments)
          .doc();
      final payment = PaymentModel(
        id: paymentRef.id,
        rentalId: rentalId,
        amount: amountPaid,
        category: PaymentCategory.rental,
        method: PaymentMethod.cash,
        handledBy: staffId,
        timestamp: actualReturnTime ?? startTime,
        note: "Base rental payment",
      );
      await paymentRef.set(payment.toMap());
    }

    // Update board status if currently rented
    if (status == RentalStatus.active) {
      await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .update({FirestoreFields.status: InventoryStatus.rented.name});
    }
  }

  /// Legacy support
  Future<void> seedData(String shopId, String adminUid) async {
    await seedAll(shopId, adminUid);
  }

  // ===========================================================================
  // SECTION 5: BACKUP / EXPORT
  // ===========================================================================

  /// Fetch all database data and save it as a JSON file
  Future<String> exportFullDatabase(String shopId) async {
    try {
      log('--- Starting Database Export ---', name: logName);
      final Map<String, dynamic> dataMap = {};
      final Map<String, dynamic> backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'shopId': shopId,
        'data': dataMap,
      };

      // 1. Fetch Shop Info
      final shopDoc = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .get();
      dataMap['shop'] = _convertFirestoreData(shopDoc.data());

      // 2. Fetch Users associated with this shop
      final users = await _db
          .collection(FirestoreCollections.users)
          .where('shopId', isEqualTo: shopId)
          .get();
      dataMap['users'] = users.docs
          .map((e) => _convertFirestoreData(e.data()))
          .toList();

      // 3. Fetch Customers
      final customers = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.customers)
          .get();
      dataMap['customers'] = customers.docs
          .map((e) => _convertFirestoreData(e.data()))
          .toList();

      // 4. Fetch Inventory
      final inventory = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory)
          .get();
      dataMap['inventory'] = inventory.docs
          .map((e) => _convertFirestoreData(e.data()))
          .toList();

      // 5. Fetch Rentals (including sub-collection payments)
      final rentals = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.rentals)
          .get();

      final rentalList = [];
      for (var doc in rentals.docs) {
        final Map<String, dynamic> rentalData = Map<String, dynamic>.from(
          _convertFirestoreData(doc.data()) ?? {},
        );
        // Fetch sub-collection: payments
        final payments = await doc.reference
            .collection(FirestoreCollections.payments)
            .get();
        rentalData['payments'] = payments.docs
            .map((p) => _convertFirestoreData(p.data()))
            .toList();
        rentalList.add(rentalData);
      }
      dataMap['rentals'] = rentalList;

      // 6. Fetch Activity Logs
      final activityLogs = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.activityLogs)
          .orderBy('timestamp', descending: true)
          .limit(1000)
          .get();
      dataMap['activity_logs'] = activityLogs.docs
          .map((e) => _convertFirestoreData(e.data()))
          .toList();

      // 7. Fetch Damage Reports
      final damageReports = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.damageReports)
          .get();
      dataMap['damage_reports'] = damageReports.docs
          .map((e) => _convertFirestoreData(e.data()))
          .toList();

      // Convert to Pretty JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Save to file
      // On Android, getExternalStorageDirectory is usually more accessible
      // than getApplicationDocumentsDirectory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      directory ??= await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'backup_${shopId}_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // Trigger Share Dialog so the user can save it elsewhere (Publicly)
      log('Triggering share dialog for: ${file.path}', name: logName);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Database Backup for Shop $shopId',
        text: 'Attached is the JSON database backup for shop ID: $shopId',
      );

      log('Database exported successfully to: ${file.path}', name: logName);
      return file.path;
    } catch (e) {
      log('Error during database export: $e', name: logName, error: e);
      rethrow;
    }
  }

  /// Helper to convert Firestore types (Timestamp) to JSON serializable formats
  dynamic _convertFirestoreData(dynamic data) {
    if (data == null) return null;
    if (data is Timestamp) return data.toDate().toIso8601String();
    if (data is Map) {
      final Map<String, dynamic> result = {};
      data.forEach((key, value) {
        result[key.toString()] = _convertFirestoreData(value);
      });
      return result;
    }
    if (data is List) {
      return data.map((e) => _convertFirestoreData(e)).toList();
    }
    return data;
  }
}
