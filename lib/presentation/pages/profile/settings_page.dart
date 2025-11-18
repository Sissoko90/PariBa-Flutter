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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
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
                value: state.notificationsEnabled,
                onChanged: (value) {
                  context.read<PreferencesBloc>().add(
                        ToggleNotificationsEvent(value),
                      );
                },
              ),
              SwitchListTile(
                title: const Text('Notifications par email'),
                subtitle: const Text('Recevoir des notifications par email'),
                value: state.emailNotificationsEnabled,
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
                onChanged: state.notificationsEnabled
                    ? (value) {
                        context.read<PreferencesBloc>().add(
                              ToggleSmsNotificationsEvent(value),
                            );
                      }
                    : null,
              ),
              const Divider(),
              // Appearance Section
              _buildSectionHeader('Apparence'),
              SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: const Text('Activer le thème sombre'),
                value: state.isDarkMode,
                onChanged: (value) {
                  context.read<PreferencesBloc>().add(
                        ToggleDarkModeEvent(value),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Mode sombre activé'
                            : 'Mode sombre désactivé',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
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
