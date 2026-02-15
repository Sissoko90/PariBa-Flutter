import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/group_permissions.dart';
import '../../../data/models/tontine_group_model.dart';
import '../../blocs/membership/membership_bloc.dart';
import '../../blocs/membership/membership_event.dart';
import '../../blocs/membership/membership_state.dart';

/// Group Members Page - Gestion des membres d'un groupe
class GroupMembersPage extends StatefulWidget {
  final TontineGroupModel group;

  const GroupMembersPage({super.key, required this.group});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  @override
  void initState() {
    super.initState();
    // 🔍 DEBUG: Vérifier currentUserRole
    print('🔍 GroupMembersPage - Groupe: ${widget.group.nom}');
    print(
      '🔍 GroupMembersPage - currentUserRole: ${widget.group.currentUserRole}',
    );
    print(
      '🔍 GroupMembersPage - canInviteMembers: ${GroupPermissions.canInviteMembers(widget.group.currentUserRole)}',
    );
    print(
      '🔍 GroupMembersPage - canManageMembers: ${GroupPermissions.canManageMembers(widget.group.currentUserRole)}',
    );

    // Charger les membres du groupe
    context.read<MembershipBloc>().add(LoadGroupMembersEvent(widget.group.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membres du groupe'),
        actions: [
          // Inviter - ADMIN uniquement
          if (GroupPermissions.canInviteMembers(widget.group.currentUserRole))
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showInviteMemberDialog(context),
              tooltip: 'Inviter',
            ),
        ],
      ),
      body: BlocBuilder<MembershipBloc, MembershipState>(
        builder: (context, state) {
          if (state is MembershipLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MembershipError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text('Erreur: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MembershipBloc>().add(
                        LoadGroupMembersEvent(widget.group.id),
                      );
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final members = state is MembersLoaded ? state.members : [];

          return Column(
            children: [
              // Stats header
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '${members.length}',
                      'Membres',
                      Icons.people,
                    ),
                    _buildStatItem(
                      '${members.length}',
                      'Actifs',
                      Icons.check_circle,
                    ),
                    _buildStatItem('0', 'En attente', Icons.pending),
                  ],
                ),
              ),

              // Liste des membres
              Expanded(
                child: members.isEmpty
                    ? const Center(child: Text('Aucun membre pour le moment'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return _buildMemberCard(member);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton:
          GroupPermissions.canInviteMembers(widget.group.currentUserRole)
          ? FloatingActionButton.extended(
              onPressed: () => _showInviteMemberDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Inviter'),
            )
          : null,
    );
  }

  void _showInviteMemberDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inviter un membre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email du membre',
                hintText: 'exemple@email.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            const Text(
              'Une invitation sera envoyée à cette adresse email.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un email')),
                );
                return;
              }

              Navigator.pop(context);
              // TODO: Appeler l'API d'invitation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invitation envoyée à $email')),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final person = member['person'] as Map<String, dynamic>?;
    final role = member['role'] as String? ?? 'MEMBER';

    if (person == null) return const SizedBox.shrink();

    final prenom = person['prenom'] as String? ?? '';
    final nom = person['nom'] as String? ?? '';
    final email = person['email'] as String? ?? '';
    final fullName = '$prenom $nom'.trim();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            prenom.isNotEmpty ? prenom[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          fullName.isNotEmpty ? fullName : 'Membre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email.isNotEmpty) Text(email),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRoleLabel(role),
                style: TextStyle(
                  color: _getRoleColor(role),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: role == 'ADMIN'
            ? const Icon(Icons.verified, color: AppColors.secondary)
            : (GroupPermissions.canManageMembers(widget.group.currentUserRole)
                  ? PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'promote',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_upward, size: 18),
                              SizedBox(width: 8),
                              Text('Promouvoir'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_remove,
                                size: 18,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Retirer',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'remove') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Retirer $fullName')),
                          );
                        } else if (value == 'promote') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Promouvoir $fullName')),
                          );
                        }
                      },
                    )
                  : null),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'ADMIN':
        return 'Administrateur';
      case 'TREASURER':
        return 'Trésorier';
      case 'MEMBER':
        return 'Membre';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return AppColors.secondary;
      case 'TREASURER':
        return AppColors.primary;
      case 'MEMBER':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}
