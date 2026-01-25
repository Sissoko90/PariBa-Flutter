import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/remote/support_remote_datasource.dart';
import '../../../data/models/faq_model.dart';
import '../../../di/injection.dart' as di;

/// FAQ Page - Questions fréquemment posées
class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  late final SupportRemoteDataSource _dataSource;
  List<FAQModel> _faqs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dataSource = SupportRemoteDataSourceImpl(di.sl());
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final faqs = await _dataSource.getFAQs();
      setState(() {
        _faqs = faqs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, List<FAQModel>> _groupByCategory() {
    final Map<String, List<FAQModel>> grouped = {};
    for (var faq in _faqs) {
      if (!grouped.containsKey(faq.category)) {
        grouped[faq.category] = [];
      }
      grouped[faq.category]!.add(faq);
    }
    return grouped;
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'ACCOUNT':
        return 'Compte utilisateur';
      case 'TONTINE':
        return 'Tontines';
      case 'PAYMENT':
        return 'Paiements';
      case 'SECURITY':
        return 'Sécurité';
      case 'FEATURES':
        return 'Fonctionnalités';
      case 'TECHNICAL':
        return 'Technique';
      case 'GENERAL':
        return 'Général';
      default:
        return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('FAQ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('FAQ')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadFAQs,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final groupedFAQs = _groupByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFAQs),
        ],
      ),
      body: groupedFAQs.isEmpty
          ? const Center(child: Text('Aucune FAQ disponible'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedFAQs.length,
              itemBuilder: (context, index) {
                final category = groupedFAQs.keys.elementAt(index);
                final faqs = groupedFAQs[category]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getCategoryLabel(category),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...faqs.map((faq) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            faq.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                faq.answer,
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
      case 'GENERAL':
        return Icons.info;
      case 'TONTINE':
        return Icons.group;
      case 'PAYMENT':
        return Icons.payment;
      case 'SECURITY':
        return Icons.security;
      case 'ACCOUNT':
        return Icons.person;
      case 'FEATURES':
        return Icons.star;
      case 'TECHNICAL':
        return Icons.build;
      default:
        return Icons.help;
    }
  }
}
