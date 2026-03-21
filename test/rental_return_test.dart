// ignore_for_file: avoid_print

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
  group('Comprehensive Rental Return Matrix (QA Board)', () {
    // Note: The board is a 'QA board'
    // purchase cost: 120,000 LKR
    // daily fee: 1,500 LKR
    // hourly fee: 100 LKR
    final double purchaseCost = 120000;
    final double dailyRate = 1500;
    final double hourlyRate = 100;
    final int dailyGraceHours = 2;
    final int hourlyGraceMinutes = 15;

    // Rental period definitions (1 day expected)
    final start = DateTime(2026, 1, 1, 10, 0);
    final due = DateTime(2026, 1, 2, 10, 0);

    // Matrix Dimension 1: Time Scenarios
    final Map<String, DateTime> timeScenarios = {
      'Before Due Time (Early)': DateTime(
        2026,
        1,
        2,
        5,
        0,
      ), // Return 5 hours early
      'Exact Due Time (On-Time)': DateTime(
        2026,
        1,
        2,
        10,
        0,
      ), // Return exactly on time
      'Within Grace Period': DateTime(
        2026,
        1,
        2,
        11,
        30,
      ), // Return 1.5h late (within 2h grace)
      'Overdue (1 Day Late)': DateTime(
        2026,
        1,
        3,
        10,
        0,
      ), // Return 1 full day late
    };

    // Matrix Dimension 2: Damage Scenarios
    final Map<String, double> damageScenarios = {
      'No Damage': 0.0,
      'Minor Damage (e.g. Broken Fin)': 350.0,
      'Total Loss (Broken Board)':
          purchaseCost, // Renter responsible for 120,000
    };

    // Matrix Dimension 3: Deposit Scenarios
    final Map<String, double> depositScenarios = {
      'No Security Deposit': 0.0,
      'Has Security Deposit (5000 LKR)': 5000.0,
    };

    int scenarioNumber = 1;

    for (var timeEntry in timeScenarios.entries) {
      for (var damageEntry in damageScenarios.entries) {
        for (var depositEntry in depositScenarios.entries) {
          final String timeName = timeEntry.key;
          final DateTime actualReturn = timeEntry.value;

          final String damageName = damageEntry.key;
          final double damageFee = damageEntry.value;
          final bool hasDamage = damageFee > 0;

          final String depositName = depositEntry.key;
          final double depositAmount = depositEntry.value;

          final String scenarioTitle =
              'SCN-${scenarioNumber.toString().padLeft(3, '0')}: $timeName | $damageName | $depositName';

          test(scenarioTitle, () {
            // 1. Arrange
            final rental = createMockRental(
              start: start,
              expectedReturn: due,
              amountPaid: 1500, // Assuming 1-day base rent was paid upfront
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
            print('\n${'=' * 60}');
            print('🎯 EXECUTION LOG FOR: $scenarioTitle');
            print('=' * 60);
            print('[BOARD DETAILS]');
            print('   - Board        : QA Board');
            print('   - Value        : $purchaseCost LKR');
            print(
              '   - Pricing      : Daily: $dailyRate LKR / Hourly: $hourlyRate LKR',
            );
            print('\n[RENTAL CONTEXT]');
            print('   - Start Time   : $start');
            print('   - Expected Due : $due');
            print('   - Actual Return: $actualReturn');
            print(
              '   - Upfront Paid : 1500.0 LKR',
            ); // Assuming 1-day base rent was paid upfront
            print('   - Deposit Cash : $depositAmount LKR');
            print('\n[CALCULATED RESULTS]');
            print('   - Base Rent           : ${result.baseRent} LKR');
            print('   - Overdue Penalty Fee : ${result.overdueFee} LKR');
            print('   - Damage Fee Applied  : ${result.damageFee} LKR');
            print('   ----------------------------------------');
            print('   >> TOTAL CHARGES      : ${result.totalCharges} LKR');
            print('   ----------------------------------------');
            print('   - Deposit Used        : ${result.depositUsed} LKR');
            print('   - Refund to Customer  : ${result.depositRefund} LKR');
            print('   >> FINAL BALANCE DUE  : ${result.balanceDue} LKR');
            print('\n[SYSTEM IMPACT]');
            print(
              '   - Inventory Status    : ${result.newInventoryStatus.name.toUpperCase()}',
            );
            print('=' * 60 + '\n');

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
              // Early, Exact, or Grace Period
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
            double outstandingBalance =
                result.totalCharges - 1500; // Subtract upfront
            double expectedUsedDeposit = 0.0;

            if (outstandingBalance > 0 && depositAmount > 0) {
              expectedUsedDeposit = outstandingBalance > depositAmount
                  ? depositAmount
                  : outstandingBalance;
            }
            double expectedRefund = depositAmount - expectedUsedDeposit;
            double expectedBalanceDue = outstandingBalance > expectedUsedDeposit
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
  });
}
