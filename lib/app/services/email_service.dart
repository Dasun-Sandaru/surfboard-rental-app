import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/shop_model.dart';
import 'shop_service.dart';

class EmailService extends GetxService {
  final ShopService _shopService = Get.find<ShopService>();

  /// Base URL for the Resend API
  static const String _resendUrl = 'https://api.resend.com/emails';

  /// Sends the Agreement Email upon rental creation.
  Future<void> sendAgreementEmail({
    required String shopId,
    required String customerEmail,
    required String customerName,
    required String agreementLink,
  }) async {
    final shop = await _getShopModel(shopId);
    if (shop == null) return;

    final String senderEmail = _getSenderEmail(shop);
    final String apiKey = shop.resendApiKey ?? '';

    if (apiKey.isEmpty) {
      log('EmailService: No Resend API Key found for shop $shopId. Skipping agreement email.');
      return;
    }

    if (customerEmail.isEmpty) {
      log('EmailService: No customer email provided. Skipping agreement email.');
      return;
    }

    final String subject = 'Your Rental Agreement - ${shop.businessName}';
    final String htmlBody = '''
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
        <h2 style="color: #0288D1;">Rental Agreement Confirmation</h2>
        <p>Hi $customerName,</p>
        <p>Thank you for renting with <strong>${shop.businessName}</strong>!</p>
        <p>Your rental agreement has been successfully created and signed. You can view and download your official agreement document using the link below:</p>
        <div style="margin: 30px 0;">
          <a href="$agreementLink" style="background-color: #0288D1; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">View Agreement PDF</a>
        </div>
        <p>If you have any questions, please contact us at ${shop.phone} or reply to this email.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;" />
        <p style="font-size: 12px; color: #888;">
          ${shop.businessName}<br>
          ${shop.location}
        </p>
      </div>
    ''';

    await _sendEmail(
      apiKey: apiKey,
      from: senderEmail,
      to: customerEmail,
      subject: subject,
      html: htmlBody,
    );
  }

  /// Sends the Invoice Email upon rental return.
  Future<void> sendInvoiceEmail({
    required String shopId,
    required String customerEmail,
    required String customerName,
    required String invoiceLink,
    required double totalAmount,
    required String currency,
  }) async {
    final shop = await _getShopModel(shopId);
    if (shop == null) return;

    final String senderEmail = _getSenderEmail(shop);
    final String apiKey = shop.resendApiKey ?? '';

    if (apiKey.isEmpty) {
      log('EmailService: No Resend API Key found for shop $shopId. Skipping invoice email.');
      return;
    }

    if (customerEmail.isEmpty) {
      log('EmailService: No customer email provided. Skipping invoice email.');
      return;
    }

    final String subject = 'Your Rental Invoice - ${shop.businessName}';
    final String htmlBody = '''
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
        <h2 style="color: #388E3C;">Rental Completed - Invoice</h2>
        <p>Hi $customerName,</p>
        <p>Your rental with <strong>${shop.businessName}</strong> has been successfully returned and finalized.</p>
        <p>Your final invoice for the rental period is attached below. The total amount settled was <strong>$currency $totalAmount</strong>.</p>
        <div style="margin: 30px 0;">
          <a href="$invoiceLink" style="background-color: #388E3C; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">View Invoice PDF</a>
        </div>
        <p>We hope you had a great time! If you have any questions, please contact us at ${shop.phone} or reply to this email.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;" />
        <p style="font-size: 12px; color: #888;">
          ${shop.businessName}<br>
          ${shop.location}
        </p>
      </div>
    ''';

    await _sendEmail(
      apiKey: apiKey,
      from: senderEmail,
      to: customerEmail,
      subject: subject,
      html: htmlBody,
    );
  }

  /// Core function to execute the Resend HTTP POST request
  Future<void> _sendEmail({
    required String apiKey,
    required String from,
    required String to,
    required String subject,
    required String html,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_resendUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': from,
          'to': [to],
          'subject': subject,
          'html': html,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('EmailService: Successfully sent email to $to');
      } else {
        log('EmailService: Failed to send email to $to. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      log('EmailService: Exception while sending email to $to: $e');
    }
  }

  /// Determines the "From" address based on shop settings and verification status.
  String _getSenderEmail(ShopModel shop) {
    // If shopEmail exists and isn't empty, try to use it.
    // However, if they haven't verified it on Resend, it will fail.
    // The user specified they don't have a verified domain yet,
    // so we default to onboarding@resend.dev unless they specifically configure one.
    if (shop.shopEmail != null && shop.shopEmail!.isNotEmpty) {
      // It's recommended to format it with the shop name: "Shop Name <email>"
      return '${shop.businessName} <${shop.shopEmail}>';
    }
    
    // Fallback for testing on unverified accounts
    log("EmailService: No shop email configured. Using Resend testing fallback.");
    return 'onboarding@resend.dev';
  }

  /// Helper to get ShopModel
  Future<ShopModel?> _getShopModel(String shopId) async {
    try {
      final doc = await _shopService.getShop(shopId);
      if (doc.exists) {
        return ShopModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
      }
    } catch (e) {
      log("EmailService: Failed to fetch shop model: $e");
    }
    return null;
  }
}
