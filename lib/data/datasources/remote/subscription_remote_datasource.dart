// lib/data/datasources/remote/subscription_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:pariba/core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/subscription_plan_model.dart';
import '../../models/subscription_request_model.dart';
import '../../models/subscription_model.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

class SubscriptionRemoteDataSource {
  final DioClient dioClient;

  SubscriptionRemoteDataSource(this.dioClient);

  /// Récupère tous les plans disponibles
  Future<List<SubscriptionPlanModel>> getPlans() async {
    try {
      _logger.d('📡 GET ${ApiConstants.subscriptions}/plans');
      final response = await dioClient.get(
        '${ApiConstants.subscriptions}/plans',
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        _logger.d('✅ Plans récupérés: ${data.length}');
        return data
            .map((json) => SubscriptionPlanModel.fromJson(json))
            .toList();
      }

      _logger.e('❌ Erreur: ${response.data['message']}');
      throw Exception(
        response.data['message'] ?? 'Erreur lors du chargement des plans',
      );
    } on DioException catch (e) {
      _logger.e('Dio error: ${e.message}');
      _logger.e('Response: ${e.response?.data}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère l'abonnement actif de l'utilisateur
  Future<SubscriptionPlanModel?> getMySubscription() async {
    try {
      _logger.d('📡 GET ${ApiConstants.subscriptions}/me');
      final response = await dioClient.get('${ApiConstants.subscriptions}/me');
      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        // Le backend peut retourner null si pas d'abonnement actif
        if (data == null) {
          _logger.d('ℹ️ Aucun abonnement actif');
          return null;
        }

        // La réponse est un SubscriptionResponse (pas un plan),
        // on construit un SubscriptionPlanModel à partir des champs disponibles
        return SubscriptionPlanModel(
          id: data['id'] ?? '',
          type: data['planType'] ?? 'FREE',
          name: data['planName'] ?? '',
          monthlyPrice: (data['monthlyPrice'] ?? 0).toDouble(),
          annualPrice: null,
          maxGroups: 0,
          canExportPdf: false,
          canExportExcel: false,
          active: data['status'] == 'ACTIVE',
<<<<<<< HEAD
=======
          isActive: data['status'] == 'ACTIVE',
>>>>>>> f6bc8a5 (Sauvegarde avant pull)
        );
      }
      return null;
    } on DioException catch (e) {
      _logger.e('Dio error: ${e.message}');
      if (e.response?.statusCode == 401) return null;
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error in getMySubscription: $e');
      rethrow;
    }
  }

  /// Crée une demande d'abonnement
  Future<SubscriptionRequestModel> requestSubscription({
    required String planId,
    String billingPeriod = 'monthly',
    String? notes,
  }) async {
    final response = await dioClient.post(
      '${ApiConstants.subscriptions}/request',
      data: {
        'planId': planId,
        'billingPeriod': billingPeriod,
        if (notes != null) 'notes': notes,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return SubscriptionRequestModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de la demande');
  }

  /// Liste toutes mes demandes d'abonnement
  Future<List<SubscriptionRequestModel>> getMyRequests() async {
    final response = await dioClient.get(
      '${ApiConstants.subscriptions}/requests',
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data
          .map((json) => SubscriptionRequestModel.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Annule une demande d'abonnement en attente
  Future<void> cancelRequest(String requestId) async {
    final response = await dioClient.post(
      '${ApiConstants.subscriptions}/requests/$requestId/cancel',
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(
        response.data['message'] ?? 'Erreur lors de l\'annulation',
      );
    }
  }

  /// Vérifie l'accès à une fonctionnalité
  Future<bool> checkFeatureAccess(String feature) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.subscriptions}/feature/$feature',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
