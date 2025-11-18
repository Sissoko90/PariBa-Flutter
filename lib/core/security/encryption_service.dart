import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Encryption Service
class EncryptionService {
  EncryptionService._();

  /// Hash password using SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate random salt
  static String generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return hashPassword(random);
  }

  /// Hash password with salt
  static String hashPasswordWithSalt(String password, String salt) {
    return hashPassword(password + salt);
  }

  /// Verify password
  static bool verifyPassword(
    String password,
    String hashedPassword,
    String salt,
  ) {
    final hash = hashPasswordWithSalt(password, salt);
    return hash == hashedPassword;
  }

  /// Encode to Base64
  static String encodeBase64(String data) {
    final bytes = utf8.encode(data);
    return base64.encode(bytes);
  }

  /// Decode from Base64
  static String decodeBase64(String encoded) {
    final bytes = base64.decode(encoded);
    return utf8.decode(bytes);
  }
}
