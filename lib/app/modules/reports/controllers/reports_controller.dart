import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../../../data/firestore/firestore_fields.dart';
import '../../../../data/firestore/firestore_collections.dart';
import '../../../../utils/storage/app_storage.dart';
import '../../../models/shop_model.dart';

enum ReportType { customers, inventory, rentals, damages }

class ReportsController extends GetxController {
  final isLoading = false.obs;
  
  // Selected Filters
  final selectedReportType = ReportType.rentals.obs;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);
  final selectedStatus = 'All'.obs;

  // Results
  final reportResults = <Map<String, dynamic>>[].obs;
  final reportColumns = <String>[].obs;

  late final ShopModel shop;

  @override
  void onInit() {
    super.onInit();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    final String? shopId = AppLocalStorage().readData<String>(FirestoreFields.shopId);
    if (shopId != null) {
      final doc = await FirebaseFirestore.instance.collection(FirestoreCollections.shops).doc(shopId).get();
      if (doc.exists) {
        shop = ShopModel.fromSnapshot(doc);
      }
    } else {
      Get.snackbar('Error', 'Shop data not found');
    }
  }

  // Define valid statuses for each report type
  List<String> get availableStatuses {
    switch (selectedReportType.value) {
      case ReportType.inventory:
        return ['All', 'available', 'rented', 'repair', 'retired', 'damaged'];
      case ReportType.rentals:
        return ['All', 'active', 'overdue', 'item_returned', 'mark_as_damaged', 'completed', 'cancelled'];
      case ReportType.damages:
        return ['All', 'reported', 'approved', 'charged', 'resolved'];
      case ReportType.customers:
        return ['All'];
    }
  }

  String getStatusDescription(String status) {
    if (status == 'All') return 'Show all records';
    
    if (selectedReportType.value == ReportType.rentals) {
      switch (status) {
        case 'active': return 'Currently rented out';
        case 'overdue': return 'Passed expected return time';
        case 'item_returned': return 'Returned, pending inspection';
        case 'mark_as_damaged': return 'Damaged, pending report';
        case 'completed': return 'Fully settled & completed';
        case 'cancelled': return 'Rental cancelled';
      }
    } else if (selectedReportType.value == ReportType.inventory) {
      switch (status) {
        case 'available': return 'Ready for rent';
        case 'rented': return 'Currently rented out';
        case 'repair': return 'Under maintenance';
        case 'retired': return 'No longer in use';
        case 'damaged': return 'Broken, pending repair';
      }
    } else if (selectedReportType.value == ReportType.damages) {
      switch (status) {
        case 'reported': return 'New damage reported';
        case 'approved': return 'Cost approved';
        case 'charged': return 'Payment charged/due';
        case 'resolved': return 'Fully resolved';
      }
    }
    return '';
  }

  void changeReportType(ReportType type) {
    selectedReportType.value = type;
    selectedStatus.value = 'All';
    reportResults.clear();
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate.value != null && endDate.value != null
          ? DateTimeRange(start: startDate.value!, end: endDate.value!)
          : null,
    );
    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
    }
  }

  Future<void> generateReport() async {
    if (shop.id == null) return;
    
    if (selectedReportType.value != ReportType.inventory && startDate.value == null) {
      Get.snackbar('Validation', 'Please select a date range for this report.');
      return;
    }

    isLoading.value = true;
    reportResults.clear();

    try {
      final db = FirebaseFirestore.instance;
      final shopDoc = db.collection(FirestoreCollections.shops).doc(shop.id);

      switch (selectedReportType.value) {
        case ReportType.customers:
          await _fetchCustomers(shopDoc);
          break;
        case ReportType.inventory:
          await _fetchInventory(shopDoc);
          break;
        case ReportType.rentals:
          await _fetchRentals(shopDoc);
          break;
        case ReportType.damages:
          await _fetchDamages(shopDoc);
          break;
      }
    } catch (e) {
      log('Error generating report: $e');
      Get.snackbar('Error', 'Failed to generate report.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCustomers(DocumentReference shopDoc) async {
    reportColumns.value = ['Name', 'Phone', 'Email', 'Created'];
    
    // Efficient querying: using where for dates
    Query query = shopDoc.collection(FirestoreCollections.customers);
    
    if (startDate.value != null && endDate.value != null) {
      query = query
        .where(FirestoreFields.createdAt, isGreaterThanOrEqualTo: startDate.value)
        .where(FirestoreFields.createdAt, isLessThanOrEqualTo: endDate.value);
    }
    
    // Limit to 500 for safety in a report
    final snap = await query.orderBy(FirestoreFields.createdAt, descending: true).limit(500).get();
    
    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data[FirestoreFields.createdAt] as Timestamp?;
      
      final firstName = data[FirestoreFields.firstName] ?? '';
      final lastName = data[FirestoreFields.lastName] ?? '';
      final fullName = '$firstName $lastName'.trim();
      
      reportResults.add({
        'Name': fullName.isEmpty ? '-' : fullName,
        'Phone': data[FirestoreFields.phone] ?? '-',
        'Email': data[FirestoreFields.email] ?? '-',
        'Created': createdAt != null ? DateFormat('MMM d, yyyy').format(createdAt.toDate()) : '-',
      });
    }
  }

  Future<void> _fetchInventory(DocumentReference shopDoc) async {
    reportColumns.value = ['Item', 'Category', 'Status', 'Rate'];
    
    Query query = shopDoc.collection(FirestoreCollections.inventory);
    
    if (selectedStatus.value != 'All') {
      query = query.where(FirestoreFields.status, isEqualTo: selectedStatus.value);
    }
    
    final snap = await query.limit(500).get();
    
    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      final type = data[FirestoreFields.type] ?? '-';
      final itemName = data['name'] ?? '-';
      
      reportResults.add({
        'Item': itemName,
        'Category': type,
        'Status': (data[FirestoreFields.status] ?? '-').toString().toUpperCase(),
        'Rate': '${shop.currency}${data[FirestoreFields.rentalRateHour] ?? 0}/hr | ${shop.currency}${data[FirestoreFields.rentalRateDay] ?? 0}/day',
      });
    }
  }

  Future<void> _fetchRentals(DocumentReference shopDoc) async {
    reportColumns.value = ['Customer', 'Start Date', 'End Date', 'Status', 'Total'];
    
    Query query = shopDoc.collection(FirestoreCollections.rentals);
    
    if (selectedStatus.value != 'All') {
      query = query.where(FirestoreFields.status, isEqualTo: selectedStatus.value);
    }
    
    if (startDate.value != null && endDate.value != null) {
      query = query
        .where(FirestoreFields.startTime, isGreaterThanOrEqualTo: startDate.value)
        .where(FirestoreFields.startTime, isLessThanOrEqualTo: endDate.value);
    }
    
    final snap = await query.orderBy(FirestoreFields.startTime, descending: true).limit(500).get();
    
    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final start = data[FirestoreFields.startTime] as Timestamp?;
      final expectedEnd = data[FirestoreFields.expectedReturnTime] as Timestamp?;
      final actualEnd = data[FirestoreFields.actualReturnTime] as Timestamp?;
      
      final end = actualEnd ?? expectedEnd;
      
      final amountPaid = data[FirestoreFields.amountPaid] ?? 0;
      final amountExpected = data[FirestoreFields.amountExpected] ?? 0;
      final total = amountPaid > 0 ? amountPaid : amountExpected;
      
      reportResults.add({
        'Customer': data[FirestoreFields.cachedCustomerName] ?? '-',
        'Start Date': start != null ? DateFormat('MMM d, yyyy').format(start.toDate()) : '-',
        'End Date': end != null ? DateFormat('MMM d, yyyy').format(end.toDate()) : '-',
        'Status': (data[FirestoreFields.status] ?? '-').toString().toUpperCase(),
        'Total': '${shop.currency} $total',
      });
    }
  }

  Future<void> _fetchDamages(DocumentReference shopDoc) async {
    reportColumns.value = ['Type', 'Item ID', 'Date', 'Status', 'Cost'];
    
    // Since damage_reports is a subcollection of rentals, we use collectionGroup
    Query query = FirebaseFirestore.instance.collectionGroup(FirestoreCollections.damageReports);
    
    if (selectedStatus.value != 'All') {
      query = query.where(FirestoreFields.status, isEqualTo: selectedStatus.value);
    }
    
    if (startDate.value != null && endDate.value != null) {
      query = query
        .where(FirestoreFields.reportedAt, isGreaterThanOrEqualTo: startDate.value)
        .where(FirestoreFields.reportedAt, isLessThanOrEqualTo: endDate.value);
    }
    
    final snap = await query.orderBy(FirestoreFields.reportedAt, descending: true).limit(500).get();
    
    for (var doc in snap.docs) {
      // Filter out damages from other shops
      if (!doc.reference.path.contains('shops/${shopDoc.id}/')) continue;
      
      final data = doc.data() as Map<String, dynamic>;
      final date = data[FirestoreFields.reportedAt] as Timestamp?;
      
      final estimated = data[FirestoreFields.estimatedCost] ?? 0;
      final finalCost = data[FirestoreFields.finalCost] ?? 0;
      final cost = finalCost > 0 ? finalCost : estimated;
      
      reportResults.add({
        'Type': (data[FirestoreFields.damageType] ?? '-').toString().replaceAll('_', ' ').capitalizeFirst,
        'Item ID': data[FirestoreFields.itemId] ?? '-',
        'Date': date != null ? DateFormat('MMM d, yyyy').format(date.toDate()) : '-',
        'Status': (data[FirestoreFields.status] ?? '-').toString().toUpperCase(),
        'Cost': '${shop.currency} $cost',
      });
    }
  }

  // --- PDF Export ---
  Future<void> exportToPdf() async {
    if (reportResults.isEmpty) {
      Get.snackbar('Empty', 'No data to export.');
      return;
    }

    try {
      final doc = pw.Document();
      
      // Determine title
      String reportTitle = "Report";
      switch(selectedReportType.value) {
        case ReportType.customers: reportTitle = "Customers Report"; break;
        case ReportType.inventory: reportTitle = "Inventory Report"; break;
        case ReportType.rentals: reportTitle = "Rentals Report"; break;
        case ReportType.damages: reportTitle = "Damages Report"; break;
      }
      
      String dateRangeStr = "";
      if (startDate.value != null && endDate.value != null) {
        dateRangeStr = "${DateFormat('MMM d, yyyy').format(startDate.value!)} to ${DateFormat('MMM d, yyyy').format(endDate.value!)}";
      }

      // Convert results to table data
      final headers = reportColumns;
      final data = reportResults.map((row) {
        return headers.map((h) => row[h].toString()).toList();
      }).toList();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(shop.businessName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(reportTitle, style: const pw.TextStyle(fontSize: 18, color: PdfColors.blueGrey800)),
                if (dateRangeStr.isNotEmpty)
                  pw.Text("Period: $dateRangeStr", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                pw.SizedBox(height: 20),
              ],
            );
          },
          build: (context) {
            return [
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: data,
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(8),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: '${reportTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      
    } catch (e) {
      log('Error exporting PDF: $e');
      Get.snackbar('Export Failed', 'An error occurred while creating the PDF.');
    }
  }
}
