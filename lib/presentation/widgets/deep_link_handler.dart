import 'package:flutter/material.dart';
import '../../core/services/deep_link_service.dart';
import '../../di/injection.dart' as di;
import '../pages/groups/group_join_page.dart';

class DeepLinkHandler extends StatefulWidget {
  final Widget child;

  const DeepLinkHandler({super.key, required this.child});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  late DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    _deepLinkService = di.sl<DeepLinkService>();
    
    // Configurer le callback pour les liens de groupe
    _deepLinkService.onJoinGroupLink = (groupId) {
      _handleJoinGroupLink(groupId);
    };
  }

  void _handleJoinGroupLink(String groupId) {
    // Attendre que le contexte soit disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GroupJoinPage(groupId: groupId),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _deepLinkService.onJoinGroupLink = null;
    super.dispose();
  }
}
