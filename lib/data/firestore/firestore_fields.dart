class FirestoreFields {
  // Common
  static const id = 'id';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const uploadedAt = 'uploadedAt';
  static const uploadedBy = 'uploadedBy';

  // User
  static const email = 'email';
  static const name = 'name';
  static const role = 'role';
  static const isActive = 'is_active';
  static const verified = 'verified';
  static const phone = 'phone';
  static const shopId = 'shop_id';
  static const emailVerified = 'email_verified';

  // Customer
  static const firstName = 'first_name';
  static const lastName = 'last_name';
  static const nic = 'nic';
  static const notes = 'notes';
  static const imageUrl = 'image_url';
  static const rentalsCount = 'rentals_count';
  static const lastRentalDate = 'last_rental_date';

  // Inventory
  static const type = 'type';
  static const brand = 'brand';
  static const sizeFeet = 'size_feet';
  static const sizeInches = 'size_inches';
  static const sizeTotalInches = 'size_total_inches';
  static const volume = 'volume';
  static const color = 'color';
  static const purchaseCost = 'purchase_cost';
  static const damageFeeRule = 'damage_fee_rule';
  static const rentalRateHour = 'rental_rate_hour';
  static const rentalRateDay = 'rental_rate_day';
  static const note = 'note';
  static const status = 'status';

  // Rental
  static const customerId = 'customerId';
  static const itemId = 'itemId';
  static const staffId = 'staffId';
  static const startTime = 'startTime';
  static const expectedReturnTime = 'expectedReturnTime';
  static const actualReturnTime = 'actualReturnTime';
  static const rentType = 'rentType';
  static const paymentStatus = 'paymentStatus';
  static const rate = 'rate';
  static const amountExpected = 'amountExpected';
  static const amountPaid = 'amountPaid';
  static const securityDeposit = 'securityDeposit';
  static const agreementLink = 'agreementLink';

  // Payment
  static const rentalId = 'rentalId';
  static const amount = 'amount';
  static const category = 'category';
  static const method = 'method';
  static const handledBy = 'handledBy';
  static const timestamp = 'timestamp';

  // Damage Fee
  static const feeAmount = 'fee_amount';
  static const description = 'description';
  static const activeStatus = 'active_status';
  static const damageType = 'damage_type';
  static const damageId = 'damageId';
  static const photoUrl = 'photoUrl';

  // Agreement Template
  static const templateName = 'template_name';
  static const section = 'sections';
  static const isDefault = 'is_default';

  // Shop
  static const businessName = 'name';
  static const location = 'location';
  static const contactNumber = 'contact_number';
  static const shopCode = 'shop_code';
  static const ownerAdminUid = 'owner_admin_uid';

  // Activity Log
  static const activityType = 'activity_type';
  static const actorId = 'actor_id';
  static const actorName = 'actor_name';
  static const entityId = 'entity_id';
  static const entityType = 'entity_type';
  static const metadata = 'metadata';
}
