import 'package:url_launcher/url_launcher.dart';

/// Helper pour partager des invitations via différents canaux
class ShareHelper {
  /// Partager via WhatsApp
  static Future<void> shareViaWhatsApp({
    required String phone,
    required String message,
  }) async {
    // Nettoyer le numéro de téléphone
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir WhatsApp');
    }
  }

  /// Partager via SMS
  static Future<void> shareViaSMS({
    required String phone,
    required String message,
  }) async {
    final url = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw Exception('Impossible d\'ouvrir l\'application SMS');
    }
  }

  /// Partager via Email
  static Future<void> shareViaEmail({
    required String email,
    required String subject,
    required String body,
  }) async {
    final url = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw Exception('Impossible d\'ouvrir l\'application Email');
    }
  }

  /// Générer le message d'invitation
  static String generateInvitationMessage({
    required String groupName,
    required String inviterName,
    required String linkCode,
  }) {
    return '''
Bonjour ! 👋

$inviterName vous invite à rejoindre le groupe de tontine "$groupName" sur PariBa.

Pour accepter l'invitation, utilisez ce code : $linkCode

Téléchargez l'application PariBa et entrez ce code pour rejoindre le groupe.

À bientôt ! 🎉
''';
  }
}
