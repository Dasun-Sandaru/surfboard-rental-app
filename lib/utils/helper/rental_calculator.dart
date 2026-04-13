import '../../app/models/rental_model.dart';
import '../constants/a_enums.dart';

class RentalReturnResult {
  final double baseRent;
  final double overdueFee;
  final double damageFee;
  final double totalCharges;
  final double depositUsed;
  final double depositRefund;
  final double balanceDue;
  final InventoryStatus newInventoryStatus;

  RentalReturnResult({
    required this.baseRent,
    required this.overdueFee,
    required this.damageFee,
    required this.totalCharges,
    required this.depositUsed,
    required this.depositRefund,
    required this.balanceDue,
    required this.newInventoryStatus,
  });
}

class RentalCalculator {
  /// Calculates the estimated total for a rental period
  static double calculateEstimatedTotal({
    required DateTime startDateTime,
    required DateTime dueDateTime,
    required RentType rentType,
    required double hourlyRate,
    required double dailyRate,
    required int hourlyGraceMinutes,
    required int dailyGraceHours,
    bool isTaxEnabled = false,
    double taxRate = 0.0,
  }) {
    if (dueDateTime.isBefore(startDateTime) || dueDateTime == startDateTime) {
      return 0.0;
    }

    final Duration difference = dueDateTime.difference(startDateTime);
    double total = 0.0;

    if (rentType == RentType.hourly) {
      int hours = difference.inHours;
      final int minutes = difference.inMinutes % 60;

      // Grace period logic
      if (minutes > hourlyGraceMinutes) {
        hours++;
      }

      // Minimum 1 hour
      if (hours == 0) hours = 1;

      total = (hours * hourlyRate).toDouble();
    } else {
      int days = difference.inDays;
      int remainingMinutes = difference.inMinutes % (24 * 60);

      // Daily Grace Logic: if remaining time exceeds grace period (in minutes), charge extra day
      if (remainingMinutes > (dailyGraceHours * 60)) {
        days++;
      }

      // Minimum 1 day
      if (days == 0) days = 1;

      total = (days * dailyRate).toDouble();
    }

    // Apply Tax
    if (isTaxEnabled) {
      total += (total * taxRate / 100);
    }

    return total;
  }

  /// Calculates the final return charges, deposit refunds, and balance due
  static RentalReturnResult calculateReturn({
    required RentalModel rental,
    required DateTime actualReturnTime,
    required bool hasDamage,
    required double damageFeeAmount,
    required int hourlyGraceMinutes,
    required int dailyGraceHours,
    required double dailyRate,
    required double hourlyRate,
  }) {
    // 1. Calculate actual duration rent
    final double actualBaseRent = calculateEstimatedTotal(
      startDateTime: rental.startTime,
      dueDateTime: actualReturnTime,
      rentType: rental.rentType,
      hourlyRate: hourlyRate,
      dailyRate: dailyRate,
      hourlyGraceMinutes: hourlyGraceMinutes,
      dailyGraceHours: dailyGraceHours,
    );

    // 2. Calculate Overdue Fee (using a simple flat penalty per extra day/hour if returned late)
    // To match user's scenarios, if they keep it an extra day, they pay the actualBaseRent for 2 days
    // PLUS an overdue fee penalty. We'll use the dailyRate as a flat penalty for each overdue day.
    double overdueFee = 0.0;

    // Check if overdue by comparing actual return and expected return + grace
    Duration allowedDuration;
    if (rental.rentType == RentType.hourly) {
      allowedDuration = rental.expectedReturnTime
          .add(Duration(minutes: hourlyGraceMinutes))
          .difference(rental.startTime);
    } else {
      allowedDuration = rental.expectedReturnTime
          .add(Duration(hours: dailyGraceHours))
          .difference(rental.startTime);
    }

    final Duration actualDuration = actualReturnTime.difference(
      rental.startTime,
    );

    if (actualDuration > allowedDuration) {
      final Duration overdueDuration = actualReturnTime.difference(
        rental.expectedReturnTime,
      );
      if (rental.rentType == RentType.daily) {
        int overdueDays = overdueDuration.inDays;
        int remainingMinutes = overdueDuration.inMinutes % (24 * 60);
        if (remainingMinutes > (dailyGraceHours * 60)) {
          overdueDays++;
        }
        if (overdueDays > 0) {
          overdueFee =
              overdueDays *
              dailyRate; // penalty is 1x daily rate per overdue day
        }
      } else {
        int overdueHours = overdueDuration.inHours;
        int remainingMinutes = overdueDuration.inMinutes % 60;
        if (remainingMinutes > hourlyGraceMinutes) {
          overdueHours++;
        }
        if (overdueHours > 0) {
          overdueFee = overdueHours * hourlyRate;
        }
      }
    }

    // 3. Damage Fee
    final double damageFee = hasDamage ? damageFeeAmount : 0.0;

    // 4. Total Charges
    final double totalCharges = actualBaseRent + overdueFee + damageFee;

    // 5. Calculate Owed (Assuming amountExpected was paid upfront)
    final double outstanding = totalCharges - rental.amountPaid;

    // 6. Deposit Handling
    double depositUsed = 0.0;
    final double depositAvailable = rental.securityDeposit.amount;

    double remainingOutstanding = outstanding;
    if (remainingOutstanding > 0 && depositAvailable > 0) {
      depositUsed = remainingOutstanding > depositAvailable
          ? depositAvailable
          : remainingOutstanding;
      remainingOutstanding -= depositUsed;
    }

    final double depositRefund = depositAvailable - depositUsed;

    // If outstanding is negative, it means we owe them a refund on rent (rare, but handled by clamping to 0 if we don't do prorated refunds)
    final double balanceDue = remainingOutstanding > 0
        ? remainingOutstanding
        : 0.0;

    // 7. Inventory Status
    final InventoryStatus newStatus = hasDamage
        ? InventoryStatus.damaged
        : InventoryStatus.available;

    return RentalReturnResult(
      baseRent: actualBaseRent,
      overdueFee: overdueFee,
      damageFee: damageFee,
      totalCharges: totalCharges,
      depositUsed: depositUsed,
      depositRefund: depositRefund,
      balanceDue: balanceDue,
      newInventoryStatus: newStatus,
    );
  }
}
