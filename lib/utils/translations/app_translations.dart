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
    'si': {
      'hello': 'ආයුබෝවන්',
      'email_address': 'විද්යුත් තැපැල් ලිපිනය',
      'password': 'මුරපදය',
      'is_required': 'අවශ්‍යයි',
      'please_enter_valid': 'කරුණාකර වලංගු එකක් ඇතුලත් කරන්න',
      'invalid_email': 'වලංගු නොවන විද්‍යුත් තැපෑලකි',
    },
  };
}
