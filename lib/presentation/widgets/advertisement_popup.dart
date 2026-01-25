import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/advertisement_model.dart';
import '../../core/theme/app_colors.dart';

/// Widget pour afficher une publicité en popup (dialog)
class AdvertisementPopup extends StatefulWidget {
  final AdvertisementModel advertisement;
  final VoidCallback onClose;
  final VoidCallback? onImpression;
  final VoidCallback? onClick;

  const AdvertisementPopup({
    super.key,
    required this.advertisement,
    required this.onClose,
    this.onImpression,
    this.onClick,
  });

  @override
  State<AdvertisementPopup> createState() => _AdvertisementPopupState();
}

class _AdvertisementPopupState extends State<AdvertisementPopup> {
  bool _impressionRecorded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordImpression();
    });
  }

  void _recordImpression() {
    if (!_impressionRecorded) {
      _impressionRecorded = true;
      widget.onImpression?.call();
      print(
        '👁️ [POPUP] Impression enregistrée pour: ${widget.advertisement.id}',
      );
    }
  }

  // Clic sur l'image : enregistrer le clic uniquement
  void _handleImageClick() {
    print('🔥 [POPUP] Clic sur l\'image pour: ${widget.advertisement.id}');
    widget.onClick?.call();
    print('� [POPUP] Clic enregistré pour: ${widget.advertisement.id}');
  }

  // Clic sur "En savoir plus" : ouvrir le lien externe uniquement
  Future<void> _openExternalLink() async {
    print(
      '🌐 [POPUP] Ouverture du lien externe: ${widget.advertisement.linkUrl}',
    );
    if (widget.advertisement.linkUrl != null &&
        widget.advertisement.linkUrl!.isNotEmpty) {
      await _launchUrl(widget.advertisement.linkUrl!);
      widget.onClose();
    } else {
      print('⚠️ [POPUP] Pas de lien à ouvrir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    print('🏗️ [POPUP] Build - linkUrl: ${widget.advertisement.linkUrl}');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 360,
          maxHeight: screenHeight * 0.65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Stack(
              children: [
                GestureDetector(
                  onTap: _handleImageClick,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.advertisement.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 36),
                      ),
                    ),
                  ),
                ),
                // Bouton fermer
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: widget.onClose,
                      borderRadius: BorderRadius.circular(14),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // Badge "Publicité"
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'Publicité',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.advertisement.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.advertisement.description != null &&
                      widget.advertisement.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.advertisement.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onClose,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            minimumSize: const Size(10, 36),
                          ),
                          child: const Text(
                            'Fermer',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      if (widget.advertisement.linkUrl != null &&
                          widget.advertisement.linkUrl!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _openExternalLink,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              minimumSize: const Size(0, 36),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'En savoir plus',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    print('🚀 [POPUP] _launchUrl appelé avec: $url');
    try {
      final uri = Uri.parse(url);
      print('📋 [POPUP] URI parsé: $uri');
      final canLaunch = await canLaunchUrl(uri);
      print('✅ [POPUP] canLaunchUrl: $canLaunch');
      if (canLaunch) {
        print('🌍 [POPUP] Lancement du navigateur...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ [POPUP] Navigateur lancé avec succès');
      } else {
        print('❌ [POPUP] Impossible de lancer l\'URL');
      }
    } catch (e) {
      print('❌ [POPUP] Erreur lors du lancement de l\'URL: $e');
    }
  }
}
