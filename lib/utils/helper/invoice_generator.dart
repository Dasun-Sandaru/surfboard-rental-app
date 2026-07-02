import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../app/models/customer_model.dart';
import '../../app/models/payment_model.dart';
import '../../app/models/rental_model.dart';
import '../../app/models/shop_model.dart';
import '../constants/a_enums.dart';

class InvoiceGenerator {
  static Future<Uint8List> generateInvoice({
    required ShopModel shop,
    required CustomerModel customer,
    required RentalModel rental,
    required List<PaymentModel> payments,
  }) async {
    final pdf = pw.Document();

    final currency = rental.currency ?? shop.currency;
    final formatter = NumberFormat.currency(
      symbol: '$currency ',
      decimalDigits: 2,
    );
    final formatStr = rental.dateFormat ?? 'MMM dd, yyyy';
    final dateFormat = DateFormat('$formatStr - hh:mm a');

    // Calculate totals
    double totalCharges = 0.0;
    double depositAmount = rental.securityDeposit.paid;
    
    double refundAmount = payments
        .where((p) => p.category == PaymentCategory.refund)
        .fold(0.0, (s, p) => s + p.amount);
        
    double cashCollected = payments
        .where((p) => p.category == PaymentCategory.partialPayment)
        .fold(0.0, (s, p) => s + p.amount);

    // Payments that represent charges (Rental Base Fee, Late Fee, Damage Fee)
    final charges = payments
        .where(
          (p) =>
              p.category == PaymentCategory.rental ||
              p.category == PaymentCategory.lateFee ||
              p.category == PaymentCategory.damageFee,
        )
        .toList();

    for (var charge in charges) {
      totalCharges += charge.amount;
    }

    final balance = totalCharges - depositAmount - cashCollected + refundAmount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        shop.businessName,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        shop.location,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Phone: ${shop.phone}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Invoice #: ${rental.id?.substring(0, 8).toUpperCase() ?? "N/A"}',
                      ),
                      pw.Text('Date: ${dateFormat.format(DateTime.now())}'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              // Customer Details
              pw.Text(
                'Billed To:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                customer.fullName,
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(customer.phone, style: const pw.TextStyle(fontSize: 12)),
              if (customer.email.isNotEmpty)
                pw.Text(
                  customer.email,
                  style: const pw.TextStyle(fontSize: 12),
                ),

              pw.SizedBox(height: 30),

              // Rental Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Item:',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          rental.cachedItemName ?? 'Surfboard',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Start Time:',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(dateFormat.format(rental.startTime)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'End Time:',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          rental.actualReturnTime != null
                              ? dateFormat.format(rental.actualReturnTime!)
                              : 'N/A',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Charges Table
              pw.Text(
                'Charge Breakdown',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                },
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                  horizontalInside: pw.BorderSide(color: PdfColors.grey200),
                ),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blueGrey50,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: pw.Text(
                          'Amount',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...charges.map((charge) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: pw.Text(charge.note ?? charge.category.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: pw.Text(
                            formatter.format(charge.amount),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 20),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Charges:'),
                            pw.Text(formatter.format(totalCharges)),
                          ],
                        ),
                        if (depositAmount > 0) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Security Deposit:'),
                              pw.Text('-${formatter.format(depositAmount)}'),
                            ],
                          ),
                        ],
                        if (cashCollected > 0) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Cash Paid:'),
                              pw.Text('-${formatter.format(cashCollected)}'),
                            ],
                          ),
                        ],
                        if (refundAmount > 0) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Refund Issued:'),
                              pw.Text('+${formatter.format(refundAmount)}'),
                            ],
                          ),
                        ],
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Balance Due:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              formatter.format(balance > 0 ? balance : 0),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for renting with us!',
                  style: const pw.TextStyle(
                    color: PdfColors.grey700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
