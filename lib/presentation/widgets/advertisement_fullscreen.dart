import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../data/models/advertisement_model.dart';
import '../../core/theme/app_colors.dart';

/// Widget pour afficher une publicité en plein écran
class AdvertisementFullscreen extends StatefulWidget {
  final AdvertisementModel advertisement;
  final VoidCallback onClose;
  final VoidCallback? onImpression;
  final VoidCallback? onClick;

  const AdvertisementFullscreen({
    super.key,
    required this.advertisement,
    required this.onClose,
    this.onImpression,
    this.onClick,
  });

  @override
  State<AdvertisementFullscreen> createState() =>
      _AdvertisementFullscreenState();
}

class _AdvertisementFullscreenState extends State<AdvertisementFullscreen> {
  bool _impressionRecorded = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordImpression();
    });
  }

  void _initializeVideo() {
    if (widget.advertisement.videoUrl != null &&
        widget.advertisement.videoUrl!.isNotEmpty) {
      _videoController =
          VideoPlayerController.networkUrl(
              Uri.parse(widget.advertisement.videoUrl!),
            )
            ..initialize().then((_) {
              setState(() {});
              _videoController!.play();
              _videoController!.setLooping(true);
            })
            ..addListener(() {
              if (mounted) setState(() {});
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _recordImpression() {
    if (!_impressionRecorded) {
      _impressionRecorded = true;
      widget.onImpression?.call();
      print(
        '👁️ [FULLSCREEN] Impression enregistrée pour: ${widget.advertisement.id}',
      );
    }
  }

  // Clic sur l'image : enregistrer le clic uniquement
  void _handleImageClick() {
    print('🔥 [FULLSCREEN] Clic sur l\'image pour: ${widget.advertisement.id}');
    widget.onClick?.call();
    print('� [FULLSCREEN] Clic enregistré pour: ${widget.advertisement.id}');
  }

  // Clic sur "En savoir plus" : ouvrir le lien externe uniquement
  Future<void> _openExternalLink() async {
    print(
      '🌐 [FULLSCREEN] Ouverture du lien externe: ${widget.advertisement.linkUrl}',
    );
    if (widget.advertisement.linkUrl != null &&
        widget.advertisement.linkUrl!.isNotEmpty) {
      await _launchUrl(widget.advertisement.linkUrl!);
      widget.onClose();
    } else {
      print('⚠️ [FULLSCREEN] Pas de lien à ouvrir');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ [FULLSCREEN] Build - linkUrl: ${widget.advertisement.linkUrl}');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Vidéo ou Image plein écran
            Center(
              child:
                  _videoController != null &&
                      _videoController!.value.isInitialized
                  ? GestureDetector(
                      onTap: _handleImageClick,
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : GestureDetector(
                      onTap: _handleImageClick,
                      child: CachedNetworkImage(
                        imageUrl: widget.advertisement.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
            // Bouton fermer en haut à droite avec compteur
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                  onPressed: widget.onClose,
                ),
              ),
            ),
            // Badge "Publicité" en haut à gauche
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Publicité',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Informations en bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.advertisement.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.advertisement.description != null &&
                          widget.advertisement.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.advertisement.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                          maxLines: 2,
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
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                minimumSize: const Size(0, 42),
                              ),
                              child: const Text(
                                'Fermer',
                                style: TextStyle(fontSize: 14),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  minimumSize: const Size(0, 42),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'En savoir plus',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.open_in_new, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 60), // Espace pour les indicateurs
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    print('🚀 [FULLSCREEN] _launchUrl appelé avec: $url');
    try {
      final uri = Uri.parse(url);
      print('📋 [FULLSCREEN] URI parsé: $uri');
      final canLaunch = await canLaunchUrl(uri);
      print('✅ [FULLSCREEN] canLaunchUrl: $canLaunch');
      if (canLaunch) {
        print('🌍 [FULLSCREEN] Lancement du navigateur...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ [FULLSCREEN] Navigateur lancé avec succès');
      } else {
        print('❌ [FULLSCREEN] Impossible de lancer l\'URL');
      }
    } catch (e) {
      print('❌ [FULLSCREEN] Erreur lors du lancement de l\'URL: $e');
    }
  }
}
