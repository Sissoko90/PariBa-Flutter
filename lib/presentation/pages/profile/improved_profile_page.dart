import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'settings_page.dart';
import 'help_support_page.dart';

/// Improved Profile Page
class ImprovedProfilePage extends StatelessWidget {
  const ImprovedProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Center(child: Text('Non authentifié'));
        }

        final person = state.person;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar avec photo de profil
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.white,
                          child: person.photo != null
                              ? ClipOval(
                                  child: Image.network(
                                    person.photo!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.primary,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.primary,
                                ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          person.fullName,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          person.email,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Statistiques rapides
                    _buildStatsSection(),

                    const SizedBox(height: 8),

                    // Informations personnelles
                    _buildSection(
                      'Informations personnelles',
                      [
                        _buildInfoTile(
                          Icons.person_outline,
                          'Nom complet',
                          person.fullName,
                        ),
                        _buildInfoTile(
                          Icons.phone_outlined,
                          'Téléphone',
                          person.phone,
                        ),
                        _buildInfoTile(
                          Icons.badge_outlined,
                          'Rôle',
                          person.role,
                        ),
                      ],
                    ),

                    // Compte
                    _buildSection(
                      'Compte',
                      [
                        _buildActionTile(
                          context,
                          Icons.edit_outlined,
                          'Modifier le profil',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          ),
                        ),
                        _buildActionTile(
                          context,
                          Icons.lock_outlined,
                          'Changer le mot de passe',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                          ),
                        ),
                        _buildActionTile(
                          context,
                          Icons.security_outlined,
                          'Sécurité et confidentialité',
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('En développement'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Préférences
                    _buildSection(
                      'Préférences',
                      [
                        _buildActionTile(
                          context,
                          Icons.settings_outlined,
                          'Paramètres',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          ),
                        ),
                        _buildActionTile(
                          context,
                          Icons.notifications_outlined,
                          'Notifications',
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('En développement'),
                              ),
                            );
                          },
                        ),
                        _buildActionTile(
                          context,
                          Icons.language_outlined,
                          'Langue',
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('En développement'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Support
                    _buildSection(
                      'Support',
                      [
                        _buildActionTile(
                          context,
                          Icons.help_outline,
                          'Aide & Support',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportPage(),
                            ),
                          ),
                        ),
                        _buildActionTile(
                          context,
                          Icons.info_outline,
                          'À propos',
                          () => _showAboutDialog(context),
                        ),
                        _buildActionTile(
                          context,
                          Icons.privacy_tip_outlined,
                          'Politique de confidentialité',
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('En développement'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Déconnexion
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        color: AppColors.error.withOpacity(0.1),
                        child: ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: AppColors.error,
                          ),
                          title: const Text(
                            'Se déconnecter',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.error,
                          ),
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Version
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('5', 'Groupes', Icons.group),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('12', 'Paiements', Icons.payment),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('3', 'En attente', Icons.pending),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos de PariBa'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PariBa - Gestion de Tontines',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'PariBa est une application moderne pour gérer vos tontines facilement et en toute sécurité.',
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 PariBa. Tous droits réservés.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
