import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/person_model.dart';

/// Auth Remote DataSource
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String identifier, String password);
  Future<Map<String, dynamic>> register(Map<String, dynamic> data);
  Future<void> logout(String refreshToken);
  Future<PersonModel> getCurrentUser();
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  Future<void> forgotPassword(String phone);
  Future<void> resetPassword(String target, String otpCode, String newPassword);
  Future<void> changePassword(String oldPassword, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final isEmail = identifier.contains('@');
      final response = await dioClient.post(
        ApiConstants.login,
        data: {'username': identifier, 'password': password},
      );

      // Le backend retourne: {success, message, data: {token, refreshToken, type, person}}
      if (response.data['success'] == true) {
        final authData = response.data['data'];
        return {
          'accessToken': authData['token'],
          'refreshToken': authData['refreshToken'],
          'person': authData['person'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Erreur de connexion');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email ou mot de passe incorrect');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: {
          'prenom': data['prenom'],
          'nom': data['nom'],
          'email': data['email'],
          'phone': data['phone'],
          'password': data['password'],
        },
      );

      if (response.data['success'] == true) {
        final authData = response.data['data'];
        return {
          'accessToken': authData['token'],
          'refreshToken': authData['refreshToken'],
          'person': authData['person'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Erreur d\'inscription');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Cet utilisateur existe déjà');
      }
      throw Exception('Erreur d\'inscription: ${e.message}');
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await dioClient.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      // Ignorer les erreurs de logout
      print('Erreur lors de la déconnexion: ${e.message}');
    }
  }

  @override
  Future<PersonModel> getCurrentUser() async {
    try {
      final response = await dioClient.get(ApiConstants.myProfile);

      if (response.data['success'] == true) {
        return PersonModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.data['success'] == true) {
        final authData = response.data['data'];
        return {
          'accessToken': authData['token'],
          'refreshToken': authData['refreshToken'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Token invalide');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de rafraîchissement: ${e.message}');
    }
  }

  @override
  Future<void> forgotPassword(String phone) async {
    try {
      await dioClient.post(ApiConstants.forgotPassword, data: {'phone': phone});
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Aucun compte associé à ce numéro');
      }
      throw Exception('Erreur: ${e.message}');
    }
  }

  @override
  Future<void> resetPassword(
    String target,
    String otpCode,
    String newPassword,
  ) async {
    try {
      await dioClient.post(
        ApiConstants.resetPassword,
        data: {
          'target': target,
          'otpCode': otpCode,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Code OTP invalide ou expiré');
      }
      throw Exception('Erreur: ${e.message}');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await dioClient.post(
        ApiConstants.changePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Ancien mot de passe incorrect');
      }
      throw Exception('Erreur: ${e.message}');
    }
  }
}
