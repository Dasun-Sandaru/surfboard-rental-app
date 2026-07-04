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
import '../../../services/firestore_usage_service.dart';
import '../../../../utils/storage/app_storage.dart';
import '../../../models/shop_model.dart';
import '../../../services/pdf_service.dart';
import '../../../../utils/common/app_snack_bar.dart';

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
      FirestoreUsageService.to.trackDocumentSnapshot(doc);
      if (doc.exists) {
        shop = ShopModel.fromSnapshot(doc);
      }
    } else {
      AppSnackBar.error(title: 'error'.tr, message: 'shop_data_not_found'.tr);
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
    if (status == 'All') return 'desc_show_all'.tr;
    
    if (selectedReportType.value == ReportType.rentals) {
      switch (status) {
        case 'active': return 'desc_active_rental'.tr;
        case 'overdue': return 'desc_overdue_rental'.tr;
        case 'item_returned': return 'desc_returned_rental'.tr;
        case 'mark_as_damaged': return 'desc_damaged_rental'.tr;
        case 'completed': return 'desc_completed_rental'.tr;
        case 'cancelled': return 'desc_cancelled_rental'.tr;
      }
    } else if (selectedReportType.value == ReportType.inventory) {
      switch (status) {
        case 'available': return 'desc_available_inv'.tr;
        case 'rented': return 'desc_rented_inv'.tr;
        case 'repair': return 'desc_repair_inv'.tr;
        case 'retired': return 'desc_retired_inv'.tr;
        case 'damaged': return 'desc_damaged_inv'.tr;
      }
    } else if (selectedReportType.value == ReportType.damages) {
      switch (status) {
        case 'reported': return 'desc_reported_dmg'.tr;
        case 'approved': return 'desc_approved_dmg'.tr;
        case 'charged': return 'desc_charged_dmg'.tr;
        case 'resolved': return 'desc_resolved_dmg'.tr;
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
      AppSnackBar.info(title: 'info'.tr, message: 'select_date_range_report'.tr);
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
      AppSnackBar.error(title: 'error'.tr, message: 'failed_generate_report'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCustomers(DocumentReference shopDoc) async {
    reportColumns.value = ['name'.tr, 'phone'.tr, 'email'.tr, 'created'.tr];
    
    // Efficient querying: using where for dates
    Query query = shopDoc.collection(FirestoreCollections.customers);
    
    if (startDate.value != null && endDate.value != null) {
      query = query
        .where(FirestoreFields.createdAt, isGreaterThanOrEqualTo: startDate.value)
        .where(FirestoreFields.createdAt, isLessThanOrEqualTo: endDate.value);
    }
    
    // Limit to 500 for safety in a report
    final snap = await query.orderBy(FirestoreFields.createdAt, descending: true).limit(500).get();
    FirestoreUsageService.to.trackQuerySnapshot(snap);
    
    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data[FirestoreFields.createdAt] as Timestamp?;
      
      final firstName = data[FirestoreFields.firstName] ?? '';
      final lastName = data[FirestoreFields.lastName] ?? '';
      final fullName = '$firstName $lastName'.trim();
      
      reportResults.add({
        'name'.tr: fullName.isEmpty ? '-' : fullName,
        'phone'.tr: data[FirestoreFields.phone] ?? '-',
        'email'.tr: data[FirestoreFields.email] ?? '-',
        'created'.tr: createdAt != null ? DateFormat('MMM d, yyyy').format(createdAt.toDate()) : '-',
      });
    }
  }

  Future<void> _fetchInventory(DocumentReference shopDoc) async {
    reportColumns.value = ['item'.tr, 'category'.tr, 'status'.tr, 'rate'.tr];
    
    Query query = shopDoc.collection(FirestoreCollections.inventory);
    
    if (selectedStatus.value != 'All') {
      query = query.where(FirestoreFields.status, isEqualTo: selectedStatus.value);
    }
    
    final snap = await query.limit(500).get();
    FirestoreUsageService.to.trackQuerySnapshot(snap);
    
    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      final type = data[FirestoreFields.type] ?? '-';
      final itemName = data['name'] ?? '-';
      
      reportResults.add({
        'item'.tr: itemName,
        'category'.tr: type,
        'status'.tr: (data[FirestoreFields.status] ?? '-').toString().toUpperCase(),
        'rate'.tr: '${shop.currency}${data[FirestoreFields.rentalRateHour] ?? 0}/hr | ${shop.currency}${data[FirestoreFields.rentalRateDay] ?? 0}/day',
      });
    }
  }

  Future<void> _fetchRentals(DocumentReference shopDoc) async {
    reportColumns.value = ['customer'.tr, 'start_date_time'.tr, 'end_date_time'.tr, 'status'.tr, 'total'.tr];
    
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
    FirestoreUsageService.to.trackQuerySnapshot(snap);
    
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
        'customer'.tr: data[FirestoreFields.cachedCustomerName] ?? '-',
        'start_date_time'.tr: start != null ? DateFormat('MMM d, yyyy, h:mm a').format(start.toDate()) : '-',
        'end_date_time'.tr: end != null ? DateFormat('MMM d, yyyy, h:mm a').format(end.toDate()) : '-',
        'status'.tr: (data[FirestoreFields.status] ?? '-').toString().toUpperCase(),
        'total'.tr: '${shop.currency} $total',
      });
    }
  }

  Future<void> _fetchDamages(DocumentReference shopDoc) async {
    reportColumns.value = ['type'.tr, 'item_id'.tr, 'date'.tr, 'status'.tr, 'cost'.tr];
    
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
    FirestoreUsageService.to.trackQuerySnapshot(snap);
    
    for (var doc in snap.docs) {
      // Filter out damages from other shops
      if (!doc.reference.path.contains('shops/${shopDoc.id}/')) continue;
      
      final data = doc.data() as Map<String, dynamic>;
      final date = data[FirestoreFields.reportedAt] as Timestamp?;
      
      final estimated = data[FirestoreFields.estimatedCost] ?? 0;
      final finalCost = data[FirestoreFields.finalCost] ?? 0;
      final cost = finalCost > 0 ? finalCost : estimated;
      
      reportResults.add({
        'type'.tr: (data[FirestoreFields.damageType] ?? '-').toString().replaceAll('_', ' ').capitalizeFirst,
        'item_id'.tr: data[FirestoreFields.itemId] ?? '-',
        'date'.tr: date != null ? DateFormat('MMM d, yyyy').format(date.toDate()) : '-',
        'status'.tr: (data[FirestoreFields.status] ?? '-').toString().toUpperCase(),
        'cost'.tr: '${shop.currency} $cost',
      });
    }
  }

  // --- PDF Export ---
  Future<void> exportToPdf() async {
    if (reportResults.isEmpty) {
      AppSnackBar.info(title: 'empty'.tr, message: 'no_data_export'.tr);
      return;
    }

    try {
      final fontRegular = await PdfGoogleFonts.notoSansSinhalaRegular();
      final fontBold = await PdfGoogleFonts.notoSansSinhalaBold();

      final doc = pw.Document(
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
      );
      
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
      AppSnackBar.error(title: 'export_failed'.tr, message: 'error_creating_pdf'.tr);
    }
  }
}
