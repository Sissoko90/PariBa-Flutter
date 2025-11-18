import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/person_model.dart';

/// Person Remote DataSource
abstract class PersonRemoteDataSource {
  Future<PersonModel> getMyProfile();
  Future<PersonModel> getPersonById(String id);
  Future<PersonModel> updateProfile(Map<String, dynamic> data);
  Future<PersonModel> uploadPhoto(String filePath);
  Future<void> deletePhoto();
  Future<void> deleteAccount();
  Future<Map<String, dynamic>> getMyStatistics();
}

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  final DioClient dioClient;

  PersonRemoteDataSourceImpl(this.dioClient);

  @override
  Future<PersonModel> getMyProfile() async {
    try {
      final response = await dioClient.get(ApiConstants.myProfile);

      if (response.data['success'] == true) {
        return PersonModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du profil: ${e.message}');
    }
  }

  @override
  Future<PersonModel> getPersonById(String id) async {
    try {
      final response = await dioClient.get(
        ApiConstants.personById(id),
      );

      if (response.data['success'] == true) {
        return PersonModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du profil: ${e.message}');
    }
  }

  @override
  Future<PersonModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        ApiConstants.myProfile,
        data: data,
      );

      if (response.data['success'] == true) {
        return PersonModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de mise à jour du profil: ${e.message}');
    }
  }

  @override
  Future<PersonModel> uploadPhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await dioClient.post(
        ApiConstants.uploadPhoto,
        data: formData,
      );

      if (response.data['success'] == true) {
        return PersonModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur d\'upload de photo: ${e.message}');
    }
  }

  @override
  Future<void> deletePhoto() async {
    try {
      final response = await dioClient.delete(ApiConstants.deletePhoto);

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de suppression de photo: ${e.message}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final response = await dioClient.delete(ApiConstants.deleteAccount);

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de suppression du compte: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMyStatistics() async {
    try {
      final response = await dioClient.get(ApiConstants.myStatistics);

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des statistiques: ${e.message}');
    }
  }
}
