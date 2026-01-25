import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_messaging_service.dart';
import '../../data/datasources/remote/notification_remote_datasource.dart';

/// Service de gestion des notifications de l'application
class NotificationService {
  final FirebaseMessagingService _firebaseMessagingService;
  final NotificationRemoteDataSource? _notificationDataSource;
  final Logger _logger = Logger();

  static const String _fcmTokenKey = 'fcm_token';
  static const String _notificationEnabledKey = 'notifications_enabled';

  NotificationService(
    this._firebaseMessagingService, {
    NotificationRemoteDataSource? notificationDataSource,
  }) : _notificationDataSource = notificationDataSource;

  /// Initialiser le service de notifications
  Future<void> initialize() async {
    try {
      _logger.i('🔔 Initialisation du service de notifications...');

      // Initialiser Firebase Messaging
      await _firebaseMessagingService.initialize();

      // Configurer le callback de rafraîchissement du token
      _firebaseMessagingService.onTokenRefresh = _onTokenRefresh;

      // Récupérer et sauvegarder le token initial
      final token = await _firebaseMessagingService.getToken();
      if (token != null) {
        await _saveToken(token);
      }

      _logger.i('✅ Service de notifications initialisé');
    } catch (e) {
      _logger.e(
        '❌ Erreur lors de l\'initialisation du service de notifications: $e',
      );
    }
  }

  /// Callback appelé quand le token FCM est rafraîchi
  Future<void> _onTokenRefresh(String newToken) async {
    try {
      _logger.i('🔄 Rafraîchissement du token FCM');
      await _saveToken(newToken);
      await _sendTokenToBackend(newToken);
    } catch (e) {
      _logger.e('❌ Erreur lors du rafraîchissement du token: $e');
    }
  }

  /// Envoyer le token FCM au backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      if (_notificationDataSource != null) {
        await _notificationDataSource!.registerFcmToken(token);
        _logger.i('✅ Token FCM envoyé au backend');
      }
    } catch (e) {
      _logger.e('❌ Erreur lors de l\'envoi du token au backend: $e');
    }
  }

  /// Enregistrer le token FCM au backend (méthode publique)
  Future<void> registerTokenToBackend() async {
    try {
      _logger.i('🔄 Tentative d\'enregistrement du token FCM au backend...');

      if (_notificationDataSource == null) {
        _logger.w(
          '⚠️ NotificationDataSource est null, impossible d\'enregistrer le token',
        );
        return;
      }

      final token = await getCurrentToken();
      _logger.i('🔑 Token récupéré: ${token?.substring(0, 20)}...');

      if (token != null) {
        await _sendTokenToBackend(token);
      } else {
        _logger.w('⚠️ Aucun token FCM disponible');
      }
    } catch (e) {
      _logger.e('❌ Erreur lors de l\'enregistrement du token: $e');
    }
  }

  /// Sauvegarder le token FCM localement
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);
      _logger.i('💾 Token FCM sauvegardé localement');
    } catch (e) {
      _logger.e('❌ Erreur lors de la sauvegarde du token: $e');
    }
  }

  /// Récupérer le token FCM sauvegardé
  Future<String?> getSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_fcmTokenKey);
    } catch (e) {
      _logger.e('❌ Erreur lors de la récupération du token sauvegardé: $e');
      return null;
    }
  }

  /// Récupérer le token FCM actuel
  Future<String?> getCurrentToken() async {
    return await _firebaseMessagingService.getToken();
  }

  /// Activer les notifications
  Future<void> enableNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, true);
      _logger.i('✅ Notifications activées');
    } catch (e) {
      _logger.e('❌ Erreur lors de l\'activation des notifications: $e');
    }
  }

  /// Désactiver les notifications
  Future<void> disableNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, false);
      _logger.i('❌ Notifications désactivées');
    } catch (e) {
      _logger.e('❌ Erreur lors de la désactivation des notifications: $e');
    }
  }

  /// Vérifier si les notifications sont activées
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationEnabledKey) ?? true;
    } catch (e) {
      _logger.e(
        '❌ Erreur lors de la vérification du statut des notifications: $e',
      );
      return true;
    }
  }

  /// S'abonner à un topic (ex: groupe spécifique)
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessagingService.subscribeToTopic(topic);
  }

  /// Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessagingService.unsubscribeFromTopic(topic);
  }

  /// S'abonner aux notifications d'un groupe
  Future<void> subscribeToGroup(String groupId) async {
    await subscribeToTopic('group_$groupId');
  }

  /// Se désabonner des notifications d'un groupe
  Future<void> unsubscribeFromGroup(String groupId) async {
    await unsubscribeFromTopic('group_$groupId');
  }

  /// Supprimer le token (lors de la déconnexion)
  Future<void> clearToken() async {
    try {
      await _firebaseMessagingService.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);
      _logger.i('✅ Token FCM supprimé');
    } catch (e) {
      _logger.e('❌ Erreur lors de la suppression du token: $e');
    }
  }

  /// Stream des messages reçus
  Stream<dynamic> get onMessageReceived =>
      _firebaseMessagingService.onMessageReceived;

  /// Nettoyer les ressources
  void dispose() {
    _firebaseMessagingService.dispose();
  }
}
