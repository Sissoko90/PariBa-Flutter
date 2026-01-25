import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

/// Service de gestion des notifications Firebase Cloud Messaging
class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  // Stream controller pour les notifications reçues
  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get onMessageReceived =>
      _messageStreamController.stream;

  // Callback pour le token FCM
  Function(String)? onTokenRefresh;

  // Callback pour notifier quand une nouvelle notification est reçue
  VoidCallback? _onNewNotificationReceived;

  /// Définir le callback pour les nouvelles notifications
  void setOnNewNotificationCallback(VoidCallback callback) {
    _onNewNotificationReceived = callback;
  }

  /// Initialiser le service Firebase Messaging
  Future<void> initialize() async {
    try {
      _logger.i('🔔 Initialisation de Firebase Messaging...');

      // Demander les permissions de notification
      await _requestPermissions();

      // Initialiser les notifications locales
      await _initializeLocalNotifications();

      // Configurer les handlers de messages
      _configureMessageHandlers();

      // Récupérer le token FCM
      await getToken();

      // Écouter les changements de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _logger.i('🔄 Nouveau token FCM: $newToken');
        onTokenRefresh?.call(newToken);
      });

      _logger.i('✅ Firebase Messaging initialisé avec succès');
    } catch (e) {
      _logger.e('❌ Erreur lors de l\'initialisation de Firebase Messaging: $e');
    }
  }

  /// Demander les permissions de notification
  Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.i('📱 Statut des permissions: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('✅ Permissions de notification accordées');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        _logger.i('⚠️ Permissions provisoires accordées');
      } else {
        _logger.w('❌ Permissions de notification refusées');
      }
    } catch (e) {
      _logger.e('❌ Erreur lors de la demande de permissions: $e');
    }
  }

  /// Initialiser les notifications locales
  Future<void> _initializeLocalNotifications() async {
    try {
      // Créer le canal de notification Android
      if (Platform.isAndroid) {
        const androidChannel = AndroidNotificationChannel(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          description: AppConstants.notificationChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(androidChannel);

        _logger.i('✅ Canal de notification Android créé');
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _logger.i('✅ Notifications locales initialisées');
    } catch (e) {
      _logger.e(
        '❌ Erreur lors de l\'initialisation des notifications locales: $e',
      );
    }
  }

  /// Configurer les handlers de messages
  void _configureMessageHandlers() {
    // Message reçu quand l'app est en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i(
        '📨 Message reçu en foreground: ${message.notification?.title}',
      );
      _messageStreamController.add(message);
      _showLocalNotification(message);

      // Notifier qu'une nouvelle notification est arrivée
      _onNewNotificationReceived?.call();
    });

    // Message reçu quand l'app est en background et l'utilisateur tape dessus
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i(
        '📬 Notification ouverte depuis background: ${message.notification?.title}',
      );
      _messageStreamController.add(message);
      _handleNotificationNavigation(message);
    });

    // Vérifier si l'app a été ouverte depuis une notification
    _checkInitialMessage();
  }

  /// Vérifier si l'app a été ouverte depuis une notification
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _logger.i(
          '🚀 App ouverte depuis une notification: ${initialMessage.notification?.title}',
        );
        _messageStreamController.add(initialMessage);
        _handleNotificationNavigation(initialMessage);
      }
    } catch (e) {
      _logger.e('❌ Erreur lors de la vérification du message initial: $e');
    }
  }

  /// Afficher une notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null) {
        const androidDetails = AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: AppConstants.notificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          notificationDetails,
          payload: message.data.toString(),
        );

        _logger.i('✅ Notification locale affichée');
      }
    } catch (e) {
      _logger.e('❌ Erreur lors de l\'affichage de la notification locale: $e');
    }
  }

  /// Gérer la navigation lors du tap sur une notification
  void _handleNotificationNavigation(RemoteMessage message) {
    // TODO: Implémenter la navigation selon le type de notification
    final data = message.data;
    _logger.i('🔗 Navigation vers: $data');

    // Exemple de navigation selon le type
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'GROUP_INVITATION':
          // Naviguer vers la page des invitations
          break;
        case 'PAYMENT_SUCCESS':
          // Naviguer vers la page des paiements
          break;
        case 'CONTRIBUTION_DUE':
          // Naviguer vers la page des contributions
          break;
        default:
          // Naviguer vers la page des notifications
          break;
      }
    }
  }

  /// Callback quand l'utilisateur tape sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('👆 Notification tapée: ${response.payload}');
    // TODO: Gérer la navigation
  }

  /// Récupérer le token FCM
  Future<String?> getToken() async {
    try {
      String? token;

      if (Platform.isIOS) {
        // Pour iOS, récupérer l'APNs token d'abord
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          token = await _firebaseMessaging.getToken();
        } else {
          _logger.w('⚠️ APNs token non disponible, réessai dans 3 secondes...');
          await Future.delayed(const Duration(seconds: 3));
          token = await _firebaseMessaging.getToken();
        }
      } else {
        token = await _firebaseMessaging.getToken();
      }

      if (token != null) {
        _logger.i('🔑 Token FCM: $token');
        return token;
      } else {
        _logger.w('⚠️ Token FCM non disponible');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Erreur lors de la récupération du token FCM: $e');
      return null;
    }
  }

  /// S'abonner à un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('✅ Abonné au topic: $topic');
    } catch (e) {
      _logger.e('❌ Erreur lors de l\'abonnement au topic $topic: $e');
    }
  }

  /// Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('✅ Désabonné du topic: $topic');
    } catch (e) {
      _logger.e('❌ Erreur lors du désabonnement du topic $topic: $e');
    }
  }

  /// Supprimer le token FCM (lors de la déconnexion)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _logger.i('✅ Token FCM supprimé');
    } catch (e) {
      _logger.e('❌ Erreur lors de la suppression du token FCM: $e');
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    _messageStreamController.close();
  }
}
