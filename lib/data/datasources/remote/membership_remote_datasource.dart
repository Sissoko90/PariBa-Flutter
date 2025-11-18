import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

/// Membership Remote DataSource
abstract class MembershipRemoteDataSource {
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId);
  Future<Map<String, dynamic>> getMemberByGroupAndPerson(String groupId, String personId);
  Future<List<Map<String, dynamic>>> getMyMemberships();
  Future<Map<String, dynamic>> updateMemberRole(String groupId, String personId, String newRole);
  Future<Map<String, dynamic>> promoteMember(String groupId, String personId);
  Future<Map<String, dynamic>> demoteMember(String groupId, String personId);
  Future<void> removeMember(String groupId, String personId);
}

class MembershipRemoteDataSourceImpl implements MembershipRemoteDataSource {
  final DioClient dioClient;

  MembershipRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final response = await dioClient.get(
        ApiConstants.groupMembers(groupId),
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des membres: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMemberByGroupAndPerson(
    String groupId,
    String personId,
  ) async {
    try {
      final response = await dioClient.get(
        ApiConstants.memberByGroupAndPerson(groupId, personId),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du membre: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMyMemberships() async {
    try {
      final response = await dioClient.get(ApiConstants.myMemberships);

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des appartenances: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> updateMemberRole(
    String groupId,
    String personId,
    String newRole,
  ) async {
    try {
      final response = await dioClient.put(
        ApiConstants.updateMemberRole,
        data: {
          'groupId': groupId,
          'personId': personId,
          'newRole': newRole,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de modification du rôle: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> promoteMember(
    String groupId,
    String personId,
  ) async {
    try {
      final response = await dioClient.put(
        ApiConstants.promoteMember(groupId, personId),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de promotion: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> demoteMember(
    String groupId,
    String personId,
  ) async {
    try {
      final response = await dioClient.put(
        ApiConstants.demoteMember(groupId, personId),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de rétrogradation: ${e.message}');
    }
  }

  @override
  Future<void> removeMember(String groupId, String personId) async {
    try {
      final response = await dioClient.delete(
        ApiConstants.removeMember(groupId, personId),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de suppression du membre: ${e.message}');
    }
  }
}
