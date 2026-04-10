import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/error_message_mapper.dart';
import '../../models/person_model.dart';

/// Request DTO for registration
class RegisterRequest {
  final String prenom;
  final String nom;
  final String email;
  final String phone;
  final String password;
  final String? photo;

  RegisterRequest({
    required this.prenom,
    required this.nom,
    required this.email,
    required this.phone,
    required this.password,
    this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'phone': phone,
      'password': password,
      if (photo != null) 'photo': photo,
    };
  }
}

/// Auth Remote DataSource
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(
    String identifier,
    String password,
    String otpCode,
  );

  Future<Map<String, dynamic>> register(RegisterRequest request);

  Future<void> sendOtp(String target, {String? channel});

  Future<bool> verifyOtp(String target, String code);

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
  Future<Map<String, dynamic>> login(
    String identifier,
    String password,
    String otpCode,
  ) async {
    try {
      final response = await dioClient.post(
        ApiConstants.login,
        data: {
          'username': identifier,
          'password': password,
          'otpCode': otpCode, // ⚠️ OTP OBLIGATOIRE
        },
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
          throw Exception(
            'Email/téléphone, mot de passe ou code OTP incorrect',
          );
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
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        final authData = response.data['data'];
        return {
          'accessToken': authData['token'],
          'refreshToken': authData['refreshToken'],
          'person': authData['person'],
        };
      } else {
        final errorMessage =
            response.data['message'] ?? 'Erreur d\'inscription';
        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String errorMessage = 'Erreur d\'inscription';

        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        switch (statusCode) {
          case 400:
            throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
          case 409:
            throw Exception(
              'Un compte avec cet email ou ce numéro de téléphone existe déjà',
            );
          case 422:
            throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
          case 500:
            throw Exception(
              'Une erreur s\'est produite sur le serveur. Veuillez réessayer plus tard',
            );
          default:
            throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
        }
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

      throw Exception('Une erreur s\'est produite. Veuillez réessayer');
    } catch (e) {
      throw Exception(ErrorMessageMapper.extractFriendlyMessage(e));
    }
  }

  @override
  Future<void> sendOtp(String target, {String? channel}) async {
    try {
      final Map<String, dynamic> data = {'target': target};

      if (channel != null && channel.isNotEmpty) {
        data['channel'] = channel.toUpperCase();
      }

      final response = await dioClient.post(ApiConstants.sendOtp, data: data);

      if (response.data['success'] != true) {
        final errorMessage =
            response.data['message'] ?? 'Erreur lors de l\'envoi du code OTP';
        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String errorMessage = 'Erreur lors de l\'envoi du code OTP';
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        if (statusCode == 404) {
          throw Exception('Aucun compte associé à ce numéro ou email');
        }

        if (statusCode == 429) {
          throw Exception(
            'Trop de tentatives. Veuillez patienter quelques minutes',
          );
        }

        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('La connexion a pris trop de temps');
      }

      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception(ErrorMessageMapper.extractFriendlyMessage(e));
    }
  }

  @override
  Future<bool> verifyOtp(String target, String code) async {
    try {
      final response = await dioClient.post(
        ApiConstants.verifyOtp,
        data: {'target': target, 'code': code},
      );

      if (response.data['success'] == true) {
        return response.data['data'] ?? true;
      } else {
        final errorMessage = response.data['message'] ?? 'Code OTP invalide';
        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String errorMessage = 'Code OTP invalide ou expiré';
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        if (statusCode == 400) {
          throw Exception('Code OTP invalide ou expiré');
        }

        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }

      throw Exception('Erreur de vérification: ${e.message}');
    } catch (e) {
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
      final response = await dioClient.post(
        ApiConstants.forgotPassword,
        data: {'phone': phone},
      );

      if (response.data['success'] != true) {
        final errorMessage =
            response.data['message'] ?? 'Erreur lors de l\'envoi du code';
        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }
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
      final response = await dioClient.post(
        ApiConstants.resetPassword,
        data: {
          'target': target,
          'otpCode': otpCode,
          'newPassword': newPassword,
        },
      );

      if (response.data['success'] != true) {
        final errorMessage =
            response.data['message'] ?? 'Erreur lors de la réinitialisation';
        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }
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
      final response = await dioClient.post(
        ApiConstants.changePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );

      if (response.data['success'] != true) {
        final errorMessage =
            response.data['message'] ??
            'Erreur lors du changement de mot de passe';
        throw Exception(ErrorMessageMapper.mapErrorMessage(errorMessage));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Ancien mot de passe incorrect');
      }
      throw Exception('Erreur: ${e.message}');
    }
  }
}
