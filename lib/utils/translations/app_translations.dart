import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'hello': 'Hello',
      'email_address': 'Email Address',
      'password': 'Password',
      'is_required': 'is required',
      'please_enter_valid': 'Please enter a valid',
      'invalid_email': 'Invalid email',
    },
    'es': {
      'hello': 'Hola',
      'email_address': 'Correo electrónico',
      'password': 'Contraseña',
      'is_required': 'es obligatorio',
      'please_enter_valid': 'Por favor ingrese un',
    },
  };
}