import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/error_message_mapper.dart';
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
        final errorMessage = response.data['message'] ?? 'Erreur de connexion';
        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String errorMessage = 'Erreur de connexion';
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        if (statusCode == 401) {
          throw Exception('Email/téléphone ou mot de passe incorrect');
        }

        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'La connexion a pris trop de temps. Vérifiez votre connexion internet',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet',
        );
      }

      throw Exception(
        'Une erreur de connexion s\'est produite. Veuillez réessayer',
      );
    } catch (e) {
      throw Exception(ErrorMessageMapper.extractFriendlyMessage(e));
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
        // Extraire le message d'erreur du backend
        final errorMessage =
            response.data['message'] ?? 'Erreur d\'inscription';
        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }
    } on DioException catch (e) {
      // Gérer les différents codes d'erreur HTTP
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Extraire le message d'erreur du backend si disponible
        String errorMessage = 'Erreur d\'inscription';

        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        // Mapper selon le code HTTP
        switch (statusCode) {
          case 400:
            // Erreur de validation
            throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
          case 409:
            // Conflit - utilisateur existe déjà
            throw Exception(
              'Un compte avec cet email ou ce numéro de téléphone existe déjà',
            );
          case 422:
            // Erreur de validation détaillée
            throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
          case 500:
            throw Exception(
              'Une erreur s\'est produite sur le serveur. Veuillez réessayer plus tard',
            );
          default:
            throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
        }
      }

      // Erreur réseau ou timeout
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'La connexion a pris trop de temps. Vérifiez votre connexion internet',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet',
        );
      }

      throw Exception('Une erreur s\'est produite. Veuillez réessayer');
    } catch (e) {
      // Erreur inattendue
      throw Exception(ErrorMessageMapper.extractFriendlyMessage(e));
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
