import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/tontine_group_model.dart';

/// Group Remote DataSource
abstract class GroupRemoteDataSource {
  Future<List<TontineGroupModel>> getGroups(String personId);
  Future<TontineGroupModel> getGroupById(String groupId);
  Future<TontineGroupModel> createGroup(Map<String, dynamic> data);
  Future<TontineGroupModel> updateGroup(
    String groupId,
    Map<String, dynamic> data,
  );
  Future<void> deleteGroup(String groupId);
  Future<void> leaveGroup(String groupId);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final DioClient dioClient;

  GroupRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<TontineGroupModel>> getGroups(String personId) async {
    try {
      final response = await dioClient.get(ApiConstants.myGroups);

      if (response.data['success'] == true) {
        final groupsList = response.data['data'] as List;

        // 🔍 DEBUG: Vérifier si currentUserRole est présent
        if (groupsList.isNotEmpty) {
          print('🔍 DEBUG - Premier groupe reçu: ${groupsList[0]}');
          print(
            '🔍 DEBUG - currentUserRole présent? ${groupsList[0].containsKey('currentUserRole')}',
          );
          print(
            '🔍 DEBUG - currentUserRole value: ${groupsList[0]['currentUserRole']}',
          );
        }

        return groupsList
            .map((json) => TontineGroupModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des groupes: ${e.message}');
    }
  }

  @override
  Future<TontineGroupModel> getGroupById(String groupId) async {
    try {
      final response = await dioClient.get(ApiConstants.groupById(groupId));

      if (response.data['success'] == true) {
        return TontineGroupModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du groupe: ${e.message}');
    }
  }

  @override
  Future<TontineGroupModel> createGroup(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(ApiConstants.groups, data: data);

      if (response.data['success'] == true) {
        return TontineGroupModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de création du groupe: ${e.message}');
    }
  }

  @override
  Future<TontineGroupModel> updateGroup(
    String groupId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dioClient.put(
        ApiConstants.groupById(groupId),
        data: data,
      );

      if (response.data['success'] == true) {
        return TontineGroupModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      // Extraire le message d'erreur du backend si disponible
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Erreur de mise à jour du groupe: ${e.message}');
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      final response = await dioClient.delete(ApiConstants.groupById(groupId));

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      // Extraire le message d'erreur du backend si disponible
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Erreur de suppression du groupe: ${e.message}');
    }
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    try {
      final response = await dioClient.post(ApiConstants.leaveGroup(groupId));

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      // Extraire le message d'erreur du backend si disponible
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Erreur pour quitter le groupe: ${e.message}');
    }
  }
}
