import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class SubscriptionRemoteDataSource {
  final Dio dio;

  SubscriptionRemoteDataSource(this.dio);

  Future<Map<String, dynamic>?> getMySubscription() async {
    final response = await dio.get('/subscriptions/me');

    if (response.statusCode == 200) {
      return response.data['data'];
    }
    return null;
  }

  Future<void> subscribe(String planId) async {
    await dio.post('/subscriptions/subscribe/$planId');
  }

  Future<void> cancel() async {
    await dio.post('/subscriptions/cancel');
  }
}
