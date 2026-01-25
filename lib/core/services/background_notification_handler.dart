import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

/// Handler pour les notifications reçues en background
/// Cette fonction doit être top-level (pas dans une classe)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();

  logger.i('📬 Message reçu en background: ${message.notification?.title}');

  // Traiter le message en background
  // Vous pouvez sauvegarder dans la base de données locale, etc.

  if (message.notification != null) {
    logger.i('Titre: ${message.notification!.title}');
    logger.i('Corps: ${message.notification!.body}');
  }

  if (message.data.isNotEmpty) {
    logger.i('Data: ${message.data}');
  }
}
