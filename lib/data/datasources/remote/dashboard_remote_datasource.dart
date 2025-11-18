import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

/// Dashboard Remote DataSource
abstract class DashboardRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardSummary();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await dioClient.get(ApiConstants.dashboardSummary);

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du dashboard: ${e.message}');
    }
  }
}
