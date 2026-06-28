import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/shop_model.dart';
import 'shop_service.dart';

class EmailService extends GetxService {
  final ShopService _shopService = Get.find<ShopService>();

  /// Base URL for the EmailJS API
  static const String _emailJsUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  /// Sends the Agreement Email upon rental creation.
  Future<void> sendAgreementEmail({
    required String shopId,
    required String customerEmail,
    required String customerName,
    required String agreementLink,
  }) async {
    final shop = await _getShopModel(shopId);
    if (shop == null) return;

    if (customerEmail.isEmpty) {
      log('EmailService: No customer email provided. Skipping agreement email.');
      return;
    }

    await _sendEmailJs(
      shop: shop,
      customerEmail: customerEmail,
      templateParams: {
        'customer_name': customerName,
        'customer_email': customerEmail,
        'shop_name': shop.businessName,
        'shop_contact': shop.phone,
        'pdf_link': agreementLink,
        'type': 'Rental Agreement',
        'total_amount': '-',
        'reply_to': shop.shopEmail ?? '',
      },
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

    if (customerEmail.isEmpty) {
      log('EmailService: No customer email provided. Skipping invoice email.');
      return;
    }

    await _sendEmailJs(
      shop: shop,
      customerEmail: customerEmail,
      templateParams: {
        'customer_name': customerName,
        'customer_email': customerEmail,
        'shop_name': shop.businessName,
        'shop_contact': shop.phone,
        'pdf_link': invoiceLink,
        'type': 'Invoice',
        'total_amount': '$currency $totalAmount',
        'reply_to': shop.shopEmail ?? '',
      },
    );
  }

  /// Core function to execute the EmailJS HTTP POST request
  Future<void> _sendEmailJs({
    required ShopModel shop,
    required String customerEmail,
    required Map<String, dynamic> templateParams,
  }) async {
    final serviceId = dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
    final templateId = dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
    final publicKey = dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';

    if (serviceId.isEmpty || templateId.isEmpty || publicKey.isEmpty) {
      log('EmailService: EmailJS credentials missing in .env. Skipping email.');
      return;
    }

    try {
      log('====================================', name: 'EmailJS');
      log('SENDING EMAIL TO: $customerEmail', name: 'EmailJS');
      log('TEMPLATE TYPE: ${templateParams['type']}', name: 'EmailJS');

      final response = await http.post(
        Uri.parse(_emailJsUrl),
        headers: {
          'origin': 'http://localhost', // EmailJS requires origin or content-type
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': templateParams,
        }),
      );

      if (response.statusCode == 200) {
        log('SUCCESS: Email sent to $customerEmail', name: 'EmailJS');
        log('====================================', name: 'EmailJS');
      } else {
        log('FAILED to send email. Status: ${response.statusCode}', name: 'EmailJS');
        log('Response Body: ${response.body}', name: 'EmailJS');
        log('====================================', name: 'EmailJS');
      }
    } catch (e) {
      log('EXCEPTION while sending email: $e', name: 'EmailJS');
      log('====================================', name: 'EmailJS');
    }
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
