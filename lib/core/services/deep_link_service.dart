import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  StreamSubscription? _linkSubscription;
  Function(String groupId)? onJoinGroupLink;

  final AppLinks _appLinks = AppLinks();

  Future<void> initialize() async {
    // Gérer le lien initial (si l'app est ouverte via un lien)
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('⚠️ Deep linking non disponible: $e');
    }

    // Écouter les liens entrants (si l'app est déjà ouverte)
    try {
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _handleDeepLink(uri);
        },
        onError: (err) {
          print('⚠️ Erreur stream deep linking: $err');
        },
      );
    } catch (e) {
      print('⚠️ Impossible d\'écouter les deep links: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    print('🔗 Deep link reçu: $uri');

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
