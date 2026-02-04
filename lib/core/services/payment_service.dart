import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../../domain/entities/payment.dart';
import '../../di/injection.dart' as di;

class PaymentService {
  static const String _baseUrl = 'http://192.168.100.57:8085/api/v1';
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

      print('📤 PaymentService - Début déclaration paiement groupe: $groupId');

      // ÉTAPE 1: Obtenir les contributions en attente de l'utilisateur
      final contributionsResult = await getMyPendingContributions(groupId);

      if (contributionsResult['success'] != true) {
        return {
          'success': false,
          'message':
              contributionsResult['message'] ??
              'Impossible de récupérer les contributions',
        };
      }

      final contributions = contributionsResult['data'] as List<dynamic>;

      if (contributions.isEmpty) {
        return {
          'success': false,
          'message': 'Aucune contribution en attente trouvée pour ce groupe',
        };
      }

      // Prendre la première contribution en attente
      final firstContribution = contributions[0] as Map<String, dynamic>;
      final contributionId = firstContribution['id'] as String;

      print('📤 PaymentService - Contribution trouvée: $contributionId');
      print('📤 PaymentService - Détails: $firstContribution');

      // ÉTAPE 2: Déclarer le paiement
      final body = {
        'contributionId': contributionId,
        'amount': amount,
        'paymentType': paymentType,
        if (transactionRef != null && transactionRef.isNotEmpty)
          'transactionRef': transactionRef,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('📤 PaymentService - Body paiement: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 PaymentService - Réponse API: ${response.statusCode}');
      print('📥 PaymentService - Body réponse: ${response.body}');

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
    } catch (e) {
      print('❌ PaymentService - Erreur: $e');
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

      final response = await http.get(
        Uri.parse('$_baseUrl/payments/group/$groupId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
          'message': 'Erreur HTTP ${response.statusCode}',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ PaymentService - Erreur chargement paiements: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
        'data': [],
      };
    }
  }

  /// Obtenir les paiements en attente (admin) - CORRIGÉ
  Future<Map<String, dynamic>> getPendingPayments(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié', 'data': []};
      }

      final url = '$_baseUrl/payments/group/$groupId/pending';
      print('🌐 PaymentService - URL: $url');
      print('🌐 PaymentService - Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 PaymentService - Status Code: ${response.statusCode}');
      print('📥 PaymentService - Headers: ${response.headers}');
      print('📥 PaymentService - Body complet: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('📥 PaymentService - Data keys: ${data.keys}');
        print('📥 PaymentService - Success: ${data['success']}');
        print('📥 PaymentService - Message: ${data['message']}');

        if (data['data'] != null) {
          print('📥 PaymentService - Data type: ${data['data'].runtimeType}');
          print(
            '📥 PaymentService - Data length: ${(data['data'] as List).length}',
          );

          if ((data['data'] as List).isNotEmpty) {
            print(
              '📥 PaymentService - Premier élément: ${(data['data'] as List)[0]}',
            );
          }
        }
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Paiements en attente chargés',
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
      print('❌ PaymentService - Erreur chargement paiements en attente: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
        'data': [],
      };
    }
  }

  /// Obtenir mes paiements - CORRIGÉ
  Future<Map<String, dynamic>> getMyPayments() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié', 'data': []};
      }

      print('📤 PaymentService - Chargement mes paiements');

      final response = await http.get(
        Uri.parse('$_baseUrl/payments/me/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 PaymentService - Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Mes paiements chargés',
          'data': data['data'] ?? [],
        };
      } else {
        // Si cette endpoint ne fonctionne pas, utiliser l'endpoint par défaut
        return await _getPaymentsByPerson(token);
      }
    } catch (e) {
      print('❌ PaymentService - Erreur chargement mes paiements: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
        'data': [],
      };
    }
  }

  /// Méthode de secours pour obtenir les paiements par personne
  Future<Map<String, dynamic>> _getPaymentsByPerson(String token) async {
    try {
      // D'abord obtenir l'ID de l'utilisateur
      final userProfileResponse = await http.get(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userProfileResponse.statusCode != 200) {
        return {
          'success': false,
          'message': 'Impossible de récupérer le profil',
          'data': [],
        };
      }

      final profileData = jsonDecode(userProfileResponse.body);
      final personId = profileData['data']['id'] as String;

      // Maintenant obtenir les paiements de cette personne
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/person/$personId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ PaymentService - Erreur _getPaymentsByPerson: $e');
      return {'success': false, 'message': 'Erreur: $e', 'data': []};
    }
  }

  /// Obtenir les contributions en attente pour un groupe
  Future<Map<String, dynamic>> getPendingContributions(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié', 'data': []};
      }

      print(
        '📤 PaymentService - Chargement contributions en attente groupe: $groupId',
      );

      final response = await http.get(
        Uri.parse('$_baseUrl/contributions/group/$groupId/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        '📥 PaymentService - Réponse contributions: ${response.statusCode}',
      );
      print('📥 PaymentService - Body: ${response.body}');

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

  Future<Map<String, dynamic>> getMyPendingContributions(String groupId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié', 'data': []};
      }

      print(
        '📤 PaymentService - Chargement mes contributions en attente groupe: $groupId',
      );

      // Essayer d'abord avec l'endpoint spécifique si disponible
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/contributions/my-contributions?groupId=$groupId&status=PENDING',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        '📥 PaymentService - Réponse mes contributions: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Mes contributions chargées',
          'data': data['data'] ?? [],
        };
      } else {
        // Si ça ne fonctionne pas, utiliser l'endpoint général
        return await getPendingContributions(groupId);
      }
    } catch (e) {
      print('❌ PaymentService - Erreur chargement mes contributions: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
        'data': [],
      };
    }
  }
}
