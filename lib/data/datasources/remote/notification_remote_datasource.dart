import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

/// Notification Remote DataSource
abstract class NotificationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMyNotifications();
  Future<List<Map<String, dynamic>>> getUnreadNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      final response = await dioClient.get(ApiConstants.notifications);

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des notifications: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    try {
      final response = await dioClient.get(ApiConstants.unreadNotifications);

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des notifications: ${e.message}');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final response = await dioClient.put(
        ApiConstants.markNotificationAsRead(id),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de marquage: ${e.message}');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await dioClient.put(ApiConstants.markAllAsRead);

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de marquage: ${e.message}');
    }
  }
}
