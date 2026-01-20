import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:surfboard_rental_app/app/models/customer_model.dart';
import 'package:surfboard_rental_app/app/models/damage_fee_model.dart';
import 'package:surfboard_rental_app/app/models/inventory_model.dart';
import 'package:surfboard_rental_app/app/models/new_rental_pass_model.dart';
import 'package:surfboard_rental_app/app/models/shop_model.dart';

class PdfService {
  Future<Uint8List> generateAgreementPdf({
    required NewRentalPassModel rentalData,
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
          _buildHeader(formattedDate),
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
          _buildSectionTitle("4. USE OF EQUIPMENT"),
          _buildUseOfEquipment(),
          pw.SizedBox(height: 20),
          _buildSectionTitle("5. ASSUMPTION OF RISK"),
          _buildAssumptionOfRisk(),
          pw.SizedBox(height: 20),
          _buildSectionTitle("6. LIABILITY WAIVER"),
          _buildLiabilityWaiver(),
          pw.SizedBox(height: 20),
          _buildSectionTitle("7. DAMAGE, LOSS, OR THEFT"),
          _buildDamageSection(selectedDamageFees),
          pw.SizedBox(height: 20),
          _buildSectionTitle("8. CONDITION OF EQUIPMENT"),
          _buildConditionOfEquipment(),
          pw.SizedBox(height: 20),
          _buildSectionTitle("9. GOVERNING LAW"),
          _buildGoverningLaw("Your Country/State"),
          pw.SizedBox(height: 40),
          _buildSectionTitle("10. SIGNATURES"),
          _buildSignatures(
            rentalData.customer,
            formattedDate,
            customerSignature,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(String date) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text("SURFBOARD RENTAL AGREEMENT",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildDetailRow("Date:", date),
        ]);
  }

  pw.Widget _buildCompanyAndRenterInfo(
      ShopModel shop, CustomerModel renter) {
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
                  "Full Name:", "${renter.firstName} ${renter.lastName}"),
              _buildDetailRow("Phone:", renter.phone),
              _buildDetailRow("ID / Passport No.:", renter.nic),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildEquipmentInfo(InventoryModel board) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _buildDetailRow(
          "Surfboard (Type / Size):", "${board.brand} ${board.name} ${board.sizeFeet}'${board.sizeInches}"),
      _buildDetailRow("Accessories (Leash / Fins):", "Included"),
    ]);
  }

  pw.Widget _buildRentalPeriod(NewRentalPassModel rentalData) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _buildDetailRow("Start Date & Time:", rentalData.startDateTimeString),
      _buildDetailRow("Return Date & Time:", rentalData.dueDateTimeString),
      pw.SizedBox(height: 5),
      pw.Text("Late returns may result in extra charges.", style: pw.TextStyle(fontStyle: pw.FontStyle.italic))
    ]);
  }

    pw.Widget _buildFeeAndDeposit(double rentalFee, double deposit) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _buildDetailRow("Rental Fee:", "R\$ ${rentalFee.toStringAsFixed(2)}"),
      if (deposit > 0)
        _buildDetailRow("Deposit (if required):", "R\$ ${deposit.toStringAsFixed(2)}"),
    ]);
  }

  pw.Widget _buildUseOfEquipment() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("The renter agrees to:"),
        pw.Bullet(text: "Use the surfboard safely and only for surfing"),
        pw.Bullet(text: "Not allow anyone else to use the equipment"),
        pw.Bullet(text: "Follow all local beach and surf rules"),
        pw.Bullet(text: "Not surf under the influence of alcohol or drugs"),
      ]
    );
  }

   pw.Widget _buildAssumptionOfRisk() {
    return pw.Text("The renter understands that surfing is a dangerous activity and accepts full responsibility for any injury, accident, or loss that may occur while using the rented equipment.");
   }

   pw.Widget _buildLiabilityWaiver() {
    return pw.Text("The renter releases and agrees not to hold the rental company responsible for any injury, damage, or loss resulting from the use of the surfboard or accessories.");
   }

   pw.Widget _buildDamageSection(List<DamageFeeModel> fees) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("The renter is fully responsible for the surfboard and accessories during the rental period."),
        pw.SizedBox(height: 5),
        pw.Text("The renter agrees to pay for:"),
         pw.Bullet(text: "Dings, cracks, breaks, snapped boards, or fin damage"),
        pw.Bullet(text: "Broken or lost leashes or fins"),
        pw.Bullet(text: "Water damage caused by unrepaired dings"),
        pw.Bullet(text: "Loss or theft of the surfboard or accessories"),
        pw.SizedBox(height: 5),
        pw.Text("Normal wear from proper use is acceptable. Any damage beyond normal wear will be charged."),
        pw.SizedBox(height: 5),
        pw.Text("If the board is lost, stolen, or damaged beyond repair, the renter agrees to pay the full replacement value."),
        pw.SizedBox(height: 10),
        _buildSubHeader("DAMAGE PRICE GUIDE"),
        ...fees.map((fee) => _buildDetailRow("${fee.damageType}:", "R\$ ${fee.feeAmount.toStringAsFixed(2)}")).toList(),
         pw.SizedBox(height: 5),
        pw.Text("Prices are estimates. Final charges depend on repair or replacement cost.", style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
      ]
    );
   }

   pw.Widget _buildConditionOfEquipment() {
     return pw.Text("The renter confirms the equipment was received in good condition and agrees to return it in the same condition, excluding normal wear.");
   }

   pw.Widget _buildGoverningLaw(String law) {
     return _buildDetailRow("This agreement is governed by the laws of:", law);
   }

  pw.Widget _buildSignatures(
      CustomerModel renter, String date, Uint8List? customerSignature) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("I have read and agree to all terms of this agreement."),
          pw.SizedBox(height: 40),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                      customerSignature != null
                          ? pw.Image(pw.MemoryImage(customerSignature),
                              height: 40)
                          : _buildSignatureLine(),
                      _buildDetailRow("Renter Signature:", ""),
                      _buildDetailRow(
                          "Name:", "${renter.firstName} ${renter.lastName}"),
                      _buildDetailRow("Date:", date),
                    ])),
                pw.SizedBox(width: 40),
                pw.Expanded(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                      _buildSignatureLine(),
                      _buildDetailRow("Rental Company Signature:", ""),
                      _buildDetailRow("Name & Title:", ""),
                      _buildDetailRow("Date:", date),
                    ])),
              ]),
        ]);
  }

  // --- Helper Widgets ---
  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.only(bottom: 2),
        decoration: const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(width: 1, color: PdfColors.black))),
        child:
            pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)));
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
                child:
                    pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(child: pw.Text(value)),
          ],
        ));
  }

   pw.Widget _buildSignatureLine() {
    return pw.Container(
      height: 40,
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1, color: PdfColors.black))
      )
    );
  }
}
