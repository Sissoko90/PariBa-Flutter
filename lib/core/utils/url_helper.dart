// core/utils/url_helper.dart
class UrlHelper {
  static const String baseIp = '192.168.100.57'; // Votre IP

  // Votre IP

  static String fixPhotoUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Remplacer localhost par l'IP réelle
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', baseIp);
    }

    // Remplacer 192.168.100.198 (Android emulator) par l'IP si nécessaire
    if (url.contains('192.168.100.198')) {
      return url.replaceAll('192.168.100.198', baseIp);
    }

    return url;
  }
}
