// core/utils/url_helper.dart
class UrlHelper {
  static const String baseIp = '192.168.100.57'; // Votre IP

  static String fixPhotoUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Remplacer localhost par l'IP réelle
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', baseIp);
    }

    // Remplacer 10.0.2.2 (Android emulator) par l'IP si nécessaire
    if (url.contains('10.0.2.2')) {
      return url.replaceAll('10.0.2.2', baseIp);
    }

    return url;
  }
}
