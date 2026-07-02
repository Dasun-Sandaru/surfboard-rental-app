import 'package:get/get.dart';

class AValidator {
  static String? validateText(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${'is_required'.tr}';
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
      return 'field_required'.trParams({'field': fieldName});
    }

    final number = num.tryParse(value);
    if (number == null) {
      return 'invalid_number'.trParams({'field': fieldName});
    }

    if (number < 0) {
      return 'number_positive'.trParams({'field': fieldName});
    }

    return null;
  }

  static String? validateAmount(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'field_required'.trParams({'field': fieldName});
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'invalid_amount'.trParams({'field': fieldName});
    }

    if (amount < 0) {
      return 'amount_positive'.trParams({'field': fieldName});
    }

    return null;
  }

  // static String? validateSurfboardSize(String? feetValue, String? inchesValue) {
  //   if ((feetValue == null || feetValue.isEmpty) &&
  //       (inchesValue == null || inchesValue.isEmpty)) {
  //     return 'surfboard_size_required'.tr;
  //   }

  //   final feet = int.tryParse(feetValue ?? '0') ?? 0;
  //   final inches = int.tryParse(inchesValue ?? '0') ?? 0;

  //   if (feet < 0 || inches < 0 || inches >= 12) {
  //     return 'invalid_surfboard_size'.tr;
  //   }

  //   return null;
  // }

  static String? validateSurfboardFeet(String? value) {
    if (value == null || value.isEmpty) {
      return 'surfboard_size_required'.tr;
    }

    final feet = int.tryParse(value);
    if (feet == null || feet < 0) {
      return 'invalid_surfboard_size'.tr;
    }

    return null;
  }

  static String? validateSurfboardInches(String? value) {
    if (value == null || value.isEmpty) {
      return 'surfboard_size_required'.tr;
    }

    final inches = int.tryParse(value);
    if (inches == null || inches < 0 || inches >= 12) {
      return 'invalid_surfboard_size'.tr;
    }

    return null;
  }
}
