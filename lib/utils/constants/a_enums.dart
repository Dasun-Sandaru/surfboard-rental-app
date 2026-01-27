// ignore_for_file: constant_identifier_names

enum UserRole { admin, staff, customer }

enum SurfBoardType { shortboard, longboard, fish, consultant }

enum InventoryStatus { available, rented, repair, retired }

enum InventoryFormMode { add, edit }

enum DamageType { fin_damaged, board_cracked, leash_broken, lost }

enum RentalStatus { active, completed, overdue, cancelled , mark_as_damaged , item_returned }

enum RentType { hourly, daily }

enum LedgerSide {
  debit, // customer owes shop
  credit, // shop owes customer
}

enum PaymentCategory {
  rental(LedgerSide.debit),
  deposit(LedgerSide.debit),
  lateFee(LedgerSide.debit),
  damageFee(LedgerSide.debit),
  partialPayment(LedgerSide.debit),
  refund(LedgerSide.credit);

  final LedgerSide side;
  const PaymentCategory(this.side);
}

enum PaymentMethod { cash, card, online }

enum PaymentStatus { paid, unpaid, partial, refunded }

enum DamageStatus {
  reported, // just reported
  approved, // manager approved
  charged, // payment created
  resolved, // fully handled
}

enum ActivityType {
  create_rental,
  return_rental,
  add_payment,
  delete_payment,
  add_customer,
  update_inventory,
  add_inventory,
  delete_inventory,
  login,
  logout,
  undefined,
}

/// Helper to parse enums safely
T enumFromString<T>(Iterable<T> values, String? value, T defaultValue) {
  if (value == null) {
    return defaultValue;
  }
  return values.firstWhere(
    (e) => e.toString().split('.').last == value,
    orElse: () => defaultValue,
  );
}

class DamageTypeData {
  final String label;
  final String description;
  const DamageTypeData({required this.label, required this.description});
}

class DamageTypeHelper {
  static const Map<String, DamageTypeData> damageTypes = {
    'fin_damaged': DamageTypeData(
      label: 'Fin Damaged',
      description: 'Fin is broken or missing',
    ),
    'board_cracked': DamageTypeData(
      label: 'Board Cracked',
      description: 'Body of the board is cracked',
    ),
    'leash_broken': DamageTypeData(
      label: 'Leash Broken',
      description: 'Leash is snapped or missing',
    ),
    'lost': DamageTypeData(
      label: 'Lost',
      description: 'Board is lost completely',
    ),
  };
}
