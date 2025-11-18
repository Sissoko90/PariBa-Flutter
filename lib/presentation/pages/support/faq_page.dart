import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// FAQ Page - Questions fréquemment posées
class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'category': 'Général',
        'questions': [
          {
            'question': 'Qu\'est-ce que PariBa ?',
            'answer':
                'PariBa est une application mobile de gestion de tontines qui vous permet de créer, gérer et participer à des groupes de tontine de manière simple et sécurisée.',
          },
          {
            'question': 'Comment créer un compte ?',
            'answer':
                'Pour créer un compte, cliquez sur "S\'inscrire" sur la page de connexion, remplissez le formulaire avec vos informations personnelles et validez.',
          },
          {
            'question': 'L\'application est-elle gratuite ?',
            'answer':
                'Oui, PariBa est entièrement gratuit. Aucun frais n\'est prélevé sur vos transactions de tontine.',
          },
        ],
      },
      {
        'category': 'Groupes',
        'questions': [
          {
            'question': 'Comment créer un groupe de tontine ?',
            'answer':
                'Allez dans l\'onglet "Groupes", cliquez sur le bouton "+" et remplissez les informations du groupe (nom, montant, fréquence, etc.).',
          },
          {
            'question': 'Comment rejoindre un groupe ?',
            'answer':
                'Vous pouvez rejoindre un groupe en utilisant le code d\'invitation fourni par le créateur du groupe ou en scannant le QR code.',
          },
          {
            'question': 'Puis-je quitter un groupe ?',
            'answer':
                'Oui, vous pouvez quitter un groupe à tout moment via les paramètres du groupe. Attention, vous perdrez l\'accès aux informations du groupe.',
          },
          {
            'question': 'Combien de membres peut contenir un groupe ?',
            'answer':
                'Un groupe peut contenir jusqu\'à 50 membres. Le nombre de membres doit correspondre au nombre de tours défini.',
          },
        ],
      },
      {
        'category': 'Paiements',
        'questions': [
          {
            'question': 'Comment effectuer un paiement ?',
            'answer':
                'Allez dans les détails du groupe, cliquez sur "Payer" et suivez les instructions pour effectuer votre cotisation.',
          },
          {
            'question': 'Quels sont les modes de paiement acceptés ?',
            'answer':
                'PariBa supporte les paiements par Mobile Money (Orange Money, Moov Money, etc.) et les virements bancaires.',
          },
          {
            'question': 'Que se passe-t-il si je rate un paiement ?',
            'answer':
                'Si votre groupe a défini des pénalités de retard, elles seront appliquées après la période de grâce. Vous recevrez des notifications de rappel.',
          },
          {
            'question': 'Puis-je voir l\'historique de mes paiements ?',
            'answer':
                'Oui, l\'historique complet de vos paiements est disponible dans les détails de chaque groupe et dans votre profil.',
          },
        ],
      },
      {
        'category': 'Sécurité',
        'questions': [
          {
            'question': 'Mes données sont-elles sécurisées ?',
            'answer':
                'Oui, toutes vos données sont cryptées et stockées de manière sécurisée. Nous ne partageons jamais vos informations personnelles.',
          },
          {
            'question': 'Comment réinitialiser mon mot de passe ?',
            'answer':
                'Sur la page de connexion, cliquez sur "Mot de passe oublié" et suivez les instructions envoyées par email.',
          },
          {
            'question': 'Puis-je activer l\'authentification à deux facteurs ?',
            'answer':
                'Cette fonctionnalité sera bientôt disponible. Vous serez notifié lors de sa mise en place.',
          },
        ],
      },
      {
        'category': 'Notifications',
        'questions': [
          {
            'question': 'Comment gérer mes notifications ?',
            'answer':
                'Allez dans Profil > Paramètres > Notifications pour activer ou désactiver les différents types de notifications.',
          },
          {
            'question': 'Pourquoi je ne reçois pas de notifications ?',
            'answer':
                'Vérifiez que les notifications sont activées dans les paramètres de l\'application et dans les paramètres de votre téléphone.',
          },
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final category = faqs[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category['category'] as String),
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      category['category'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              ...(category['questions'] as List).map((faq) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      faq['question'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          faq['answer'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          border: Border(
            top: BorderSide(color: AppColors.info.withOpacity(0.3)),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.help_outline, color: AppColors.info),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Vous ne trouvez pas votre réponse ?',
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
              child: const Text('Contactez-nous'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Général':
        return Icons.info;
      case 'Groupes':
        return Icons.group;
      case 'Paiements':
        return Icons.payment;
      case 'Sécurité':
        return Icons.security;
      case 'Notifications':
        return Icons.notifications;
      default:
        return Icons.help;
    }
  }
}
