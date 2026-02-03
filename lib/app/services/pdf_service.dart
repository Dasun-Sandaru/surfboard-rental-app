import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/agreement_template_model.dart';
import '../models/customer_model.dart';
import '../models/damage_fee_model.dart';
import '../models/inventory_model.dart';
import '../models/init_rental_model.dart';
import '../models/shop_model.dart';
import 'agreement_template_service.dart';

class PdfService {
  final AgreementTemplateService _templateService = AgreementTemplateService();

  /// Generate agreement PDF using a template
  Future<Uint8List> generateAgreementPdf({
    required InitRentalModel rentalData,
    required ShopModel shopData,
    required String shopId,
    required double rentalFee,
    required double deposit,
    required List<DamageFeeModel> selectedDamageFees,
    String? templateId,
    Uint8List? customerSignature,
  }) async {
    // Fetch template from Firestore (use default if not specified)
    final template = templateId != null
        ? await _templateService.getTemplate(
            shopId: shopId,
            templateId: templateId,
          )
        : await _templateService.getDefaultTemplate(shopId);

    if (template == null) {
      throw Exception('No agreement template found for shop: $shopId');
    }

    return _generatePdfFromTemplate(
      template: template,
      rentalData: rentalData,
      shopData: shopData,
      rentalFee: rentalFee,
      deposit: deposit,
      selectedDamageFees: selectedDamageFees,
      customerSignature: customerSignature,
    );
  }

  /// Generate PDF from template (internal method)
  Future<Uint8List> _generatePdfFromTemplate({
    required AgreementTemplateModel template,
    required InitRentalModel rentalData,
    required ShopModel shopData,
    required double rentalFee,
    required double deposit,
    required List<DamageFeeModel> selectedDamageFees,
    Uint8List? customerSignature,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          _buildHeader(
            formattedDate,
            template.sections['header'] ?? 'SURFBOARD RENTAL AGREEMENT',
          ),
          pw.SizedBox(height: 30),
          _buildCompanyAndRenterInfo(shopData, rentalData.customer),
          pw.SizedBox(height: 20),
          _buildSectionTitle("1. EQUIPMENT RENTED"),
          _buildEquipmentInfo(rentalData.items.first),
          pw.SizedBox(height: 20),
          _buildSectionTitle("2. RENTAL PERIOD"),
          _buildRentalPeriod(rentalData),
          pw.SizedBox(height: 20),
          _buildSectionTitle("3. RENTAL FEE & DEPOSIT"),
          _buildFeeAndDeposit(rentalFee, deposit),
          pw.SizedBox(height: 20),
          _buildSectionTitle(
            template.sections['use_of_equipment_title'] ??
                "4. USE OF EQUIPMENT",
          ),
          _buildUseOfEquipmentFromTemplate(
            template.sections['use_of_equipment'],
          ),
          pw.SizedBox(height: 20),
          _buildSectionTitle(
            template.sections['assumption_of_risk_title'] ??
                "5. ASSUMPTION OF RISK",
          ),
          _buildTextSection(template.sections['assumption_of_risk']),
          pw.SizedBox(height: 20),
          _buildSectionTitle(
            template.sections['liability_waiver_title'] ??
                "6. LIABILITY WAIVER",
          ),
          _buildTextSection(template.sections['liability_waiver']),
          pw.SizedBox(height: 20),
          _buildSectionTitle(
            template.sections['damage_responsibility_title'] ??
                "7. DAMAGE, LOSS, OR THEFT",
          ),
          _buildDamageSection(
            selectedDamageFees,
            template.sections['damage_responsibility'],
          ),
          pw.SizedBox(height: 20),
          _buildSectionTitle(
            template.sections['condition_of_equipment_title'] ??
                "8. CONDITION OF EQUIPMENT",
          ),
          _buildTextSection(template.sections['condition_of_equipment']),
          pw.SizedBox(height: 20),
          _buildSectionTitle(
            template.sections['governing_law_title'] ?? "9. GOVERNING LAW",
          ),
          _buildTextSection(template.sections['governing_law']),
          pw.SizedBox(height: 40),
          _buildSectionTitle("10. SIGNATURES"),
          _buildSignatures(
            rentalData.customer,
            formattedDate,
            customerSignature,
            template.sections['signature_statement'],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(String date, String headerText) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          headerText,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        _buildDetailRow("Date:", date),
      ],
    );
  }

