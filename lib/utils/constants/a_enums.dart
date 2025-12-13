// ignore_for_file: constant_identifier_names

import 'dart:developer';

// Upload Status Enum
enum UploadStatus { uploading, errorDio, errorBankend, success }

// Upload Img Quality Enum
enum UploadImgQuality { Low, Medium, High }

// Gender Enum
enum Gender { male, female, other }

// Payment Status Enum
enum PaymentStatus { pending, completed, failed, refunded }

// Booking Status Enum
enum BookingStatus { pending, confirmed, canceled, completed }

// User Role Enum
enum UserRole { admin, user, guest }

// Device Type Enum
enum DeviceType { mobile, tablet, desktop, web }

// Order Status Enum
enum OrderStatus { placed, processing, shipped, delivered, canceled }

// Notification Type Enum
enum NotificationType { message, alert, warning, info }

// Priority Level Enum (e.g., for tasks or issues)
enum PriorityLevel { low, medium, high, critical }

// Rating Enum (e.g., for reviews or feedback)
enum Rating { oneStar, twoStar, threeStar, fourStar, fiveStar }

// Subscription Plan Enum (if your app offers subscriptions)
enum SubscriptionPlan { free, basic, premium, enterprise }

// Days of the Week Enum
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

// File Type Enum (for file uploads)
enum FileType { image, video, audio, document, other }

void handleBookingStatus(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      log("Booking is pending.");
      break;
    case BookingStatus.confirmed:
      log("Booking is confirmed.");
      break;
    case BookingStatus.canceled:
      log("Booking has been canceled.");
      break;
    case BookingStatus.completed:
      log("Booking is completed.");
      break;
  }
}

enum DisposeLevel { low, medium, high }

// Example Usage
// handleBookingStatus(BookingStatus.confirmed);
