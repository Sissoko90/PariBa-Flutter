import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../di/injection.dart' as di;
import '../../models/contribution_model.dart';

abstract class ContributionRemoteDataSource {
  Future<List<ContributionModel>> getContributionsByGroup(String groupId);
  Future<List<ContributionModel>> getContributionsByTour(String tourId);
  Future<List<ContributionModel>> getContributionsByMember(String memberId);
  Future<ContributionModel> getContributionById(String contributionId);
  Future<List<ContributionModel>> getPendingContributions(String groupId);
}

class ContributionRemoteDataSourceImpl implements ContributionRemoteDataSource {
  final AuthService _authService = di.sl<AuthService>();
  static String get _baseUrl => ApiConstants.baseUrl;

  @override
  Future<List<ContributionModel>> getContributionsByGroup(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/contributions/group/$groupId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('TIMEOUT'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> contributionsJson = data['data'] ?? [];
        return contributionsJson
            .map((json) => ContributionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de chargement des contributions: $e');
    }
  }

  @override
  Future<List<ContributionModel>> getContributionsByTour(String tourId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/contributions/tour/$tourId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('TIMEOUT'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> contributionsJson = data['data'] ?? [];
        return contributionsJson
            .map((json) => ContributionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de chargement des contributions: $e');
    }
  }

  @override
  Future<List<ContributionModel>> getContributionsByMember(String memberId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/contributions/member/$memberId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('TIMEOUT'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> contributionsJson = data['data'] ?? [];
        return contributionsJson
            .map((json) => ContributionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de chargement des contributions: $e');
    }
  }

  @override
  Future<ContributionModel> getContributionById(String contributionId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/contributions/$contributionId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('TIMEOUT'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ContributionModel.fromJson(data['data']);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de chargement de la contribution: $e');
    }
  }

  @override
  Future<List<ContributionModel>> getPendingContributions(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/contributions/group/$groupId/pending'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('TIMEOUT'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> contributionsJson = data['data'] ?? [];
        return contributionsJson
            .map((json) => ContributionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de chargement des contributions: $e');
    }
  }
}
