// core/services/auth_service.dart - CORRIGÉ

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Clés de stockage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _personIdKey = 'person_id';

  // Singleton instance
  static AuthService? _instance;

  factory AuthService() {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  AuthService._internal() {
    print('🔄 AuthService initialisé');
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      print(
        '🔐 AuthService - Token récupéré: ${token != null ? "OUI (${token.length} chars)" : "NON"}',
      );
      return token;
    } catch (e) {
      print('❌ AuthService - Erreur récupération token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      print('❌ AuthService - Erreur récupération refresh token: $e');
      return null;
    }
  }

  Future<String?> getPersonId() async {
    try {
      return await _secureStorage.read(key: _personIdKey);
    } catch (e) {
      print('❌ AuthService - Erreur récupération person ID: $e');
      return null;
    }
  }

  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: token);
      print(
        '💾 AuthService - Access token sauvegardé: ${token.substring(0, 20)}...',
      );
    } catch (e) {
      print('❌ AuthService - Erreur sauvegarde access token: $e');
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
      print('💾 AuthService - Refresh token sauvegardé');
    } catch (e) {
      print('❌ AuthService - Erreur sauvegarde refresh token: $e');
    }
  }

  Future<void> savePersonId(String personId) async {
    try {
      await _secureStorage.write(key: _personIdKey, value: personId);
      print('💾 AuthService - Person ID sauvegardé: $personId');
    } catch (e) {
      print('❌ AuthService - Erreur sauvegarde person ID: $e');
    }
  }

  Future<void> saveUserInfo(String userId, String email) async {
    try {
      await _secureStorage.write(key: _userIdKey, value: userId);
      await _secureStorage.write(key: _userEmailKey, value: email);
      print('💾 AuthService - User info sauvegardé: $email');
    } catch (e) {
      print('❌ AuthService - Erreur sauvegarde user info: $e');
    }
  }

  Future<Map<String, String>?> getUserInfo() async {
    try {
      final userId = await _secureStorage.read(key: _userIdKey);
      final userEmail = await _secureStorage.read(key: _userEmailKey);

      if (userId != null && userEmail != null) {
        return {'userId': userId, 'email': userEmail};
      }
      return null;
    } catch (e) {
      print('❌ AuthService - Erreur récupération user info: $e');
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userEmailKey);
      await _secureStorage.delete(key: _personIdKey);
      print('🗑️ AuthService - Tokens effacés');
    } catch (e) {
      print('❌ AuthService - Erreur effacement tokens: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    print('🔐 AuthService - isLoggedIn: $isLoggedIn');
    return isLoggedIn;
  }

  // Méthode utilitaire pour vérifier l'état
  Future<void> debugAuthStatus() async {
    final token = await getAccessToken();
    final personId = await getPersonId();

    print('🔍 AuthService - Debug:');
    print(
      '  Token: ${token != null ? "✓ (${token.substring(0, 20)}...)" : "✗"}',
    );
    print('  Person ID: ${personId ?? "✗"}');
    print('  Connecté: ${await isLoggedIn() ? "✓" : "✗"}');
  }
}
