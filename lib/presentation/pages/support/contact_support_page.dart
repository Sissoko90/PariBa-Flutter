import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../data/datasources/remote/support_remote_datasource.dart';
import '../../../data/models/support_contact_model.dart';
import '../../../di/injection.dart' as di;
import 'package:url_launcher/url_launcher.dart';

/// Contact Support Page - Contacter le support
class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'GENERAL_INQUIRY';
  late final SupportRemoteDataSource _dataSource;
  bool _isSubmitting = false;
  SupportContactModel? _contactInfo;
  bool _isLoadingContact = true;

  final Map<String, String> _categories = {
    'GENERAL_INQUIRY': 'Question générale',
    'TECHNICAL_ISSUE': 'Problème technique',
    'PAYMENT_ISSUE': 'Problème de paiement',
    'ACCOUNT_ISSUE': 'Problème de compte',
    'BUG_REPORT': 'Signalement de bug',
    'OTHER': 'Autre',
  };

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
        _isLoadingContact = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingContact = false;
      });
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        await _dataSource.createTicket({
          'type': _selectedCategory,
          'subject': _subjectController.text,
          'message': _messageController.text,
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket créé avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacter le support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.support_agent,
                      color: AppColors.primary,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notre équipe est là pour vous',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Réponse sous 24h en moyenne',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Catégorie
              const Text(
                'Catégorie',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),

              const SizedBox(height: 24),

              // Sujet
              const Text(
                'Sujet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _subjectController,
                label: 'Sujet de votre message',
                hint: 'Ex: Problème de connexion',
                prefixIcon: Icons.subject,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le sujet est requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Message
              const Text(
                'Message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _messageController,
                label: 'Votre message',
                hint: 'Décrivez votre problème ou votre question...',
                prefixIcon: Icons.message,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le message est requis';
                  }
                  if (value.length < 10) {
                    return 'Le message doit contenir au moins 10 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Bouton Envoyer
              CustomButton(
                text: _isSubmitting
                    ? 'Envoi en cours...'
                    : 'Envoyer le message',
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: Icons.send,
              ),

              const SizedBox(height: 24),

              // Autres moyens de contact
              const Text(
                'Autres moyens de nous contacter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (_isLoadingContact)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildContactCard(
                  'Email',
                  _contactInfo?.email ?? 'makenzyks6@gmail.com',
                  Icons.email,
                  AppColors.info,
                  () => _launchEmail(),
                ),

                const SizedBox(height: 12),

                _buildContactCard(
                  'Téléphone',
                  _contactInfo?.phone ?? '+223 97758697',
                  Icons.phone,
                  AppColors.success,
                  () => _launchPhone(),
                ),

                const SizedBox(height: 12),

                _buildContactCard(
                  'WhatsApp',
                  _contactInfo?.whatsappNumber ??
                      _contactInfo?.phone ??
                      '+223 97 75 86 97',
                  Icons.message,
                  AppColors.success,
                  () => _launchWhatsApp(),
                ),
              ],
              if (!_isLoadingContact && _contactInfo?.supportHours != null)
                const SizedBox(height: 16),
              if (!_isLoadingContact && _contactInfo?.supportHours != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _contactInfo!.supportHours!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final email = _contactInfo?.email ?? 'makenzyks6@gmail.com';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support PariBa',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir l\'application email'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _launchPhone() async {
    final phone = _contactInfo?.phone.replaceAll(' ', '') ?? '+22376714142';
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de lancer l\'appel'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _launchWhatsApp() async {
    final whatsapp =
        (_contactInfo?.whatsappNumber ?? _contactInfo?.phone ?? '+22376714142')
            .replaceAll(' ', '')
            .replaceAll('+', '');
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$whatsapp?text=Bonjour, j\'ai besoin d\'aide',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir WhatsApp'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildContactCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