  pw.Widget _buildCompanyAndRenterInfo(ShopModel shop, CustomerModel renter) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSubHeader("RENTAL COMPANY"),
              _buildDetailRow("Business Name:", shop.businessName),
              _buildDetailRow("Phone / WhatsApp:", shop.phone),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSubHeader("RENTER INFORMATION"),
              _buildDetailRow(
                "Full Name:",
                "${renter.firstName} ${renter.lastName}",
              ),
              _buildDetailRow("Phone:", renter.phone),
              _buildDetailRow("ID / Passport No.:", renter.nic),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildEquipmentInfo(InventoryModel board) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          "Surfboard (Type / Size):",
          "${board.brand} ${board.name} ${board.sizeFeet}'${board.sizeInches}",
        ),
        _buildDetailRow("Accessories (Leash / Fins):", "Included"),
      ],
    );
  }

  pw.Widget _buildRentalPeriod(InitRentalModel rentalData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailRow("Start Date & Time:", rentalData.startDateTimeString),
        _buildDetailRow("Return Date & Time:", rentalData.dueDateTimeString),
        pw.SizedBox(height: 5),
        pw.Text(
          "Late returns may result in extra charges.",
          style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
        ),
      ],
    );
  }

  pw.Widget _buildFeeAndDeposit(double rentalFee, double deposit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailRow("Rental Fee:", "R\$ ${rentalFee.toStringAsFixed(2)}"),
        if (deposit > 0)
          _buildDetailRow(
            "Deposit (if required):",
            "R\$ ${deposit.toStringAsFixed(2)}",
          ),
      ],
    );
  }

  pw.Widget _buildUseOfEquipmentFromTemplate(String? content) {
    if (content == null || content.isEmpty) {
      return pw.SizedBox.shrink();
    }
    return _buildTextSectionWithBullets(content);
  }

  pw.Widget _buildDamageSection(
    List<DamageFeeModel> fees,
    String? templateContent,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (templateContent != null && templateContent.isNotEmpty)
          _buildTextSectionWithBullets(templateContent)
        else
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "The renter is fully responsible for the surfboard and accessories during the rental period.",
              ),
            ],
          ),
        pw.SizedBox(height: 10),
        _buildSubHeader("DAMAGE PRICE GUIDE"),
        ...fees
            .map(
              (fee) => _buildDetailRow(
                "${fee.damageType}:",
                "R\$ ${fee.feeAmount.toStringAsFixed(2)}",
              ),
            )
            ,
        pw.SizedBox(height: 5),
        pw.Text(
          "Prices are estimates. Final charges depend on repair or replacement cost.",
          style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
        ),
      ],
    );
  }

  pw.Widget _buildSignatures(
    CustomerModel renter,
    String date,
    Uint8List? customerSignature,
    String? signatureStatement,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          signatureStatement ??
              "I have read and agree to all terms of this agreement.",
        ),
        pw.SizedBox(height: 40),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  customerSignature != null
                      ? pw.Image(pw.MemoryImage(customerSignature), height: 40)
                      : _buildSignatureLine(),
                  _buildDetailRow("Renter Signature:", ""),
                  _buildDetailRow(
                    "Name:",
                    "${renter.firstName} ${renter.lastName}",
                  ),
                  _buildDetailRow("Date:", date),
                ],
              ),
            ),
            pw.SizedBox(width: 40),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildSignatureLine(),
                  _buildDetailRow("Rental Company Signature:", ""),
                  _buildDetailRow("Name & Title:", ""),
                  _buildDetailRow("Date:", date),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Helper Widgets ---
  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 1, color: PdfColors.black),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
      ),
    );
  }

  pw.Widget _buildSubHeader(String title) {
    return pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold));
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  pw.Widget _buildSignatureLine() {
    return pw.Container(
      height: 40,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 1, color: PdfColors.black),
        ),
      ),
    );
  }

  /// Build text section from template content
  pw.Widget _buildTextSection(String? content) {
    if (content == null || content.isEmpty) {
      return pw.SizedBox.shrink();
    }
    return pw.Text(content);
  }

  /// Build text section with bullet points (parse bullet markers with •)
  pw.Widget _buildTextSectionWithBullets(String content) {
    if (content.isEmpty) {
      return pw.SizedBox.shrink();
    }

    final lines = content.split('\n');
    final widgets = <pw.Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(pw.SizedBox(height: 5));
      } else if (line.trim().startsWith('•')) {
        widgets.add(pw.Bullet(text: line.trim().replaceFirst('•', '').trim()));
      } else {
        widgets.add(pw.Text(line.trim()));
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: widgets,
    );
  }
}