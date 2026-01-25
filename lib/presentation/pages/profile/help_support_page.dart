import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../support/faq_page.dart';
import '../support/contact_support_page.dart';
import '../support/user_guide_page.dart';
import '../support/report_issue_page.dart';
import '../../../data/datasources/remote/support_remote_datasource.dart';
import '../../../data/models/support_contact_model.dart';
import '../../../di/injection.dart' as di;

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  late final SupportRemoteDataSource _dataSource;
  SupportContactModel? _contactInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = SupportRemoteDataSourceImpl(di.sl());
    _loadContactInfo();
  }

  Future<void> _loadContactInfo() async {
    try {
      final contact = await _dataSource.getSupportContact();
      setState(() {
        _contactInfo = contact;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aide & Support')),
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
              MaterialPageRoute(
                builder: (context) => const ContactSupportPage(),
              ),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contactez-nous',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    Row(
                      children: [
                        const Icon(Icons.email, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _contactInfo?.email ?? 'support@pariba.com',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _contactInfo?.phone ?? '+223 76 71 41 42',
                          ),
                        ),
                      ],
                    ),
                    if (_contactInfo?.supportHours != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_contactInfo!.supportHours!)),
                        ],
                      ),
                    ],
                  ],
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
