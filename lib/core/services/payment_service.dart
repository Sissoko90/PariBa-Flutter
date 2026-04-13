import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../../di/injection.dart' as di;
import '../constants/api_constants.dart';

class PaymentService {
  static String get _baseUrl => ApiConstants.baseUrl;
  final AuthService _authService;

  PaymentService() : _authService = di.sl<AuthService>();

  /// Déclarer un paiement - CORRIGÉ selon votre API
  Future<Map<String, dynamic>> declarePayment({
    required String groupId,
    required double amount,
    required String paymentType,
    String? transactionRef,
    String? notes,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      // 1. Récupérer l'ID de l'utilisateur connecté
      print('📤 PaymentService - Récupération profil utilisateur');
      final profileResponse = await http.get(
        Uri.parse('$_baseUrl${ApiConstants.myProfile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (profileResponse.statusCode != 200) {
        print('❌ Profile response error: ${profileResponse.statusCode}');
        return {
          'success': false,
          'message': 'Impossible de récupérer votre profil',
        };
      }

      final profileData = jsonDecode(profileResponse.body);
      final String personId = profileData['data']['id'];
      print('📤 PaymentService - ID utilisateur: $personId');

      // 2. Récupérer les contributions en attente du groupe
      final pendingUrl = '$_baseUrl/contributions/group/$groupId/pending';
      print('📤 PaymentService - Appel API: $pendingUrl');

      final contributionsResponse = await http.get(
        Uri.parse(pendingUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        '📥 PaymentService - Réponse contributions: ${contributionsResponse.statusCode}',
      );
      print('📥 PaymentService - Body brut: ${contributionsResponse.body}');

      if (contributionsResponse.statusCode != 200) {
        return {
          'success': false,
          'message': 'Erreur lors du chargement des contributions',
        };
      }

      final contributionsData = jsonDecode(contributionsResponse.body);

      if (contributionsData['success'] != true) {
        return {
          'success': false,
          'message':
              contributionsData['message'] ?? 'Erreur chargement contributions',
        };
      }

      final List<dynamic> contributions = contributionsData['data'] ?? [];
      print(
        '📥 PaymentService - Nombre de contributions: ${contributions.length}',
      );

      if (contributions.isEmpty) {
        return {
          'success': false,
          'message': 'Aucune contribution en attente pour ce groupe',
        };
      }

      // 3. Trouver la contribution de l'utilisateur connecté
      // Note: Dans la réponse, le champ s'appelle "member" pas "group"
      dynamic matchingContribution = null;

      for (var c in contributions) {
        final member = c['member'];
        final memberId = member is Map ? member['id'] : null;
        print('📥 Contribution: ${c['id']}, memberId: $memberId');

        if (memberId == personId) {
          matchingContribution = c;
          print('✅ Contribution trouvée pour cet utilisateur: ${c['id']}');
          break;
        }
      }

      if (matchingContribution == null) {
        print(
          '❌ Aucune contribution trouvée pour l\'utilisateur $personId dans ce groupe',
        );
        return {
          'success': false,
          'message':
              'Vous n\'avez aucune contribution en attente dans ce groupe',
        };
      }

      final contributionId = matchingContribution['id'] as String;
      print('✅ ContributionId sélectionné: $contributionId');

      // 4. Déclarer le paiement
      final body = {
        'contributionId': contributionId,
        'amount': amount,
        'paymentType': paymentType,
        if (transactionRef != null && transactionRef.isNotEmpty)
          'transactionRef': transactionRef,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('📤 PaymentService - Déclaration paiement: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.payments}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 PaymentService - Réponse déclaration: ${response.statusCode}');
      print('📥 PaymentService - Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Paiement déclaré avec succès',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la déclaration',
        };
      }
    } catch (e, stackTrace) {
      print('❌ PaymentService - Erreur: $e');
      print('❌ StackTrace: $stackTrace');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  /// Valider un paiement (admin) - CORRIGÉ
  Future<Map<String, dynamic>> validatePayment({
    required String paymentId,
    required bool confirmed,
    String? notes,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final body = {
        'paymentId': paymentId,
        'confirmed': confirmed,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('📤 PaymentService - Validation paiement: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 PaymentService - Réponse validation: ${response.statusCode}');
      print('📥 PaymentService - Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Paiement validé avec succès',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la validation',
        };
      }
    } catch (e) {
      print('❌ PaymentService - Erreur validation: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  /// Obtenir les paiements d'un groupe - CORRIGÉ
  Future<Map<String, dynamic>> getGroupPayments(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié', 'data': []};
      }

      print('📤 PaymentService - Chargement paiements groupe: $groupId');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/payments/group/$groupId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('TIMEOUT'),
          );

      print('📥 PaymentService - Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Paiements chargés',
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors du chargement des paiements',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ PaymentService - Erreur chargement paiements: $e');

      // Messages d'erreur conviviaux
      String userMessage;
      if (e.toString().contains('TIMEOUT') ||
          e.toString().contains('Connection timed out')) {
        userMessage =
            'Le serveur met trop de temps à répondre. Veuillez réessayer.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection closed') ||
          e.toString().contains('Connection refused')) {
        userMessage =
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      } else if (e.toString().contains('FormatException')) {
        userMessage = 'Erreur de format des données reçues.';
      } else {
        userMessage = 'Une erreur est survenue. Veuillez réessayer.';
      }

      return {'success': false, 'message': userMessage, 'data': []};
    }
  }

  /// Obtenir les paiements en attente (admin) - CORRIGÉ
  Future<Map<String, dynamic>> getPendingPayments(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié', 'data': []};
      }

      print(
        '📤 PaymentService - Chargement paiements en attente groupe: $groupId',
      );

      final response = await http
          .get(
            Uri.parse('$_baseUrl/payments/group/$groupId/pending'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('TIMEOUT'),
          );

      print('📥 PaymentService - Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Paiements en attente chargés',
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors du chargement des paiements',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ PaymentService - Erreur chargement paiements en attente: $e');

      // Messages d'erreur conviviaux
      String userMessage;
      if (e.toString().contains('TIMEOUT') ||
          e.toString().contains('Connection timed out')) {
        userMessage =
            'Le serveur met trop de temps à répondre. Veuillez réessayer.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection closed') ||
          e.toString().contains('Connection refused')) {
        userMessage =
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      } else if (e.toString().contains('FormatException')) {
        userMessage = 'Erreur de format des données reçues.';
      } else {
        userMessage = 'Une erreur est survenue. Veuillez réessayer.';
      }

      return {'success': false, 'message': userMessage, 'data': []};
    }
  }

  /// Obtenir mes paiements en attente (à venir)
  Future<Map<String, dynamic>> getMyPendingPayments() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': true, 'message': 'Non authentifié', 'data': []};
      }

