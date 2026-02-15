import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/group_permissions.dart';
import '../../pages/payments/payment_page.dart';
import '../../pages/payments/payment_validation_page.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../blocs/membership/membership_bloc.dart';
import '../../blocs/membership/membership_event.dart';
import '../../blocs/membership/membership_state.dart';
import '../../blocs/tour/tour_bloc.dart';
import '../../blocs/tour/tour_event.dart';
import '../../blocs/tour/tour_state.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../blocs/payment/payment_event.dart';
import '../../blocs/payment/payment_state.dart';
import '../../blocs/contribution/contribution_bloc.dart';
import '../../blocs/join_request/join_request_bloc.dart';
import '../../blocs/join_request/join_request_event.dart';
import '../../blocs/join_request/join_request_state.dart';
import 'group_members_page.dart';
import 'group_invitations_page.dart';
import 'join_requests_page.dart';
import '../contributions/contributions_tracking_page.dart';
import '../../../data/models/tontine_group_model.dart';
import '../../../domain/entities/group_member.dart';
import '../../../di/injection.dart' as di;
import '../tours/tour_order_configuration_page.dart';
import 'edit_group_page.dart';

/// Group Details Page - Détails d'un groupe de tontine
class GroupDetailsPage extends StatefulWidget {
  final TontineGroupModel group;

  const GroupDetailsPage({super.key, required this.group});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late TontineGroupModel _currentGroup;

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;
    // 🔍 DEBUG: Vérifier currentUserRole
    print('🔍 GroupDetailsPage - Groupe: ${_currentGroup.nom}');
    print(
      '🔍 GroupDetailsPage - currentUserRole: ${_currentGroup.currentUserRole}',
    );
    print(
      '🔍 GroupDetailsPage - canEditGroup: ${GroupPermissions.canEditGroup(_currentGroup.currentUserRole)}',
    );
    print(
      '🔍 GroupDetailsPage - canInviteMembers: ${GroupPermissions.canInviteMembers(_currentGroup.currentUserRole)}',
    );
    print(
      '🔍 GroupDetailsPage - canDeleteGroup: ${GroupPermissions.canDeleteGroup(_currentGroup.currentUserRole)}',
    );

