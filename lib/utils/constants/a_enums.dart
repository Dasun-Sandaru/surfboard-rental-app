// ignore_for_file: constant_identifier_names

enum UserRole { admin, staff, customer }

enum SurfBoardType { shortboard, longboard, fish, consultant }

enum InventoryStatus { available, rented, repair, retired }

enum InventoryFormMode { add, edit }

enum DamageType { fin_damaged, board_cracked, leash_broken, lost }



enum RentalStatus {
active,
completed,
overdue,
cancelled,
}

enum LedgerSide {
debit, // customer owes shop
credit, // shop owes customer
}

enum PaymentCategory {
rental(LedgerSide.debit),
deposit(LedgerSide.debit),
lateFee(LedgerSide.debit),
damageFee(LedgerSide.debit),
refund(LedgerSide.credit);


final LedgerSide side;
const PaymentCategory(this.side);
}

enum RentType { hourly, daily }

enum PaymentStatus { unpaid, partial, paid }

enum PaymentType { rental_fee, damage_fee, security_deposit }

enum PaymentMethod { cash, card, online }

extension EnumParser on Enum {
  String get value => name;
}

T enumFromString<T extends Enum>(List<T> values, String value, T fallback) {
  return values.firstWhere((e) => e.name == value, orElse: () => fallback);
}

// Damage Type Helper with descriptions
class DamageTypeHelper {
  static const Map<String, DamageTypeData> damageTypes = {
    'fin_damaged': DamageTypeData(
      label: 'Broken Fin',
      description: 'Fin box damage or snapped fin.',
    ),
    'board_cracked': DamageTypeData(
      label: 'Major Ding',
      description: 'Deep cracks affecting the core foam.',
    ),
    'leash_broken': DamageTypeData(
      label: 'Snapped Leash',
      description: 'Leash cord broken.',
    ),
    'lost': DamageTypeData(
      label: 'Item Lost',
      description: 'Item not returned.',
    ),
  };

  static String getLabel(DamageType type) {
    return damageTypes[type.name]?.label ?? type.name;
  }

  static String getDescription(DamageType type) {
    return damageTypes[type.name]?.description ?? '';
  }

  static List<DamageTypeData> getAll() {
    return damageTypes.values.toList();
  }

  static DamageTypeData? getByLabel(String label) {
    return damageTypes.values.firstWhere(
      (item) => item.label == label,
      orElse: () => const DamageTypeData(label: '', description: ''),
    );
  }
}

class DamageTypeData {
  final String label;
  final String description;

  const DamageTypeData({required this.label, required this.description});
}
