import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/app/models/customer_model.dart';
import 'package:surfboard_rental_app/app/models/inventory_model.dart';
import 'package:surfboard_rental_app/app/models/rental_model.dart';
import 'package:surfboard_rental_app/app/models/payment_model.dart';
import 'package:surfboard_rental_app/app/models/security_deposit_model.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_collections.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';

class SampleDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'SampleDataService';

  Future<void> seedData(String shopId, String adminUid) async {
    try {
      log('Starting data seeding for shop: $shopId', name: logName);

      // 1. Create Customers
      log('Seeding Customers...', name: logName);
      final List<String> customerIds = [];
      final List<CustomerModel> sampleCustomers = [
        CustomerModel(
          firstName: "John",
          lastName: "Doe",
          phone: "+94771234567",
          nic: "951234567V",
          email: "john@example.com",
          notes: "Regular customer from Colombo",
          createdAt: DateTime.now(),
        ),
        CustomerModel(
          firstName: "Jane",
          lastName: "Smith",
          phone: "+94779876543",
          nic: "921234567V",
          email: "jane@example.com",
          notes: "Prefers high-performance shortboards",
          createdAt: DateTime.now(),
        ),
        CustomerModel(
          firstName: "Mike",
          lastName: "Johnson",
          phone: "+94771122334",
          nic: "881234567V",
          email: "mike@example.com",
          notes: "Intermediate surfer, visiting for 2 weeks",
          createdAt: DateTime.now(),
        ),
      ];

      for (var customer in sampleCustomers) {
        final docRef = _db
            .collection(FirestoreCollections.shops)
            .doc(shopId)
            .collection(FirestoreCollections.customers)
            .doc();
        await docRef.set(
          customer.toMap()..addAll({FirestoreFields.id: docRef.id}),
        );
        customerIds.add(docRef.id);
      }

      // 2. Create Inventory
      log('Seeding Inventory...', name: logName);
      final List<InventoryModel> sampleBoards = [
        InventoryModel(
          id: '',
          imageUrl:
              "https://images.unsplash.com/photo-1528150177508-7cc0c36cda5c?w=500",
          name: "Blue Thunder 7'6",
          type: "Funboard",
          brand: "NSP",
          sizeFeet: 7,
          sizeInches: 6,
          sizeTotalInches: 90,
          volume: 54,
          color: "Blue",
          purchaseCost: 450,
          damageFeeRule: "standard",
          rentalRateHour: 5,
          rentalRateDay: 25,
          note: "Easy to catch waves, great for beginners",
          status: InventoryStatus.available,
          createdAt: DateTime.now(),
        ),
        InventoryModel(
          id: '',
          imageUrl:
              "https://images.unsplash.com/photo-1531722569936-825d3dd91b15?w=500",
          name: "Soul Glide 9'0",
          type: "Longboard",
          brand: "Torq",
          sizeFeet: 9,
          sizeInches: 0,
          sizeTotalInches: 108,
          volume: 72,
          color: "White/Grey",
          purchaseCost: 650,
          damageFeeRule: "standard",
          rentalRateHour: 7,
          rentalRateDay: 35,
          note: "Traditional single fin feel",
          status: InventoryStatus.available,
          createdAt: DateTime.now(),
        ),
        InventoryModel(
          id: '',
          imageUrl:
              "https://images.unsplash.com/photo-1459491624952-04003d1140c3?w=500",
          name: "Rip Curl Shorty 6'2",
          type: "Shortboard",
          brand: "Rip Curl",
          sizeFeet: 6,
          sizeInches: 2,
          sizeTotalInches: 74,
          volume: 32,
          color: "Yellow",
          purchaseCost: 550,
          damageFeeRule: "standard",
          rentalRateHour: 6,
          rentalRateDay: 30,
          note: "Fast and responsive for advanced surfers",
          status: InventoryStatus.available,
          createdAt: DateTime.now(),
        ),
      ];

      final List<String> inventoryIds = [];
      final List<String> boardNames = [];
      for (var board in sampleBoards) {
        final docRef = _db
            .collection(FirestoreCollections.shops)
            .doc(shopId)
            .collection(FirestoreCollections.inventory)
            .doc();
        final finalBoard = board.toMap()
          ..addAll({FirestoreFields.id: docRef.id});
        await docRef.set(finalBoard);
        inventoryIds.add(docRef.id);
        boardNames.add(board.name);
      }

      // 3. Create Rentals (Active, Returned, Overdue)
      log('Seeding Rentals...', name: logName);
      final now = DateTime.now();

      // Rental 1: Active
      await _createSampleRental(
        shopId: shopId,
        customerId: customerIds[0],
        customerName:
            "${sampleCustomers[0].firstName} ${sampleCustomers[0].lastName}",
        itemId: inventoryIds[0],
        itemName: boardNames[0],
        staffId: adminUid,
        staffName: "Admin User",
        startTime: now.subtract(const Duration(hours: 2)),
        expectedReturnTime: now.add(const Duration(hours: 4)),
        status: RentalStatus.active,
        rate: 5.0,
        amountExpected: 30.0,
        amountPaid: 0.0,
      );

      // Rental 2: Returned (Completed)
      await _createSampleRental(
        shopId: shopId,
        customerId: customerIds[1],
        customerName:
            "${sampleCustomers[1].firstName} ${sampleCustomers[1].lastName}",
        itemId: inventoryIds[1],
        itemName: boardNames[1],
        staffId: adminUid,
        staffName: "Admin User",
        startTime: now.subtract(const Duration(days: 1)),
        expectedReturnTime: now.subtract(const Duration(days: 1, hours: 20)),
        actualReturnTime: now.subtract(const Duration(days: 1, hours: 19)),
        status: RentalStatus.completed,
        rate: 7.0,
        amountExpected: 35.0,
        amountPaid: 35.0,
      );

      // Rental 3: Overdue
      await _createSampleRental(
        shopId: shopId,
        customerId: customerIds[2],
        customerName:
            "${sampleCustomers[2].firstName} ${sampleCustomers[2].lastName}",
        itemId: inventoryIds[2],
        itemName: boardNames[2],
        staffId: adminUid,
        staffName: "Admin User",
        startTime: now.subtract(const Duration(hours: 8)),
        expectedReturnTime: now.subtract(const Duration(hours: 2)),
        status: RentalStatus.active,
        rate: 6.0,
        amountExpected: 36.0,
        amountPaid: 0.0,
      );

      log('Data seeding completed successfully!', name: logName);
    } catch (e) {
      log('Error during data seeding: $e', name: logName, error: e);
      rethrow;
    }
  }

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
      paymentStatus: amountPaid >= amountExpected
          ? PaymentStatus.paid
          : PaymentStatus.unpaid,
      rate: rate,
      amountExpected: amountExpected,
      amountPaid: amountPaid,
      securityDeposit: SecurityDepositModel(
        enabled: true,
        amount: 50.0,
        paid: 50.0,
        refunded: actualReturnTime != null ? 50.0 : 0.0,
      ),
      cachedCustomerName: customerName,
      cachedItemName: itemName,
      cachedStaffName: staffName,
      createdAt: startTime,
    );

    await rentalRef.set(rental.toMap()..addAll({FirestoreFields.id: rentalId}));

    // Add a payment if amountPaid > 0
    if (amountPaid > 0) {
      final paymentRef = rentalRef
          .collection(FirestoreCollections.payments)
          .doc();
      final payment = PaymentModel(
        id: paymentRef.id,
        rentalId: rentalId,
        amount: amountPaid,
        category: PaymentCategory.damageFee,
        method: PaymentMethod.cash,
        handledBy: staffId,
        timestamp: actualReturnTime ?? startTime,
        note: "Initial payment",
      );
      await paymentRef.set(
        payment.toMap()..addAll({FirestoreFields.id: paymentRef.id}),
      );
    }

    // If active or overdue, mark item as rented
    if (status == RentalStatus.active) {
      await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .update({FirestoreFields.status: InventoryStatus.rented.name});
    }
  }
}
