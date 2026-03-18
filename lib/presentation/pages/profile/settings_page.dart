import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/preferences/preferences_bloc.dart';
import '../../blocs/preferences/preferences_event.dart';
import '../../blocs/preferences/preferences_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Vérifier si le PreferencesBloc est disponible
    try {
      context.read<PreferencesBloc>();
    } catch (e) {
      // Si le bloc n'est pas disponible, afficher un message d'erreur
      return Scaffold(
        appBar: AppBar(title: const Text('Paramètres')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Service temporairement indisponible',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Veuillez réessayer plus tard',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          return ListView(
            children: [
              const SizedBox(height: 16),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              SwitchListTile(
                title: const Text('Activer les notifications'),
                subtitle: const Text('Recevoir des alertes de l\'application'),
                value: state.notificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  context.read<PreferencesBloc>().add(
                    ToggleNotificationsEvent(value),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Notifications activées'
                            : 'Notifications désactivées',
                      ),
                      backgroundColor: value
                          ? AppColors.success
                          : AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              SwitchListTile(
                title: const Text('Notifications par email'),
                subtitle: const Text('Recevoir des notifications par email'),
                value: state.emailNotificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: state.notificationsEnabled
                    ? (value) {
                        context.read<PreferencesBloc>().add(
                          ToggleEmailNotificationsEvent(value),
                        );
                      }
                    : null,
              ),

              SwitchListTile(
                title: const Text('Notifications par SMS'),
                subtitle: const Text('Recevoir des notifications par SMS'),
                value: state.smsNotificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: state.notificationsEnabled
                    ? (value) {
                        context.read<PreferencesBloc>().add(
                          ToggleSmsNotificationsEvent(value),
                        );
                      }
                    : null,
              ),

              const Divider(height: 32, thickness: 8),

              // Appearance Section
              _buildSectionHeader('Apparence'),
              SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: const Text('Activer le thème sombre'),
                value: state.isDarkMode,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  context.read<PreferencesBloc>().add(
                    ToggleDarkModeEvent(value),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value ? 'Mode sombre activé' : 'Mode clair activé',
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Informations supplémentaires
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Espace de stockage',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Les préférences sont sauvegardées localement',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
