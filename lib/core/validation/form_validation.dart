import 'package:easy_localization/easy_localization.dart';

class FormValidators {
  FormValidators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final email = value.trim().toLowerCase();

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'please_enter_valid_email'.tr();
    }

    const validTlds = {'com', 'org', 'net', 'edu', 'gov'};

    final tld = email.split('.').last;

    if (!validTlds.contains(tld)) {
      return 'please_enter_valid_email'.tr();
    }

    return null;
  }

  static String? Function(String?) required(String errorKey) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorKey.tr();
      }
      return null;
    };
  }

  static String? Function(String?) requiredName({int maxLength = 20}) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'please_enter_your_name'.tr();
      }
      if (value.length > maxLength - 1) {
        return 'full_name_max_length'.tr();
      }
      return null;
    };
  }

  static String? Function(String?) optionalName({int maxLength = 20}) {
    return (value) {
      if (value != null && value.length > maxLength - 1) {
        return 'full_name_max_length'.tr();
      }
      return null;
    };
  }

  static String? Function(String?) requiredEmail({int maxLength = 30}) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'please_enter_email'.tr();
      }

      // validateEmail returns null if valid, error string if invalid
      final emailError = validateEmail(value);
      if (emailError != null) {
        return emailError;
      }
      return null;
    };
  }

  static String? Function(String?) requiredPassword({int minLength = 8}) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'please_enter_password'.tr();
      }
      if (value.length < minLength) {
        return 'password_min_length'.tr(args: [minLength.toString()]);
      }
      return null;
    };
  }

  static String? Function(String?) amount({
    double minAmount = 0,
    String errorMessageEmpty = 'Please enter amount',
    String errorMessageInvalid = 'Please enter a valid amount',
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return errorMessageEmpty;
      }
      final amount = double.tryParse(value);
      if (amount == null || amount <= minAmount) {
        return errorMessageInvalid;
      }
      return null;
    };
  }

  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