      print('📤 PaymentService - Chargement paiements à venir');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/payments/me/pending'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('TIMEOUT'),
          );

      print(
        '📥 PaymentService - Réponse paiements à venir: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Paiements à venir chargés',
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': true,
          'message': 'Aucun paiement à venir',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ PaymentService - Erreur chargement paiements à venir: $e');
      return {'success': true, 'message': 'Aucun paiement à venir', 'data': []};
    }
  }

  /// Obtenir mes paiements - CORRIGÉ
  Future<Map<String, dynamic>> getMyPayments() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': true, 'message': 'Non authentifié', 'data': []};
      }

      print('📤 PaymentService - Chargement mes paiements');

      // Utiliser directement la méthode par personne qui récupère TOUS les paiements
      return await _getPaymentsByPerson(token);
    } catch (e) {
      print('❌ PaymentService - Erreur chargement mes paiements: $e');
      return {
        'success': true,
        'message': 'Aucun paiement disponible',
        'data': [],
      };
    }
  }

  /// Méthode de secours pour obtenir les paiements par personne
  Future<Map<String, dynamic>> _getPaymentsByPerson(String token) async {
    try {
      // D'abord obtenir l'ID de l'utilisateur
      final userProfileResponse = await http
          .get(
            Uri.parse('$_baseUrl/persons/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('TIMEOUT'),
          );

      if (userProfileResponse.statusCode != 200) {
        return {
          'success': true,
          'message': 'Aucun paiement disponible',
          'data': [],
        };
      }

      final profileData = jsonDecode(userProfileResponse.body);
      final personId = profileData['data']['id'] as String;

      // Maintenant obtenir les paiements de cette personne
      final response = await http
          .get(
            Uri.parse('$_baseUrl/payments/person/$personId'),
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
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Paiements chargés',
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success':
              true, // Retourner success true avec data vide au lieu d'une erreur
          'message': 'Aucun paiement trouvé',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ PaymentService - Erreur _getPaymentsByPerson: $e');

      // Messages d'erreur conviviaux
      if (e.toString().contains('TIMEOUT') ||
          e.toString().contains('Connection timed out')) {
        return {
          'success': true, // Retourner success pour éviter l'erreur rouge
          'message': 'Chargement lent. Veuillez patienter...',
          'data': [],
        };
      } else if (e.toString().contains('SocketException')) {
        return {
          'success': true,
          'message': 'Connexion au serveur impossible',
          'data': [],
        };
      } else {
        return {
          'success': true,
          'message': 'Aucun paiement disponible',
          'data': [],
        };
      }
    }
  }

  /// Obtenir les contributions en attente pour un groupe
  Future<Map<String, dynamic>> getPendingContributions(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié', 'data': []};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/contributions/group/$groupId/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Contributions chargées',
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ PaymentService - Erreur chargement contributions: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
        'data': [],
      };
    }
  }

  /// Compter les paiements en attente de l'utilisateur
  Future<int> countMyPendingPayments() async {
    try {
      final result = await getMyPayments();
      if (result['success'] == true) {
        final payments = result['data'] as List;
        return payments.where((p) => p['status'] == 'PENDING').length;
      }
      return 0;
    } catch (e) {
      print('❌ PaymentService - Erreur comptage paiements en attente: $e');
      return 0;
    }
  }
}
