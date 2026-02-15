import 'package:dio/dio.dart';
import '../../models/join_request_model.dart';
import '../../models/group_share_link_model.dart';
import '../../../core/network/dio_client.dart';

abstract class JoinRequestRemoteDataSource {
  Future<JoinRequestModel> createJoinRequest({
    required String groupId,
    String? message,
  });

  Future<JoinRequestModel> reviewJoinRequest({
    required String requestId,
    required String action, // APPROVE ou REJECT
    String? note,
  });

  Future<void> cancelJoinRequest(String requestId);

  Future<List<JoinRequestModel>> getGroupJoinRequests(String groupId);

  Future<List<JoinRequestModel>> getMyJoinRequests();

  Future<int> getPendingJoinRequestsCount(String groupId);

  Future<GroupShareLinkModel> generateShareLink(String groupId);
}

class JoinRequestRemoteDataSourceImpl implements JoinRequestRemoteDataSource {
  final DioClient dioClient;

  JoinRequestRemoteDataSourceImpl(this.dioClient);

  @override
  Future<JoinRequestModel> createJoinRequest({
    required String groupId,
    String? message,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '/join-requests',
        data: {'groupId': groupId, if (message != null) 'message': message},
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return JoinRequestModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<JoinRequestModel> reviewJoinRequest({
    required String requestId,
    required String action,
    String? note,
  }) async {
    try {
      final response = await dioClient.dio.put(
        '/join-requests/$requestId/review',
        data: {'action': action, if (note != null) 'note': note},
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return JoinRequestModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> cancelJoinRequest(String requestId) async {
    try {
      await dioClient.dio.delete('/join-requests/$requestId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<JoinRequestModel>> getGroupJoinRequests(String groupId) async {
    try {
      final response = await dioClient.dio.get('/join-requests/group/$groupId');

      final data = response.data['data'] as List;
      return data.map((json) => JoinRequestModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<JoinRequestModel>> getMyJoinRequests() async {
    try {
      final response = await dioClient.dio.get('/join-requests/my-requests');

      final data = response.data['data'] as List;
      return data.map((json) => JoinRequestModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<int> getPendingJoinRequestsCount(String groupId) async {
    try {
      final response = await dioClient.dio.get(
        '/join-requests/group/$groupId/pending-count',
      );

      return response.data['data'] as int;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<GroupShareLinkModel> generateShareLink(String groupId) async {
    try {
      final response = await dioClient.dio.get('/groups/$groupId/share-link');

      final data = response.data['data'] as Map<String, dynamic>;
      return GroupShareLinkModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final errorData = e.response!.data as Map<String, dynamic>;
      return errorData['message'] as String? ?? 'Une erreur est survenue';
    }
    return e.message ?? 'Une erreur est survenue';
  }
}
