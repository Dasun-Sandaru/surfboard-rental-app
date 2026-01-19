import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this package for calls/emails

class CustomerDetailsController extends GetxController {
  
  // Dummy Customer Data (Replace with Get.arguments later)
  final customer = {
    "id": "CUST-001",
    "first_name": "Kai",
    "last_name": "Smith",
    "phone": "(808) 555-0123",
    "email": "kai.smith@example.com",
    "nic": "N987654321",
    "notes": "Prefers longboards. Always returns on time.",
    "imageUrl": "https://via.placeholder.com/150", 
    "created_at": "2024-01-15",
  }.obs;

  // Dummy History Data
  final history = <Map<String, dynamic>>[
    {
      "date": "15 Aug 2024",
      "items": "Firewire Longboard (9'0\")",
      "duration": "2 Days",
      "cost": "\$40.00",
      "status": "Returned", // Status for color coding
    },
    {
      "date": "01 Aug 2024",
      "items": "Channel Islands Fish (6'2\")",
      "duration": "1 Day",
      "cost": "\$25.00",
      "status": "Late Return",
    },
    {
      "date": "20 Jul 2024",
      "items": "Soft Top (8'0\")",
      "duration": "4 Hours",
      "cost": "\$15.00",
      "status": "Returned",
    },
  ].obs;

  void editCustomer() {
    // Navigate to Edit Screen with current data
    Get.toNamed('/add-edit-customer', arguments: customer);
  }

  void makeCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: customer['phone']);
    if (await canLaunchUrl(launchUri)) {
      await launchUri;
    } else {
      Get.snackbar("Error", "Could not launch dialer");
    }
  }

  void sendEmail() {
    Get.snackbar("Action", "Opening Email App...");
  }
}