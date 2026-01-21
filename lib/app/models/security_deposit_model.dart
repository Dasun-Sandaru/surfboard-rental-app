class SecurityDepositModel {
  final bool enabled;
  final double amount;
  final double paid;
  final double refunded;

  const SecurityDepositModel({
    required this.enabled,
    required this.amount,
    required this.paid,
    required this.refunded,
  });

  factory SecurityDepositModel.empty() {
    return const SecurityDepositModel(
      enabled: false,
      amount: 0,
      paid: 0,
      refunded: 0,
    );
  }

  factory SecurityDepositModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) return SecurityDepositModel.empty();

    return SecurityDepositModel(
      enabled: data['enabled'] ?? false,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      paid: (data['paid'] as num?)?.toDouble() ?? 0,
      refunded: (data['refunded'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'amount': amount,
      'paid': paid,
      'refunded': refunded,
    };
  }
}
