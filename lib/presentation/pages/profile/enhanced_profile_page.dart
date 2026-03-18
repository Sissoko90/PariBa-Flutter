import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pariba/presentation/pages/notifications/enhanced_notifications_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_state.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'settings_page.dart';
import 'help_support_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/url_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_state.dart';

/// Enhanced Profile Page - Version améliorée
class EnhancedProfilePage extends StatelessWidget {
  const EnhancedProfilePage({super.key});

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
              // App Bar avec design moderne
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                              AppColors.secondary.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      // Pattern overlay
                      Opacity(
                        opacity: 0.1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Photo de profil avec bordure
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () => _changeProfilePhoto(context),
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor: AppColors.white,
                                  child:
                                      person.photo != null &&
                                          person.photo!.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            UrlHelper.fixPhotoUrl(
                                              person.photo!,
                                            ),
                                            width: 88,
                                            height: 88,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 88,
                                                    height: 88,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: AppColors.primary,
                                                    ),
                                                  );
                                                },
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: AppColors.primary,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Nom
                            Text(
                              person.fullName,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Email
                            Text(
                              person.email ?? person.phone ?? 'Non renseigné',
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Badge rôle
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.white.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_user,
                                    color: AppColors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    person.role,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ✅ Statistiques avec vraies données des groupes
                    BlocBuilder<GroupBloc, GroupState>(
                      builder: (context, groupState) {
                        int totalGroups = 0;
                        int totalPayments = 0;
                        int pendingPayments = 0;

                        if (groupState is GroupsLoaded) {
                          totalGroups = groupState.groups.length;

                          // ✅ CORRECTION 1: Convertir double en int avec .toInt()
                          totalPayments = groupState.groups
                              .fold<double>(
                                0,
                                (sum, group) => sum + (group.montant ?? 0),
                              )
                              .toInt();

                          // ✅ CORRECTION 2: pendingPayments n'existe pas, on utilise une autre propriété
                          // Par exemple, on peut compter le nombre de groupes actifs
                          pendingPayments = groupState.groups
                              .where(
                                (group) =>
                                    group.status == 'pending' ||
                                    group.status == 'active',
                              )
                              .length;
                        }

                        return _buildEnhancedStats(
                          totalGroups: totalGroups,
                          totalPayments: totalPayments,
                          pendingPayments: pendingPayments,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Menu rapide
                    _buildQuickMenu(context),

                    const SizedBox(height: 16),

                    // Informations personnelles
                    _buildSection('Informations personnelles', Icons.person, [
                      _buildInfoTile(
                        Icons.badge_outlined,
                        'Nom complet',
                        person.fullName,
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        Icons.phone_outlined,
                        'Téléphone',
                        person.phone ?? 'Non renseigné',
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        Icons.email_outlined,
                        'Email',
                        person.email ?? 'Non renseigné',
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Compte & Sécurité
                    _buildSection('Compte & Sécurité', Icons.security, [
                      _buildActionTile(
                        context,
                        Icons.edit_outlined,
                        'Modifier le profil',
                        'Mettre à jour vos informations',
                        AppColors.primary,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        context,
                        Icons.lock_outlined,
                        'Changer le mot de passe',
                        'Sécurisez votre compte',
                        AppColors.secondary,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage(),
                          ),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Préférences
                    _buildSection('Préférences', Icons.tune, [
                      _buildActionTile(
                        context,
                        Icons.settings_outlined,
                        'Paramètres',
                        'Personnalisez votre expérience',
                        AppColors.info,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      // Tile des notifications avec badge
                      BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (context, notifState) {
                          int unreadCount = 0;
                          if (notifState is NotificationLoaded) {
                            unreadCount = notifState.unreadCount;
                          }

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                unreadCount > 0
                                    ? Icons.notifications_active
                                    : Icons.notifications_outlined,
                                color: AppColors.warning,
                                size: 22,
                              ),
                            ),
                            title: Row(
                              children: [
                                const Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: const Text(
                              'Gérer vos alertes',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EnhancedNotificationsPage(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Support
                    _buildSection('Support', Icons.help_center, [
                      _buildActionTile(
                        context,
                        Icons.help_outline,
                        'Aide & Support',
                        'Besoin d\'assistance ?',
                        AppColors.success,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportPage(),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        context,
                        Icons.info_outline,
                        'À propos',
                        'Version et informations',
                        AppColors.info,
                        () => _showAboutDialog(context),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Déconnexion avec design amélioré
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showLogoutDialog(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.error.withOpacity(0.1),
                                  AppColors.error.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Se déconnecter',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Version
                    Text(
                      'PariBa v1.0.0',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Méthode avec paramètres dynamiques
  Widget _buildEnhancedStats({
    required int totalGroups,
    required int totalPayments,
    required int pendingPayments,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: _buildStatItem(
              totalGroups.toString(),
              'Groupes',
              Icons.group,
              AppColors.primary,
            ),
          ),
          Container(height: 40, width: 1, color: AppColors.greyLight),
          Flexible(
            child: _buildStatItem(
              totalPayments.toString(),
              'Paiements',
              Icons.payment,
              AppColors.success,
            ),
          ),
          Container(height: 40, width: 1, color: AppColors.greyLight),
          Flexible(
            child: _buildStatItem(
              pendingPayments.toString(),
              'En attente',
              Icons.pending,
              AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuickMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickMenuItem(
              'Modifier',
              Icons.edit,
              AppColors.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickMenuItem(
              'Sécurité',
              Icons.lock,
              AppColors.secondary,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickMenuItem(
              'Aide',
              Icons.help,
              AppColors.success,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenuItem(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  Future<void> _changeProfilePhoto(BuildContext context) async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Changer la photo'),
          content: const Text('Choisissez une source'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Appareil photo'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galerie'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) return;

      if (!context.mounted) return;

      BuildContext? dialogContext;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          dialogContext = ctx;
          return const Center(child: CircularProgressIndicator());
        },
      );

      final file = File(image.path);

      context.read<AuthBloc>().add(UploadProfilePhotoEvent(file: file));

      await Future.delayed(const Duration(seconds: 1));

      if (dialogContext != null && context.mounted) {
        try {
          Navigator.of(dialogContext!).pop();
        } catch (_) {}
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            const SizedBox(width: 12),
            const Text('Déconnexion'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text('À propos'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PariBa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Gestion de Tontines',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'PariBa est une application moderne pour gérer vos tontines facilement et en toute sécurité.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 PariBa. Tous droits réservés.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