    // Charger les membres du groupe
    context.read<MembershipBloc>().add(LoadGroupMembersEvent(_currentGroup.id));
    // Charger le prochain tour
    context.read<TourBloc>().add(LoadNextTourEvent(_currentGroup.id));
    // Charger l'historique des paiements
    context.read<PaymentBloc>().add(LoadPaymentHistoryEvent(_currentGroup.id));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener pour les tours
        BlocListener<TourBloc, TourState>(
          listener: (context, state) {
            if (state is ToursLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ ${state.tours.length} tours générés avec succès !',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              // Recharger le prochain tour
              context.read<TourBloc>().add(LoadNextTourEvent(_currentGroup.id));
            } else if (state is TourError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Erreur: ${state.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
        // Listener pour les groupes (suppression/sortie/modification)
        BlocListener<GroupBloc, GroupState>(
          listener: (context, state) {
            if (state is GroupDetailsLoaded) {
              // Mettre à jour le groupe actuel avec les nouvelles données
              setState(() {
                _currentGroup = state.group;
              });
            } else if (state is GroupDeleted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Groupe supprimé avec succès'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is GroupLeft) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Vous avez quitté le groupe'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is GroupError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar avec design moderne
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _currentGroup.nom,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                        AppColors.secondary.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.group,
                          size: 60,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Bouton modifier - visible uniquement pour les ADMIN
                if (GroupPermissions.canEditGroup(
                  _currentGroup.currentUserRole,
                ))
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditGroupPage(group: _currentGroup),
                        ),
                      );
                      // Recharger les détails du groupe si modification réussie
                      if (result == true && mounted) {
                        context.read<GroupBloc>().add(
                          LoadGroupDetailsEvent(_currentGroup.id),
                        );
                      }
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptionsMenu(context),
                ),
              ],
            ),

            // Contenu
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Statistiques du groupe
                  _buildGroupStats(),

                  const SizedBox(height: 16),

                  // Informations principales
                  _buildInfoSection(),

                  const SizedBox(height: 16),

                  // Actions rapides
                  _buildQuickActions(context),

                  const SizedBox(height: 16),

                  // Membres
                  _buildMembersSection(context),

                  const SizedBox(height: 16),

                  // Prochains tours
                  _buildUpcomingTours(),

                  const SizedBox(height: 16),

                  // Historique des paiements
                  _buildPaymentHistory(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupStats() {
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
              _currentGroup.totalTours.toString(),
              'Tours',
              Icons.repeat,
              AppColors.primary,
            ),
          ),
          Container(height: 40, width: 1, color: AppColors.greyLight),
          Flexible(
            child: BlocBuilder<MembershipBloc, MembershipState>(
              builder: (context, state) {
                final memberCount = state is MembersLoaded
                    ? state.members.length.toString()
                    : '...';
                return _buildStatItem(
                  memberCount,
                  'Membres',
                  Icons.people,
                  AppColors.success,
                );
              },
            ),
          ),
          Container(height: 40, width: 1, color: AppColors.greyLight),
          Flexible(
            child: _buildStatItem(
              CurrencyFormatter.formatCompact(
                _currentGroup.montant * _currentGroup.totalTours,
              ),
              'Total',
              Icons.account_balance_wallet,
              AppColors.secondary,
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.account_balance_wallet,
              'Montant par tour',
              CurrencyFormatter.format(_currentGroup.montant),
            ),
            const Divider(),
            _buildInfoRow(
              Icons.calendar_today,
              'Fréquence',
              _currentGroup.frequency,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.rotate_right,
              'Mode de rotation',
              _currentGroup.rotationMode,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.event,
              'Date de début',
              _currentGroup.startDate,
            ),
            if (_currentGroup.description != null) ...[
              const Divider(),
              _buildInfoRow(
                Icons.description,
                'Description',
                _currentGroup.description!,
              ),
            ],
            if (_currentGroup.latePenaltyAmount != null) ...[
              const Divider(),
              _buildInfoRow(
                Icons.warning,
                'Pénalité de retard',
                CurrencyFormatter.format(_currentGroup.latePenaltyAmount!),
              ),
            ],
            if (_currentGroup.graceDays != null) ...[
              const Divider(),
              _buildInfoRow(
                Icons.timer,
                'Jours de grâce',
                '${_currentGroup.graceDays} jours',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
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

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Première ligne d'actions
          Row(
            children: [
              // Inviter - ADMIN uniquement
              if (GroupPermissions.canInviteMembers(
                _currentGroup.currentUserRole,
              ))
                Expanded(
                  child: _buildActionCard(
                    'Inviter',
                    Icons.person_add,
                    AppColors.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GroupInvitationsPage(group: _currentGroup),
                      ),
                    ),
                  ),
                ),
              if (GroupPermissions.canInviteMembers(
                _currentGroup.currentUserRole,
              ))
                const SizedBox(width: 12),

              // Payer - Tous les membres
              Expanded(
                child: _buildActionCard(
                  'Payer',
                  Icons.payment,
                  AppColors.success,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(group: _currentGroup),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Partager - Tous les membres
              Expanded(
                child: _buildActionCard(
                  'Partager',
                  Icons.share,
                  AppColors.info,
                  () => _shareGroup(context),
                ),
              ),
            ],
          ),

          // Deuxième ligne d'actions - ADMIN uniquement
          if (GroupPermissions.isAdmin(_currentGroup.currentUserRole)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Générer tours
                Expanded(
                  child: _buildActionCard(
                    'Générer tours',
                    Icons.autorenew,
                    AppColors.secondary,
                    () => _showGenerateToursDialog(context),
                  ),
                ),
                const SizedBox(width: 12),

                // Valider paiements
                Expanded(
                  child: _buildActionCard(
                    'Paiements',
                    Icons.check_circle,
                    AppColors.warning,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentValidationPage(
                          groupId: _currentGroup.id,
                          groupName: _currentGroup.nom,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Gérer les demandes d'adhésion
                Expanded(
                  child: _buildActionCard(
                    'Demandes',
                    Icons.person_add,
                    AppColors.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JoinRequestsPage(
                          groupId: _currentGroup.id,
                          groupName: _currentGroup.nom,
                          isAdmin: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    return BlocBuilder<MembershipBloc, MembershipState>(
      builder: (context, state) {
        if (state is MembershipLoading) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is MembershipError) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text('Erreur: ${state.message}'),
                ],
              ),
            ),
          );
        }

        final members = state is MembersLoaded ? state.members : [];
        final displayMembers = members.take(3).toList();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Membres',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupMembersPage(group: _currentGroup),
                    ),
                  ),
                  child: Text('Voir tout (${members.length})'),
                ),
              ),
              if (displayMembers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Aucun membre pour le moment'),
                )
              else
                ...displayMembers.map((member) {
                  final person = member['person'] as Map<String, dynamic>?;
                  final role = member['role'] as String? ?? 'MEMBER';

                  if (person == null) return const SizedBox.shrink();

                  final prenom = person['prenom'] as String? ?? '';
                  final nom = person['nom'] as String? ?? '';
                  final fullName = '$prenom $nom'.trim();

                  return ListTile(
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
                    title: Text(fullName.isNotEmpty ? fullName : 'Membre'),
                    subtitle: Text(_getRoleLabel(role)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Actif',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
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

  Widget _buildUpcomingTours() {
    return BlocBuilder<TourBloc, TourState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const ListTile(
                title: Text(
                  'Prochain tour',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (state is TourLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is TourEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else if (state is TourError)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Erreur: ${state.message}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                )
              else if (state is TourLoaded)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.warning.withOpacity(0.1),
                    child: const Icon(Icons.schedule, color: AppColors.warning),
                  ),
                  title: Text('Tour #${state.tour.indexInGroup}'),
                  subtitle: Text(
                    'Bénéficiaire: ${state.tour.beneficiary?.fullName ?? "Non défini"}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(state.tour.totalDue ?? 0.0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        state.tour.scheduledDate ?? 'Non planifié',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Aucun tour disponible',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentHistory() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const ListTile(
                title: Text(
                  'Historique récent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (state is PaymentsLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is PaymentsEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else if (state is PaymentError)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Erreur: ${state.message}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                )
              else if (state is PaymentHistoryLoaded)
                ...state.history.take(3).map((payment) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.success.withOpacity(0.1),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                    title: Text(
                      (payment.isPayout ?? false)
                          ? 'Paiement versé'
                          : 'Paiement reçu',
                    ),
                    subtitle: Text(
                      '${payment.tourNumber} - ${payment.formattedDate}',
                    ),
                    trailing: Text(
                      CurrencyFormatter.format(payment.amount),
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                })
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Aucun historique disponible',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Modifier - ADMIN uniquement
          if (GroupPermissions.canEditGroup(_currentGroup.currentUserRole))
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Modifier le groupe'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGroupPage(group: _currentGroup),
                  ),
                );
                // Recharger les détails du groupe si modification réussie
                if (result == true && mounted) {
                  context.read<GroupBloc>().add(
                    LoadGroupDetailsEvent(_currentGroup.id),
                  );
                }
              },
            ),

          // Inviter des membres - ADMIN uniquement
          if (GroupPermissions.canInviteMembers(_currentGroup.currentUserRole))
            ListTile(
              leading: const Icon(Icons.person_add, color: AppColors.primary),
              title: const Text('Inviter des membres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupInvitationsPage(group: _currentGroup),
                  ),
                );
              },
            ),

          // Voir les invitations - ADMIN uniquement
          if (GroupPermissions.canViewInvitations(
            _currentGroup.currentUserRole,
          ))
            ListTile(
              leading: const Icon(Icons.link, color: AppColors.primary),
              title: const Text('Gérer les invitations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupInvitationsPage(group: _currentGroup),
                  ),
                );
              },
            ),

          // Suivi des cotisations - ADMIN uniquement
          if (GroupPermissions.canValidatePayments(
            _currentGroup.currentUserRole,
          ))
            ListTile(
              leading: const Icon(Icons.assignment, color: AppColors.primary),
              title: const Text('Suivi des cotisations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => di.sl<ContributionBloc>(),
                      child: ContributionsTrackingPage(
                        groupId: _currentGroup.id,
                        groupName: _currentGroup.nom,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Quitter le groupe - Tous les membres
          if (GroupPermissions.canLeaveGroup(_currentGroup.currentUserRole))
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: AppColors.warning),
              title: const Text('Quitter le groupe'),
              onTap: () {
                Navigator.pop(context);
                _showLeaveGroupDialog(context);
              },
            ),

          // Supprimer le groupe - ADMIN uniquement
          if (GroupPermissions.canDeleteGroup(_currentGroup.currentUserRole))
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Supprimer le groupe'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteGroupDialog(context);
              },
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showGenerateToursDialog(BuildContext context) async {
    // Si le mode est CUSTOM, ouvrir la page de configuration de l'ordre
    if (_currentGroup.rotationMode == 'CUSTOM') {
      final membershipState = context.read<MembershipBloc>().state;

      if (membershipState is! MembersLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chargement des membres en cours...'),
            backgroundColor: AppColors.info,
          ),
        );
        return;
      }

      final membersData = membershipState.members;
      if (membersData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun membre dans le groupe'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Convertir les données en GroupMember
      final members = membersData
          .map((data) => GroupMember.fromJson(data))
          .toList();

      // Ouvrir la page de configuration de l'ordre
      final customOrder = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) => TourOrderConfigurationPage(
            groupId: _currentGroup.id,
            groupName: _currentGroup.nom,
            members: members,
            totalTours: _currentGroup.totalTours ?? members.length,
          ),
        ),
      );

      // Si l'utilisateur a validé, générer les tours avec l'ordre personnalisé
      if (customOrder != null) {
        _generateTours(customBeneficiaryOrder: customOrder);
      }
    } else {
      // Pour les autres modes, afficher le dialogue de confirmation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Générer les tours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Voulez-vous générer les tours pour ce groupe ?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Cela créera ${_currentGroup.totalTours} tours selon le mode de rotation configuré.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Cette action ne peut être effectuée qu\'une seule fois.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
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
                Navigator.pop(context);
                _generateTours();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text('Générer'),
            ),
          ],
        ),
      );
    }
  }

  void _generateTours({List<String>? customBeneficiaryOrder}) {
    print(
      '🔵 GroupDetailsPage - Génération des tours pour: ${_currentGroup.id}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Génération des tours en cours...'),
        backgroundColor: AppColors.info,
      ),
    );

    context.read<TourBloc>().add(
      GenerateToursEvent(
        groupId: _currentGroup.id,
        shuffle: _currentGroup.rotationMode == 'RANDOM',
        customBeneficiaryOrder: customBeneficiaryOrder,
      ),
    );
  }

  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le groupe'),
        content: const Text(
          'Êtes-vous sûr de vouloir quitter ce groupe ? Vous ne pourrez plus accéder aux informations du groupe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Quitter le groupe via le BLoC
              context.read<GroupBloc>().add(LeaveGroupEvent(_currentGroup.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le groupe'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce groupe ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Supprimer le groupe via le BLoC
              context.read<GroupBloc>().add(DeleteGroupEvent(_currentGroup.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Groupe supprimé avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _shareGroup(BuildContext context) async {
    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Générer le lien de partage
    context.read<JoinRequestBloc>().add(
      GenerateShareLinkEvent(_currentGroup.id),
    );

    // Écouter la réponse
    final subscription = context.read<JoinRequestBloc>().stream.listen((state) {
      if (state is ShareLinkGenerated) {
        Navigator.pop(context); // Fermer le loader

        // Partager via les réseaux sociaux
        Share.share(
          state.shareLink.shareText,
          subject: 'Rejoignez mon groupe ${_currentGroup.nom}',
        );
      } else if (state is JoinRequestError) {
        Navigator.pop(context); // Fermer le loader

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    // Annuler l'écoute après 10 secondes
    Future.delayed(const Duration(seconds: 10), () {
      subscription.cancel();
    });
  }
}
