import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/remote/support_remote_datasource.dart';
import '../../../data/models/guide_model.dart';
import '../../../di/injection.dart' as di;

/// User Guide Page - Guide d'utilisation
class UserGuidePage extends StatefulWidget {
  const UserGuidePage({super.key});

  @override
  State<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage> {
  late final SupportRemoteDataSource _dataSource;
  List<GuideModel> _guides = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dataSource = SupportRemoteDataSourceImpl(di.sl());
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final guides = await _dataSource.getGuides();
      setState(() {
        _guides = guides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  IconData _getIconFromName(String? iconName) {
    if (iconName == null) return Icons.book;
    switch (iconName.toLowerCase()) {
      case 'info':
        return Icons.info;
      case 'person':
        return Icons.person;
      case 'group_add':
        return Icons.group_add;
      case 'payment':
        return Icons.payment;
      case 'star':
        return Icons.star;
      case 'build':
        return Icons.build;
      case 'security':
        return Icons.security;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Guide d\'utilisation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Guide d\'utilisation')),
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
                onPressed: _loadGuides,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide d\'utilisation'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGuides),
        ],
      ),
      body: _guides.isEmpty
          ? const Center(child: Text('Aucun guide disponible'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _guides.length,
              itemBuilder: (context, index) {
                final guide = _guides[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        _getIconFromName(guide.iconName),
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      guide.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: guide.description != null
                        ? Text(
                            guide.description!,
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guide.content,
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                            if (guide.estimatedReadTime != null)
                              Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${guide.estimatedReadTime} min de lecture',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
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
