// core/services/group_service.dart - CORRIGÉ

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../../di/injection.dart' as di; // IMPORT AJOUTÉ

class GroupService {
  static const String _baseUrl = 'http://192.168.100.57:8082/api/v1';
  final AuthService _authService;

  // Option 1: Constructeur avec injection
  GroupService({required AuthService authService}) : _authService = authService;

  // Option 2: Constructeur par défaut
  factory GroupService.create() {
    return GroupService(authService: di.sl<AuthService>());
  }

  /// Obtenir les groupes de l'utilisateur
  Future<List<dynamic>> getUserGroups() async {
    try {
      final token = await _authService
          .getAccessToken(); // CHANGÉ: _authService au lieu de AuthService
      if (token == null) {
        print('❌ GroupService - Non authentifié');
        throw Exception('Non authentifié');
      }

      print('🔵 GroupService - Récupération des groupes');

      final response = await http.get(
        Uri.parse('$_baseUrl/groups/my-groups'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 GroupService - Réponse status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final groups = data['data'] ?? [];
          print('✅ GroupService - ${groups.length} groupes récupérés');
          return groups;
        }
      } else {
        print('❌ GroupService - Erreur HTTP: ${response.statusCode}');
        print('❌ GroupService - Body: ${response.body}');
      }

      return [];
    } catch (e) {
      print('❌ GroupService - Erreur chargement groupes: $e');
      return [];
    }
  }

  /// Obtenir les détails d'un groupe spécifique
  Future<Map<String, dynamic>?> getGroupDetails(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.get(
        Uri.parse('$_baseUrl/groups/$groupId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('❌ GroupService - Erreur détails groupe: $e');
      return null;
    }
  }

  /// Créer un nouveau groupe
  Future<Map<String, dynamic>> createGroup({
    required String nom,
    required double montant,
    required String frequency,
    required String rotationMode,
    required String startDate,
    String? description,
    double? latePenaltyAmount,
    int? graceDays,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Non authentifié');

      final body = {
        'nom': nom,
        'montant': montant,
        'frequency': frequency,
        'rotationMode': rotationMode,
        'startDate': startDate,
        if (description != null) 'description': description,
        if (latePenaltyAmount != null) 'latePenaltyAmount': latePenaltyAmount,
        if (graceDays != null) 'graceDays': graceDays,
      };

      print('📤 GroupService - Création groupe: $nom');

      final response = await http.post(
        Uri.parse('$_baseUrl/groups'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ GroupService - Groupe créé avec succès');
          return {
            'success': true,
            'message': data['message'] ?? 'Groupe créé avec succès',
            'data': data['data'],
          };
        }
      }

      return {
        'success': false,
        'message': 'Erreur lors de la création du groupe',
      };
    } catch (e) {
      print('❌ GroupService - Erreur création groupe: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  /// Quitter un groupe
  Future<Map<String, dynamic>> leaveGroup(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.delete(
        Uri.parse('$_baseUrl/groups/$groupId/leave'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Vous avez quitté le groupe',
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de la sortie du groupe',
      };
    } catch (e) {
      print('❌ GroupService - Erreur sortie groupe: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }
}
