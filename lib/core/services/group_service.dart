// core/services/group_service.dart - CORRIGÉ

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../../di/injection.dart' as di; // IMPORT AJOUTÉ
import '../constants/api_constants.dart';

class GroupService {
  static String get _baseUrl => ApiConstants.baseUrl;
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

  /// Rejoindre un groupe via code d'invitation
  Future<Map<String, dynamic>> joinGroup(String invitationCode) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Vous devez être connecté pour rejoindre un groupe',
        };
      }

      print('📤 GroupService - Rejoindre groupe avec code: $invitationCode');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/groups/join'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'invitationCode': invitationCode}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('TIMEOUT');
            },
          );

      print('📥 GroupService - Réponse: ${response.statusCode}');
      print('📥 GroupService - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Demande envoyée avec succès',
          'data': data['data'],
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Code d\'invitation invalide ou expiré',
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'Vous êtes déjà membre de ce groupe',
        };
      } else {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Une erreur est survenue',
          };
        } catch (_) {
          return {'success': false, 'message': 'Une erreur est survenue'};
        }
      }
    } catch (e) {
      print('❌ GroupService - Erreur rejoindre groupe: $e');

      // Messages d'erreur conviviaux
      if (e.toString().contains('TIMEOUT') ||
          e.toString().contains('Connection timed out')) {
        return {
          'success': false,
          'message':
              'Le serveur ne répond pas. Vérifiez votre connexion internet.',
        };
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'message':
              'Impossible de se connecter au serveur. Vérifiez votre connexion.',
        };
      } else if (e.toString().contains('FormatException')) {
        return {
          'success': false,
          'message': 'Erreur de communication avec le serveur.',
        };
      } else {
        return {
          'success': false,
          'message': 'Une erreur inattendue est survenue. Veuillez réessayer.',
        };
      }
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
