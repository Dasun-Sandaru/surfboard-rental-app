import 'package:get/get.dart';

class AValidator {
  static String? validateText(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      // return 'field_required'.trParams({'field': fieldName});
      return '$fieldName is required';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required'.tr;
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'invalid_email'.tr;
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required'.tr;
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'password_min_length'.tr;
    }

    // Check for UPPERCASE letters
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'password_uppercase'.tr;
    }

    // Check for special characters
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'password_special_char'.tr;
    }

    return null;
  }

  static String? validateConfirmPassword(String? pw, String? copw) {
    if (copw == null || copw.isEmpty) {
      return 'confirm_password_required'.tr;
    }

    if (copw != pw) {
      return 'confirm_password_not_match'.tr;
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'phone_required'.tr;
    }

    // Regular expression for phone number validation (assuming a 10-digit format)
    final phoneRegExp = RegExp(r'^\d{10}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'invalid_phone_format'.tr;
    }
    return null;
  }

  static String? validateDropDown(String? value, String fieldName) {
    if (value == null || value == '-1') {
      return 'field_required'.trParams({'field': fieldName});
    }

    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      // return 'field_required'.trParams({'field': fieldName});
      return '$fieldName is required';
    }

    final number = num.tryParse(value);
    if (number == null) {
      // return 'invalid_number'.trParams({'field': fieldName});
      return '$fieldName must be a valid number';
    }

    if (number < 0) {
      // return 'number_positive'.trParams({'field': fieldName});
      return '$fieldName must be a positive number';
    }

    return null;
  }

  static String? validateAmount(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      // return 'field_required'.trParams({'field': fieldName});
      return '$fieldName is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      // return 'invalid_amount'.trParams({'field': fieldName});
      return '$fieldName must be a valid amount';
    }

    if (amount < 0) {
      // return 'amount_positive'.trParams({'field': fieldName});
      return '$fieldName must be a positive amount';
    }

    return null;
  }
}
