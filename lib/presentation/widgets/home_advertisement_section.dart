import 'package:flutter/material.dart';
import '../../data/models/advertisement_model.dart';
import '../../data/datasources/remote/advertisement_remote_datasource.dart';
import 'advertisement_banner.dart';
import 'advertisement_fullscreen.dart';
import 'advertisement_popup.dart';
import 'advertisement_carousel_with_indicators.dart';

/// Widget qui affiche les publicités sur la page d'accueil
/// uniquement pour les utilisateurs non abonnés
class HomeAdvertisementSection extends StatefulWidget {
  final bool hasActiveSubscription;
  final AdvertisementRemoteDataSource advertisementDataSource;

  const HomeAdvertisementSection({
    super.key,
    required this.hasActiveSubscription,
    required this.advertisementDataSource,
  });

  @override
  State<HomeAdvertisementSection> createState() =>
      _HomeAdvertisementSectionState();
}

class _HomeAdvertisementSectionState extends State<HomeAdvertisementSection> {
  List<AdvertisementModel>? _bannerAds;
  List<AdvertisementModel>? _popupAds;
  List<AdvertisementModel>? _fullscreenAds;
  bool _isLoading = true;
  bool _popupShown = false;
  bool _fullscreenShown = false;

  @override
  void initState() {
    super.initState();
    if (!widget.hasActiveSubscription) {
      _loadAdvertisements();
    }
  }

  Future<void> _loadAdvertisements() async {
    try {
      debugPrint('🚀 [HOME_ADS] Début du chargement des publicités...');

      // Charger les publicités pour chaque placement
      debugPrint('📥 [HOME_ADS] Chargement BANNER...');
      final banners = await widget.advertisementDataSource.getAdvertisements(
        'BANNER',
      );
      debugPrint('✅ [HOME_ADS] BANNER: ${banners.length} publicités');

      debugPrint('📥 [HOME_ADS] Chargement POPUP...');
      final popups = await widget.advertisementDataSource.getAdvertisements(
        'POPUP',
      );
      debugPrint('✅ [HOME_ADS] POPUP: ${popups.length} publicités');

      debugPrint('📥 [HOME_ADS] Chargement FULLSCREEN...');
      final fullscreens = await widget.advertisementDataSource
          .getAdvertisements('FULLSCREEN');
      debugPrint('✅ [HOME_ADS] FULLSCREEN: ${fullscreens.length} publicités');

      setState(() {
        _bannerAds = banners;
        _popupAds = popups;
        _fullscreenAds = fullscreens;
        _isLoading = false;
      });

      debugPrint('✨ [HOME_ADS] Chargement terminé avec succès');

      // Afficher les popups après 3 secondes si disponibles
      if (_popupAds != null && _popupAds!.isNotEmpty && !_popupShown) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_popupShown) {
            _showPopupAdsCarousel();
          }
        });
      }

      // Afficher les fullscreen après 10 secondes si disponibles
      if (_fullscreenAds != null &&
          _fullscreenAds!.isNotEmpty &&
          !_fullscreenShown) {
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted && !_fullscreenShown) {
            _showFullscreenAdsCarousel();
          }
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('❌ [HOME_ADS] Erreur lors du chargement des publicités: $e');
      debugPrint('❌ [HOME_ADS] StackTrace: $stackTrace');
    }
  }

  void _showPopupAdsCarousel() {
    setState(() {
      _popupShown = true;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AdvertisementCarouselWithIndicators(
          advertisements: _popupAds!,
          placement: AdPlacement.popup,
          onImpression: _recordImpression,
          onClick: _recordClick,
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showPopupAd(AdvertisementModel ad) {
    setState(() {
      _popupShown = true;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AdvertisementPopup(
        advertisement: ad,
        onClose: () {
          Navigator.of(context).pop();
        },
        onImpression: () {
          _recordImpression(ad.id);
        },
        onClick: () {
          _recordClick(ad.id);
        },
      ),
    );
  }

  void _showFullscreenAdsCarousel() {
    setState(() {
      _fullscreenShown = true;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AdvertisementCarouselWithIndicators(
          advertisements: _fullscreenAds!,
          placement: AdPlacement.fullscreen,
          onImpression: _recordImpression,
          onClick: _recordClick,
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showFullscreenAd(AdvertisementModel ad) {
    setState(() {
      _fullscreenShown = true;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AdvertisementFullscreen(
          advertisement: ad,
          onClose: () {
            Navigator.of(context).pop();
          },
          onImpression: () {
            _recordImpression(ad.id);
          },
          onClick: () {
            _recordClick(ad.id);
          },
        ),
      ),
    );
  }

  Future<void> _recordImpression(String adId) async {
    try {
      await widget.advertisementDataSource.recordImpression(adId);
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement de l\'impression: $e');
    }
  }

  Future<void> _recordClick(String adId) async {
    try {
      await widget.advertisementDataSource.recordClick(adId);
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement du clic: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si l'utilisateur a un abonnement actif, ne rien afficher
    if (widget.hasActiveSubscription) {
      return const SizedBox.shrink();
    }

    // Pendant le chargement
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    // Si pas de bannières, ne rien afficher
    if (_bannerAds == null || _bannerAds!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Afficher les bannières avec carousel et indicateurs
    return AdvertisementCarouselWithIndicators(
      advertisements: _bannerAds!,
      placement: AdPlacement.banner,
      onImpression: _recordImpression,
      onClick: _recordClick,
      onClose: () {
        setState(() {
          _bannerAds = [];
        });
      },
    );
  }
}
