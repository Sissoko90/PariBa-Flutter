import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// User Guide Page - Guide d'utilisation
class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final guides = [
      {
        'title': 'Premiers pas',
        'icon': Icons.rocket_launch,
        'color': AppColors.primary,
        'steps': [
          'Créez votre compte avec votre email et mot de passe',
          'Complétez votre profil avec vos informations personnelles',
          'Explorez l\'interface et familiarisez-vous avec les fonctionnalités',
          'Créez votre premier groupe ou rejoignez un groupe existant',
        ],
      },
      {
        'title': 'Créer un groupe',
        'icon': Icons.add_circle,
        'color': AppColors.success,
        'steps': [
          'Allez dans l\'onglet "Groupes"',
          'Cliquez sur le bouton "+" ou "Nouveau Groupe"',
          'Remplissez les informations : nom, montant, fréquence',
          'Définissez le mode de rotation et le nombre de tours',
          'Ajoutez une description (optionnel)',
          'Configurez les pénalités de retard si nécessaire',
          'Validez pour créer le groupe',
        ],
      },
      {
        'title': 'Rejoindre un groupe',
        'icon': Icons.group_add,
        'color': AppColors.secondary,
        'steps': [
          'Demandez le code d\'invitation au créateur du groupe',
          'Allez dans "Rejoindre un groupe"',
          'Entrez le code d\'invitation ou scannez le QR code',
          'Vérifiez les informations du groupe',
          'Confirmez votre adhésion',
          'Attendez la validation du créateur si nécessaire',
        ],
      },
      {
        'title': 'Effectuer un paiement',
        'icon': Icons.payment,
        'color': AppColors.info,
        'steps': [
          'Ouvrez les détails du groupe',
          'Cliquez sur "Payer" ou "Effectuer un paiement"',
          'Choisissez votre mode de paiement',
          'Entrez le montant (pré-rempli)',
          'Confirmez le paiement',
          'Conservez la preuve de transaction',
        ],
      },
      {
        'title': 'Inviter des membres',
        'icon': Icons.person_add,
        'color': AppColors.warning,
        'steps': [
          'Ouvrez les détails du groupe',
          'Cliquez sur "Inviter"',
          'Partagez le code d\'invitation ou le QR code',
          'Ou envoyez une invitation par email/SMS/WhatsApp',
          'Suivez les invitations en attente',
          'Acceptez ou refusez les demandes d\'adhésion',
        ],
      },
      {
        'title': 'Gérer votre profil',
        'icon': Icons.person,
        'color': AppColors.primary,
        'steps': [
          'Allez dans l\'onglet "Profil"',
          'Cliquez sur "Modifier le profil"',
          'Mettez à jour vos informations',
          'Changez votre photo de profil',
          'Modifiez votre mot de passe si nécessaire',
          'Configurez vos préférences de notifications',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide d\'utilisation'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guides.length,
        itemBuilder: (context, index) {
          final guide = guides[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (guide['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  guide['icon'] as IconData,
                  color: guide['color'] as Color,
                  size: 28,
                ),
              ),
              title: Text(
                guide['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (guide['steps'] as List<String>)
                        .asMap()
                        .entries
                        .map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: (guide['color'] as Color).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: TextStyle(
                                    color: guide['color'] as Color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          border: Border(
            top: BorderSide(color: AppColors.success.withOpacity(0.3)),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.success),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Besoin d\'aide supplémentaire ?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contacter le support')),
                );
              },
              child: const Text('Support'),
            ),
          ],
        ),
      ),
    );
  }
}
