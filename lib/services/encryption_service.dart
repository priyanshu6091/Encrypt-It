import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptionService {
  // Generate a key from password
  Key deriveKeyFromPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return Key.fromUtf8(digest.toString().substring(0, 32));
  }

  // Encrypt text
  String encryptText(String text, String password) {
    final key = deriveKeyFromPassword(password);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(text, iv: iv);
    return '${encrypted.base64}|${iv.base64}';
  }

  // Decrypt text
  String decryptText(String encryptedText, String password) {
    try {
      final parts = encryptedText.split('|');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted text format');
      }

      final key = deriveKeyFromPassword(password);
      final encrypter = Encrypter(AES(key));

      final encrypted = Encrypted.fromBase64(parts[0]);
      final iv = IV.fromBase64(parts[1]);

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception(
        'Failed to decrypt: Incorrect password or corrupted data',
      );
    }
  }
}
