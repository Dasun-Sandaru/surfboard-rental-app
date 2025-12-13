import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class AFormatter {
  static String formatDate(DateTime? date, {String? sdate}) {
    // Default output format is just the date. Pass `outputFormat` to change.
    return formatDateWithFormat(date, sdate: sdate, outputFormat: 'yyyy-MM-dd');
  }

  static String formatCurrency(String amount) {
    double priceDouble = double.parse(amount);
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
    ).format(priceDouble);
  }

  static String formatPhoneNumber(String phonenumber) {
    // Assuming a 10-digit US phone number farmat: (123) 346-7890
    if (phonenumber.length == 10) {
      return '(${phonenumber.substring(0, 3)}) ${phonenumber.substring(3, 6)} ${phonenumber.substring(6)}';
    } else if (phonenumber.length == 11) {
      return '(${phonenumber.substring(0, 4)}) ${phonenumber.substring(4, 7)} ${phonenumber.substring(7)}';
    }

    // Add more custome phone number formatting logic for different formats if needed
    return phonenumber;
  }

  static String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  // Function to convert the hex string to a Color object
  static Color colorFromString(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String greeting() {
    var hour = DateTime.now().hour;
    if (hour <= 12) {
      return 'good_morning'.tr;
    } else if ((hour > 12) && (hour <= 16)) {
      return 'good_afternoon'.tr;
    } else if ((hour > 16) && (hour < 20)) {
      return 'good_evening'.tr;
    } else {
      return 'good_night'.tr;
    }
  }

  /// Converts an ISO 8601 timestamp to a relative time string like "about 16 hours ago"
  static String timeAgo(String isoTimestamp, {String locale = 'en'}) {
    try {
      final dateTime = DateTime.parse(isoTimestamp).toLocal();
      String result = timeago.format(
        dateTime,
        locale: locale,
        allowFromNow: true, // allows future dates like "in 5 minutes"
      );
      log("Formatted time ago: $result");
      return result;
    } catch (e) {
      return 'Invalid date';
    }
  }

  static String customTimeAgo(String isoTimestamp) {
    try {
      final dateTime = DateTime.parse(isoTimestamp).toLocal();
      final now = DateTime.now();
      final isPast = now.isAfter(dateTime);
      final diff = isPast ? now.difference(dateTime) : dateTime.difference(now);

      String suffix = isPast ? 'ago' : 'from now';
      String result;

      if (diff.inSeconds < 60) {
        result = 'just now';
      } else if (diff.inMinutes < 60) {
        result =
            '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} $suffix';
      } else if (diff.inHours < 24) {
        result = '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} $suffix';
      } else if (diff.inDays < 7) {
        result = '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} $suffix';
      } else if (diff.inDays < 30) {
        int weeks = (diff.inDays / 7).floor();
        result = '$weeks week${weeks == 1 ? '' : 's'} $suffix';
      } else if (diff.inDays < 365) {
        int months = (diff.inDays / 30).floor();
        result = '$months month${months == 1 ? '' : 's'} $suffix';
      } else {
        int years = (diff.inDays / 365).floor();
        result = '$years year${years == 1 ? '' : 's'} $suffix';
      }

      log("Formatted custom time ago: $result");
      return result;
    } catch (e) {
      log("TimeAgo error: $e");
      return 'Invalid date';
    }
  }

  static String formatGMTTimeToLocal(String rawDate) {
    final dateTime = DateTime.parse(
      rawDate,
    ).toUtc().toLocal(); // Parse as UTC, convert to local
    return DateFormat('M/d/yyyy, h:mm:ss a').format(dateTime);
  }

  /// Formats a [DateTime] or ISO date string ([sdate]) using [outputFormat].
  /// Example output format: 'yyyy-MM-dd HH:mm:ss'
  static String formatDateWithFormat(
    DateTime? date, {
    String? sdate,
    String outputFormat = 'yyyy-MM-dd',
  }) {
    try {
      if (date != null) {
        return DateFormat(outputFormat).format(date);
      } else if (sdate != null) {
        final parsedDate = DateTime.parse(sdate);
        return DateFormat(outputFormat).format(parsedDate);
      } else {
        return 'No date provided';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  static String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes == 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (bytes != 0) ? (math.log(bytes) / math.log(1024)).floor() : 0;
    final size = bytes / math.pow(1024, i);
    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }
}
