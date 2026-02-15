// core/services/invitation_service.dart - CORRIGÉ

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';
import '../../domain/entities/invitation.dart';
import '../../di/injection.dart' as di;

class InvitationService {
  static String get _baseUrl => ApiConstants.baseUrl;
  final http.Client client;
  AuthService? _authService;

  InvitationService({required this.client});

  // Getter pour obtenir AuthService (initialisation paresseuse)
  AuthService get _getAuthService {
    _authService ??= di.sl<AuthService>();
    return _authService!;
  }

  // Méthode alternative pour les tests
  factory InvitationService.withAuthService({
    required http.Client client,
    required AuthService authService,
  }) {
    return InvitationService(client: client).._authService = authService;
  }

  // Accepter une invitation
  Future<Map<String, dynamic>> acceptInvitation(String linkCode) async {
    try {
      print('🔵 InvitationService - Acceptation code: $linkCode');

      final token = await _getAuthService.getAccessToken();
      if (token == null) {
        print('❌ InvitationService - Non authentifié');
        return {'success': false, 'message': 'Non authentifié'};
      }

      print(
        '🔑 InvitationService - Token utilisé: ${token.substring(0, 20)}...',
      );

      final response = await client.post(
        Uri.parse('$_baseUrl/invitations/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'linkCode': linkCode}),
      );

      print('📥 InvitationService - Réponse status: ${response.statusCode}');
      print('📥 InvitationService - Réponse body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Invitation acceptée',
          'data': data['data'] ?? {},
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Invitation non trouvée ou expirée',
        };
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur serveur',
        };
      }
    } catch (e) {
      print('❌ InvitationService - Erreur acceptation: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  // Récupérer les invitations d'un groupe
  Future<List<Invitation>> getGroupInvitations(String groupId) async {
    try {
      final token = await _getAuthService.getAccessToken();
      if (token == null) {
        print(
          '❌ InvitationService - Non authentifié pour chargement invitations',
        );
        return [];
      }

      final response = await client.get(
        Uri.parse('$_baseUrl/invitations/group/$groupId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> invitations = data['data'] ?? [];
          return invitations.map((json) => Invitation.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ InvitationService - Erreur chargement invitations: $e');
      return [];
    }
  }

  // Inviter un membre
  Future<Map<String, dynamic>> inviteMember({
    required String groupId,
    required String email,
    String? phone,
  }) async {
    try {
      final token = await _getAuthService.getAccessToken();
      if (token == null) {
        print('❌ InvitationService - Non authentifié pour envoi invitation');
        return {'success': false, 'message': 'Non authentifié'};
      }

      print(
        '🔑 InvitationService - Token utilisé: ${token.substring(0, 20)}...',
      );
      print('🔵 InvitationService - Envoi invitation groupe: $groupId');
      print('📧 InvitationService - Email: $email, Phone: $phone');

      final Map<String, dynamic> body = {'groupId': groupId};

      if (email.isNotEmpty) {
        body['targetEmail'] = email;
      }

      if (phone != null && phone.isNotEmpty && phone != '+') {
        body['targetPhone'] = phone;
      }

      print('📤 InvitationService - Body: $body');

      final response = await client.post(
        Uri.parse('$_baseUrl/invitations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 InvitationService - Réponse status: ${response.statusCode}');
      print('📥 InvitationService - Réponse body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Invitation envoyée avec succès',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de l\'envoi de l\'invitation',
        };
      }
    } catch (e) {
      print('❌ InvitationService - Erreur envoi invitation: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }
}
