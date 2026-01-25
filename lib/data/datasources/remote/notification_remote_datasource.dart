import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/notification_model.dart';

/// Notification Remote DataSource
abstract class NotificationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMyNotifications();
  Future<List<Map<String, dynamic>>> getUnreadNotifications();
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> registerFcmToken(String token);
  Future<void> deleteFcmToken();
  Future<void> deleteNotification(String id);
  Future<void> deleteAllNotifications();
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
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dioClient.get(ApiConstants.notifications);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
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

  @override
  Future<void> registerFcmToken(String token) async {
    try {
      final response = await dioClient.post(
        ApiConstants.registerFcmToken,
        data: {'token': token},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur d\'enregistrement du token FCM: ${e.message}');
    }
  }

  @override
  Future<void> deleteFcmToken() async {
    try {
      final response = await dioClient.delete(ApiConstants.deleteFcmToken);

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de suppression du token FCM: ${e.message}');
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      final response = await dioClient.delete(
        ApiConstants.deleteNotification(id),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de suppression: ${e.message}');
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      final response = await dioClient.delete(
        ApiConstants.deleteAllNotifications,
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de suppression: ${e.message}');
    }
  }
}
