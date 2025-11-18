import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../support/faq_page.dart';
import '../support/contact_support_page.dart';
import '../support/user_guide_page.dart';
import '../support/report_issue_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpCard(
            'FAQ',
            'Questions fréquemment posées',
            Icons.question_answer,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FAQPage()),
            ),
          ),
          _buildHelpCard(
            'Contacter le support',
            'Envoyez-nous un message',
            Icons.email,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactSupportPage()),
            ),
          ),
          _buildHelpCard(
            'Guide d\'utilisation',
            'Apprenez à utiliser PariBa',
            Icons.book,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserGuidePage()),
            ),
          ),
          _buildHelpCard(
            'Signaler un problème',
            'Faites-nous part d\'un bug',
            Icons.bug_report,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportIssuePage()),
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contactez-nous',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.email, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text('support@pariba.com'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text('+223 76 71 41 42'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
