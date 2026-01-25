import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/models/advertisement_model.dart';
import 'advertisement_banner.dart';
import 'advertisement_popup.dart';
import 'advertisement_fullscreen.dart';

class AdvertisementCarouselWithIndicators extends StatefulWidget {
  final List<AdvertisementModel> advertisements;
  final AdPlacement placement;
  final Function(String adId)? onImpression;
  final Function(String adId)? onClick;
  final VoidCallback? onClose;

  const AdvertisementCarouselWithIndicators({
    super.key,
    required this.advertisements,
    required this.placement,
    this.onImpression,
    this.onClick,
    this.onClose,
  });

  @override
  State<AdvertisementCarouselWithIndicators> createState() =>
      _AdvertisementCarouselWithIndicatorsState();
}

class _AdvertisementCarouselWithIndicatorsState
    extends State<AdvertisementCarouselWithIndicators> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Note: L'enregistrement des impressions est géré par chaque widget individuel
    // (AdvertisementBanner, AdvertisementPopup, AdvertisementFullscreen)
    // dans leur propre initState() via le callback onImpression
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // Note: L'impression de la nouvelle publicité sera enregistrée automatiquement
    // par le widget individuel lors de son affichage (initState)
  }

  Widget _buildAdvertisementWidget(AdvertisementModel ad) {
    switch (widget.placement) {
      case AdPlacement.banner:
        return AdvertisementBanner(
          advertisement: ad,
          onClose: widget.onClose,
          onImpression: () => widget.onImpression?.call(ad.id),
          onClick: () => widget.onClick?.call(ad.id),
        );
      case AdPlacement.popup:
        return AdvertisementPopup(
          advertisement: ad,
          onClose: widget.onClose ?? () {},
          onImpression: () => widget.onImpression?.call(ad.id),
          onClick: () => widget.onClick?.call(ad.id),
        );
      case AdPlacement.fullscreen:
        return AdvertisementFullscreen(
          advertisement: ad,
          onClose: widget.onClose ?? () {},
          onImpression: () => widget.onImpression?.call(ad.id),
          onClick: () => widget.onClick?.call(ad.id),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.advertisements.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.advertisements.length == 1) {
      // Une seule publicité, pas besoin de carousel
      return _buildAdvertisementWidget(widget.advertisements[0]);
    }

    // Plusieurs publicités, afficher avec carousel et indicateurs
    final isFullscreen = widget.placement == AdPlacement.fullscreen;
    final isPopup = widget.placement == AdPlacement.popup;

    if (isFullscreen) {
      // Pour FULLSCREEN, utiliser tout l'écran avec indicateurs en bas
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.advertisements.length,
              itemBuilder: (context, index) {
                return _buildAdvertisementWidget(widget.advertisements[index]);
              },
            ),
            if (widget.advertisements.length > 1)
              Positioned(
                bottom:
                    120, // Au-dessus des boutons (60px espace + 42px bouton + 18px marge)
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: widget.advertisements.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 6,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (isPopup) {
      // Pour POPUP, utiliser un dialog avec carousel et indicateurs
      final screenHeight = MediaQuery.of(context).size.height;

      return Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenHeight * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.advertisements.length,
                itemBuilder: (context, index) {
                  return _buildAdvertisementWidget(
                    widget.advertisements[index],
                  );
                },
              ),
            ),
            if (widget.advertisements.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 12),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.advertisements.length,
                  effect: WormEffect(
                    dotHeight: 7,
                    dotWidth: 7,
                    spacing: 5,
                    activeDotColor: Theme.of(context).primaryColor,
                    dotColor: Colors.grey.shade300,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Pour BANNER, utiliser une hauteur fixe
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.advertisements.length,
            itemBuilder: (context, index) {
              return _buildAdvertisementWidget(widget.advertisements[index]);
            },
          ),
        ),
        if (widget.advertisements.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.advertisements.length,
              effect: WormEffect(
                dotHeight: 6,
                dotWidth: 6,
                spacing: 4,
                activeDotColor: Theme.of(context).primaryColor,
                dotColor: Colors.grey.shade300,
              ),
            ),
          ),
      ],
    );
  }
}
