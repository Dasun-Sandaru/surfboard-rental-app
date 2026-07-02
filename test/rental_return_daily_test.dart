// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:surfboard_rental_app/utils/helper/rental_calculator.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';
import 'package:surfboard_rental_app/app/models/rental_model.dart';
import 'package:surfboard_rental_app/app/models/security_deposit_model.dart';

RentalModel createMockRental({
  required DateTime start,
  required DateTime expectedReturn,
  required double amountPaid,
  required double depositAmount,
}) {
  return RentalModel(
    id: 'test_return_scenario',
    shopId: 'shop1',
    customerId: 'cust1',
    itemId: 'QA_BOARD_001',
    staffId: 'staff1',
    startTime: start,
    expectedReturnTime: expectedReturn,
    status: RentalStatus.active,
    rentType: RentType.daily,
    paymentStatus: PaymentStatus.paid,
    rate: 1500,
    amountExpected: 1500,
    amountPaid: amountPaid,
    securityDeposit: SecurityDepositModel(
      enabled: depositAmount > 0,
      amount: depositAmount,
      paid: depositAmount,
      refunded: 0,
    ),
    createdAt: DateTime.now(),
  );
}

void main() {
  final file = File('rental_return_daily_results.txt');
  if (file.existsSync()) file.deleteSync();

  void logScenario(String message) {
    print(message);
    file.writeAsStringSync('$message\n', mode: FileMode.append);
  }

  group('Comprehensive Rental Return Matrix (QA Board) - 48 Scenarios', () {
    final double purchaseCost = 120000;
    final double dailyRate = 1500;
    final double hourlyRate = 100;
    final int dailyGraceHours = 2;
    final int hourlyGraceMinutes = 15;

    final start = DateTime(2026, 1, 1, 10, 0);
    final due = DateTime(2026, 1, 2, 10, 0);

    final Map<String, DateTime> timeScenarios = {
      'Before Due Time (Early)': DateTime(2026, 1, 2, 5, 0),
      'Exact Due Time (On-Time)': DateTime(2026, 1, 2, 10, 0),
      'Within Grace Period': DateTime(2026, 1, 2, 11, 30),
      'Overdue (1 Day Late)': DateTime(2026, 1, 3, 10, 0),
    };

    final Map<String, double> damageScenarios = {
      'No Damage': 0.0,
      'Minor Damage (Broken Fin)': 350.0,
      'Total Loss (Broken Board)': purchaseCost,
    };

    final Map<String, double> depositScenarios = {
      'No Security Deposit': 0.0,
      'Has Security Deposit (5000 LKR)': 5000.0,
    };

    final Map<String, double> upfrontScenarios = {
      'No Upfront Payment': 0.0,
      'Paid 1-Day Upfront': 1500.0,
    };

    int scenarioNumber = 1;

    for (var timeEntry in timeScenarios.entries) {
      for (var damageEntry in damageScenarios.entries) {
        for (var depositEntry in depositScenarios.entries) {
          for (var upfrontEntry in upfrontScenarios.entries) {
            final String timeName = timeEntry.key;
            final DateTime actualReturn = timeEntry.value;

            final String damageName = damageEntry.key;
            final double damageFee = damageEntry.value;
            final bool hasDamage = damageFee > 0;

            final String depositName = depositEntry.key;
            final double depositAmount = depositEntry.value;

            final String upfrontName = upfrontEntry.key;
            final double upfrontPaid = upfrontEntry.value;

            final String scenarioTitle =
                'SCN-${scenarioNumber.toString().padLeft(3, '0')}: $timeName | $damageName | $depositName | $upfrontName';

            test(scenarioTitle, () {
              // 1. Arrange
              final rental = createMockRental(
                start: start,
                expectedReturn: due,
                amountPaid: upfrontPaid,
                depositAmount: depositAmount,
              );

              // 2. Act
              final result = RentalCalculator.calculateReturn(
                rental: rental,
                actualReturnTime: actualReturn,
                hasDamage: hasDamage,
                damageFeeAmount: damageFee,
                hourlyGraceMinutes: hourlyGraceMinutes,
                dailyGraceHours: dailyGraceHours,
                dailyRate: dailyRate,
                hourlyRate: hourlyRate,
              );

              // 3. Descriptive Execution Logs
              logScenario('\n${'=' * 70}');
              logScenario('🎯 EXECUTION LOG FOR: $scenarioTitle');
              logScenario('=' * 70);
              logScenario('[BOARD DETAILS]');
              logScenario('   - Board        : QA Board');
              logScenario('   - Value        : $purchaseCost LKR');
              logScenario(
                '   - Pricing      : Daily: $dailyRate LKR / Hourly: $hourlyRate LKR',
              );
              logScenario('\n[RENTAL CONTEXT]');
              logScenario('   - Start Time   : $start');
              logScenario('   - Expected Due : $due');
              logScenario('   - Actual Return: $actualReturn');
              logScenario(
                '   - Upfront Paid : $upfrontPaid LKR ($upfrontName)',
              );
              logScenario('   - Deposit Cash : $depositAmount LKR');
              logScenario('\n[CALCULATED RESULTS]');
              logScenario('   - Base Rent           : ${result.baseRent} LKR');
              logScenario(
                '   - Overdue Penalty Fee : ${result.overdueFee} LKR',
              );
              logScenario('   - Damage Fee Applied  : ${result.damageFee} LKR');
              logScenario('   ----------------------------------------');
              logScenario(
                '   >> TOTAL CHARGES      : ${result.totalCharges} LKR',
              );
              logScenario('   ----------------------------------------');
              logScenario(
                '   - Deposit Used        : ${result.depositUsed} LKR',
              );
              logScenario(
                '   - Refund to Customer  : ${result.depositRefund} LKR',
              );
              logScenario(
                '   >> FINAL BALANCE DUE  : ${result.balanceDue} LKR',
              );
              logScenario('\n[SYSTEM IMPACT]');
              logScenario(
                '   - Inventory Status    : ${result.newInventoryStatus.name.toUpperCase()}',
              );
              logScenario('=' * 70 + '\n');

              // 4. Assertions to ensure math holds up exactly

              // Base rent & Overdue logic validations
              if (timeName == 'Overdue (1 Day Late)') {
                expect(
                  result.baseRent,
                  3000,
                  reason: 'Actual duration stretched to 2 days',
                );
                expect(result.overdueFee, 1500, reason: '1 day late penalty');
                expect(result.totalCharges, 3000 + 1500 + damageFee);
              } else {
                expect(
                  result.baseRent,
                  1500,
                  reason: 'Actual duration billed as 1 day',
                );
                expect(
                  result.overdueFee,
                  0,
                  reason: 'No overdue penalty should apply',
                );
                expect(result.totalCharges, 1500 + damageFee);
              }

              // Balance / Refund math validation
              double outstandingBalance = result.totalCharges - upfrontPaid;
              double expectedUsedDeposit = 0.0;

              if (outstandingBalance > 0 && depositAmount > 0) {
                expectedUsedDeposit = outstandingBalance > depositAmount
                    ? depositAmount
                    : outstandingBalance;
              }
              double expectedRefund = depositAmount - expectedUsedDeposit;
              double expectedBalanceDue =
                  outstandingBalance > expectedUsedDeposit
                  ? outstandingBalance - expectedUsedDeposit
                  : 0.0;

              expect(result.depositUsed, expectedUsedDeposit);
              expect(result.depositRefund, expectedRefund);
              expect(result.balanceDue, expectedBalanceDue);

              // Inventory status validation
              if (hasDamage) {
                expect(result.newInventoryStatus, InventoryStatus.damaged);
              } else {
                expect(result.newInventoryStatus, InventoryStatus.available);
              }
            });

            scenarioNumber++;
          }
        }
      }
    }
  });
}
