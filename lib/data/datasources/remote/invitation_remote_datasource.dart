import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

/// Invitation Remote DataSource
abstract class InvitationRemoteDataSource {
  Future<Map<String, dynamic>> inviteMember(String groupId, String phone, String? message);
  Future<void> acceptInvitation(String linkCode);
  Future<List<Map<String, dynamic>>> getGroupInvitations(String groupId);
}

class InvitationRemoteDataSourceImpl implements InvitationRemoteDataSource {
  final DioClient dioClient;

  InvitationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> inviteMember(
    String groupId,
    String phone,
    String? message,
  ) async {
    try {
      final response = await dioClient.post(
        ApiConstants.invitations,
        data: {
          'groupId': groupId,
          'phone': phone,
          if (message != null) 'message': message,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur d\'invitation: ${e.message}');
    }
  }

  @override
  Future<void> acceptInvitation(String linkCode) async {
    try {
      final response = await dioClient.post(
        ApiConstants.acceptInvitation,
        data: {'linkCode': linkCode},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur d\'acceptation: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGroupInvitations(String groupId) async {
    try {
      final response = await dioClient.get(
        ApiConstants.groupInvitations(groupId),
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des invitations: ${e.message}');
    }
  }
}
