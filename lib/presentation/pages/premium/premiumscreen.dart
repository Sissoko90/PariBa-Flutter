import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  String selectedPlan = 'Annuel';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<PremiumFeature> _features = const [
    PremiumFeature(
      icon: Icons.picture_as_pdf,
      title: 'Export PDF & Excel',
      description: 'Exportez vos données en un clic',
      color: Color(0xFF2E7D32),
    ),
    PremiumFeature(
      icon: Icons.group_work,
      title: 'Tontines illimitées',
      description: 'Créez autant de groupes que vous voulez',
      color: Color(0xFF1976D2),
    ),
    PremiumFeature(
      icon: Icons.people_alt,
      title: 'Gestion multi-compte',
      description: 'Gérez plusieurs comptes facilement',
      color: Color(0xFFED6A02),
    ),
    PremiumFeature(
      icon: Icons.stars,
      title: 'Badge Premium exclusif',
      description: 'Mettez en valeur votre profil',
      color: Color(0xFF9C27B0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// HEADER ANIMÉ
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Icône Premium animée
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              size: 60,
                              color: Colors.amber,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Passez Premium",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Débloquez toutes les fonctionnalités exclusives et boostez votre expérience.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// CONTAINER BLANC PRINCIPAL AVEC ANIMATION
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        /// PLANS AMÉLIORÉS
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildAnimatedPlanCard(
                                title: "Mensuel",
                                price: "2 000",
                                currency: "FCFA",
                                period: "mois",
                                isSelected: selectedPlan == 'Mensuel',
                                delay: 100,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildAnimatedPlanCard(
                                title: "Annuel",
                                price: "20 000",
                                currency: "FCFA",
                                period: "an",
                                isSelected: selectedPlan == 'Annuel',
                                isBestOffer: true,
                                delay: 200,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        /// FEATURES AMÉLIORÉS
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Fonctionnalités incluses",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// LISTE DES FEATURES ANIMÉE
                        Expanded(
                          child: ListView.builder(
                            itemCount: _features.length,
                            itemBuilder: (context, index) {
                              return TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: Duration(
                                  milliseconds: 500 + (index * 100),
                                ),
                                curve: Curves.easeOut,
                                builder: (context, double opacity, child) {
                                  return Opacity(
                                    opacity: opacity,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _buildEnhancedFeatureItem(
                                        _features[index],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// CTA BUTTON AMÉLIORÉ
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.9, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          builder: (context, double scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2E7D32),
                                      Color(0xFF388E3C),
                                      Color(0xFF43A047),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2E7D32,
                                      ).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _showSuccessAnimation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Devenir Premium",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      TweenAnimationBuilder(
                                        tween: Tween<double>(
                                          begin: 1.0,
                                          end: 1.2,
                                        ),
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                        curve: Curves.easeInOut,
                                        builder:
                                            (context, double scale, child) {
                                              return Transform.scale(
                                                scale: scale,
                                                child: const Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPlanCard({
    required String title,
    required String price,
    required String currency,
    required String period,
    required bool isSelected,
    bool isBestOffer = false,
    int delay = 0,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: () {
              setState(() => selectedPlan = title);
              _showPlanSelectionAnimation();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                top: isBestOffer ? 24 : 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Stack(
                clipBehavior: Clip.none, // Permet au badge de dépasser
                children: [
                  if (isBestOffer)
                    Positioned(
                      top: -12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, double scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.amber, Colors.orange],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Meilleure offre",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: isBestOffer ? 20 : 0),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              currency,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "/$period",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedFeatureItem(PremiumFeature feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: feature.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanSelectionAnimation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "💰 Plan $selectedPlan sélectionné",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 50,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Félicitations !",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Vous êtes maintenant membre Premium",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "✅ Abonnement $selectedPlan activé avec succès !",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Commencer",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
