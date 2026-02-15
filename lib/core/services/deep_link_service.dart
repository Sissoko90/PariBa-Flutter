import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';

class DeepLinkService {
  StreamSubscription? _linkSubscription;
  Function(String groupId)? onJoinGroupLink;

  Future<void> initialize() async {
    // Gérer le lien initial (si l'app est ouverte via un lien)
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } on PlatformException catch (e) {
      // Gérer l'erreur silencieusement (plugin non initialisé)
      print('⚠️ Deep linking non disponible: ${e.message}');
    } catch (e) {
      // Autres erreurs
      print('⚠️ Erreur deep linking: $e');
    }

    // Écouter les liens entrants (si l'app est déjà ouverte)
    try {
      _linkSubscription = linkStream.listen(
        (String? link) {
          if (link != null) {
            _handleDeepLink(link);
          }
        },
        onError: (err) {
          // Gérer l'erreur silencieusement
          print('⚠️ Erreur stream deep linking: $err');
        },
      );
    } catch (e) {
      print('⚠️ Impossible d\'écouter les deep links: $e');
    }
  }

  void _handleDeepLink(String link) {
    print('🔗 Deep link reçu: $link');

    final uri = Uri.parse(link);
    String? groupId;

    // Format 1: pariba://join-group/{groupId}
    if (uri.scheme == 'pariba' && uri.host == 'join-group') {
      groupId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }
    // Format 2: https://pariba.app/j/{groupId}
    else if (uri.scheme == 'https' &&
        uri.host == 'pariba.app' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'j' &&
        uri.pathSegments.length > 1) {
      groupId = uri.pathSegments[1];
    }

    if (groupId != null && onJoinGroupLink != null) {
      print('✅ Redirection vers le groupe: $groupId');
      onJoinGroupLink!(groupId);
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
