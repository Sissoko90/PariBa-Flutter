import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

/// Tour Remote DataSource
abstract class TourRemoteDataSource {
  Future<Map<String, dynamic>> getTourById(String id);
  Future<List<Map<String, dynamic>>> getToursByGroup(String groupId);
  Future<Map<String, dynamic>> getCurrentTour(String groupId);
  Future<Map<String, dynamic>> getNextTour(String groupId);
  Future<List<Map<String, dynamic>>> generateTours(
    String groupId,
    bool shuffle, {
    List<String>? customBeneficiaryOrder,
  });
}

class TourRemoteDataSourceImpl implements TourRemoteDataSource {
  final DioClient dioClient;

  TourRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> getTourById(String id) async {
    try {
      final response = await dioClient.get(ApiConstants.tourById(id));

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du tour: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getToursByGroup(String groupId) async {
    try {
      final response = await dioClient.get(ApiConstants.toursByGroup(groupId));

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des tours: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentTour(String groupId) async {
    try {
      final response = await dioClient.get(ApiConstants.currentTour(groupId));

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du tour actuel: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getNextTour(String groupId) async {
    try {
      final response = await dioClient.get(ApiConstants.nextTour(groupId));

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du prochain tour: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> generateTours(
    String groupId,
    bool shuffle, {
    List<String>? customBeneficiaryOrder,
  }) async {
    try {
      final data = {
        'groupId': groupId,
        'shuffle': shuffle,
        if (customBeneficiaryOrder != null)
          'customBeneficiaryOrder': customBeneficiaryOrder,
      };

      final response = await dioClient.post(
        ApiConstants.generateTours,
        data: data,
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Erreur lors de la génération des tours',
        );
      }
    } on DioException catch (e) {
      throw Exception('Erreur de génération des tours: ${e.message}');
    }
  }
}
