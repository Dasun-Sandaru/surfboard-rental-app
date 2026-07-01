import 'dart:developer';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionHelper {
  static const String logName = 'EncryptionHelper';
  
  // A secure 32-character (256-bit) fallback key if ENCRYPTION_KEY is not defined in .env
  static const String _fallbackKey = 'surfboardrentalappsecretkey12345';

  static encrypt.Key get _encryptionKey {
    final keyStr = dotenv.env['ENCRYPTION_KEY'] ?? _fallbackKey;
    // Ensure the key is exactly 32 bytes (pad or truncate if necessary)
    if (keyStr.length < 32) {
      return encrypt.Key.fromUtf8(keyStr.padRight(32, '0'));
    } else if (keyStr.length > 32) {
      return encrypt.Key.fromUtf8(keyStr.substring(0, 32));
    }
    return encrypt.Key.fromUtf8(keyStr);
  }

  /// Encrypts plain text using AES (CBC mode, PKCS7 padding) with a random IV.
  /// Returns a string formatted as 'iv_base64:ciphertext_base64'.
  static String encryptString(String plainText) {
    if (plainText.isEmpty) return plainText;
    try {
      final key = _encryptionKey;
      final iv = encrypt.IV.fromLength(16); // generates random 16-byte IV
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      log('Encryption error: $e', name: logName);
      return plainText; // Fail-safe: return plain text if encryption fails
    }
  }

  /// Decrypts ciphertext formatted as 'iv_base64:ciphertext_base64'.
  /// If format is invalid or decryption fails, returns input text as-is.
  static String decryptString(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;
    
    // Check if the text matches the encrypted format (iv:ciphertext)
    final parts = encryptedText.split(':');
    if (parts.length != 2) {
      // Not encrypted or old format data, return as-is
      return encryptedText;
    }

    try {
      final key = _encryptionKey;
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(parts[1]), iv: iv);
      return decrypted;
    } catch (e) {
      log('Decryption error: $e. Returning input value.', name: logName);
      return encryptedText; // Fallback to raw value if decryption fails (e.g., if it wasn't encrypted)
    }
  }
}
