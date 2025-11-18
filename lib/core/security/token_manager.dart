import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_constants.dart';

/// Token Manager for handling JWT tokens
class TokenManager {
  final FlutterSecureStorage _secureStorage;

  TokenManager(this._secureStorage);

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: StorageConstants.accessToken,
      value: token,
    );
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: StorageConstants.accessToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: StorageConstants.refreshToken,
      value: token,
    );
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageConstants.refreshToken);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(
      key: StorageConstants.userId,
      value: userId,
    );
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: StorageConstants.userId);
  }

  /// Save person ID
  Future<void> savePersonId(String personId) async {
    await _secureStorage.write(
      key: StorageConstants.personId,
      value: personId,
    );
  }

  /// Get person ID
  Future<String?> getPersonId() async {
    return await _secureStorage.read(key: StorageConstants.personId);
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: StorageConstants.accessToken);
    await _secureStorage.delete(key: StorageConstants.refreshToken);
    await _secureStorage.delete(key: StorageConstants.userId);
    await _secureStorage.delete(key: StorageConstants.personId);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
