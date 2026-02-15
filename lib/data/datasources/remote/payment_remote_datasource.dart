import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

/// Payment Remote DataSource
abstract class PaymentRemoteDataSource {
  Future<Map<String, dynamic>> makePayment({
    required String contributionId,
    required double amount,
    required String paymentType,
    String? externalRef,
  });
  Future<Map<String, dynamic>> getPaymentById(String id);
  Future<List<Map<String, dynamic>>> getPaymentsByContribution(
    String contributionId,
  );
  Future<List<Map<String, dynamic>>> getPaymentsByPerson(String personId);
  Future<void> verifyPayment(String id);
  Future<List<Map<String, dynamic>>> getPaymentHistory(String groupId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final DioClient dioClient;

  PaymentRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> makePayment({
    required String contributionId,
    required double amount,
    required String paymentType,
    String? externalRef,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.payments,
        data: {
          'contributionId': contributionId,
          'amount': amount,
          'paymentType': paymentType,
          if (externalRef != null) 'externalRef': externalRef,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de paiement: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPaymentById(String id) async {
    try {
      final response = await dioClient.get(ApiConstants.paymentById(id));

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du paiement: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentsByContribution(
    String contributionId,
  ) async {
    try {
      final response = await dioClient.get(
        ApiConstants.paymentsByContribution(contributionId),
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des paiements: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentsByPerson(
    String personId,
  ) async {
    try {
      final response = await dioClient.get(
        ApiConstants.paymentsByPerson(personId),
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des paiements: ${e.message}');
    }
  }

  @override
  Future<void> verifyPayment(String id) async {
    try {
      final response = await dioClient.post(ApiConstants.verifyPayment(id));

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de vérification: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentHistory(String groupId) async {
    try {
      final response = await dioClient.get(
        ApiConstants.paymentHistory(groupId),
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération de l\'historique: ${e.message}');
    }
  }
}
