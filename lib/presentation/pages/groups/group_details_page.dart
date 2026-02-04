import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pariba/presentation/pages/groups/accept_invitation_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../pages/payments/payment_page.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/membership/membership_bloc.dart';
import '../../blocs/membership/membership_event.dart';
import '../../blocs/membership/membership_state.dart';
import 'group_members_page.dart';
import 'group_invitations_page.dart';
import '../../../data/models/tontine_group_model.dart';
import '../../../domain/entities/tontine_group.dart';
import '/core/services/payment_service.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../../data/models/tontine_group_model.dart';
import '../../../domain/entities/tontine_group.dart';
import '../../pages/payments/admin_payment_validation_page.dart';
import '../../pages/payments/payment_page.dart'; // Assurez-vous que cette ligne existe

/// Group Details Page - Détails d'un groupe de tontine
class GroupDetailsPage extends StatefulWidget {
  final TontineGroupModel group;

  const GroupDetailsPage({super.key, required this.group});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  String? userRole;
  int pendingPaymentsCount = 0;
  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadPendingPaymentsCount();
    // Charger les membres du groupe
    context.read<MembershipBloc>().add(LoadGroupMembersEvent(widget.group.id));
  }

  void _loadUserRole() {
    // Pour l'instant, définissez le rôle comme admin pour le test
    // Vous devrez implémenter la récupération réelle du rôle depuis le backend
    setState(() {
      userRole =
          'ADMIN'; // Changez ceci pour 'MEMBER' si l'utilisateur n'est pas admin
    });
  }

  void _loadPendingPaymentsCount() {
    // Pour l'instant, définissez un nombre fixe
    // Vous devrez implémenter la récupération réelle depuis le backend
    setState(() {
      pendingPaymentsCount = 2; // Changez ceci avec la valeur réelle
    });
  }

  TontineGroup _convertToEntity() {
    return TontineGroup(
      id: widget.group.id,
      nom: widget.group.nom,
      montant: widget.group.montant,
      frequency: widget.group.frequency,
      rotationMode: widget.group.rotationMode,
      startDate: widget.group.startDate,
      totalTours: widget.group.totalTours,
      description: widget.group.description,
      latePenaltyAmount: widget.group.latePenaltyAmount,
      graceDays: widget.group.graceDays,
      role: widget.group.role,
      status: widget.group.status ?? 'active',
      creatorPersonId: widget.group.creatorPersonId,
      createdAt: widget.group.createdAt,
      updatedAt: widget.group.updatedAt,
      isActive: (widget.group.status ?? 'active') == 'active',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec design moderne
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.group.nom,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Modifier le groupe')),
                  );
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
              widget.group.totalTours.toString(),
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
                widget.group.montant * widget.group.totalTours,
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
              CurrencyFormatter.format(widget.group.montant),
            ),
            const Divider(),
            _buildInfoRow(
              Icons.calendar_today,
              'Fréquence',
              widget.group.frequency,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.rotate_right,
              'Mode de rotation',
              widget.group.rotationMode,
            ),
            const Divider(),
            _buildInfoRow(Icons.event, 'Date de début', widget.group.startDate),
            if (widget.group.description != null) ...[
              const Divider(),
              _buildInfoRow(
                Icons.description,
                'Description',
                widget.group.description!,
              ),
            ],
            if (widget.group.latePenaltyAmount != null) ...[
              const Divider(),
              _buildInfoRow(
                Icons.warning,
                'Pénalité de retard',
                CurrencyFormatter.format(widget.group.latePenaltyAmount!),
              ),
            ],
            if (widget.group.graceDays != null) ...[
              const Divider(),
              _buildInfoRow(
                Icons.timer,
                'Jours de grâce',
                '${widget.group.graceDays} jours',
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
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Inviter',
                  Icons.person_add,
                  AppColors.primary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupInvitationsPage(group: widget.group),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Payer',
                  Icons.payment,
                  AppColors.success,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(group: widget.group),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Partager',
                  Icons.share,
                  AppColors.info,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Partager le groupe')),
                    );
                  },
                ),
              ),
            ],
          ),
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
                          GroupMembersPage(group: widget.group),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const ListTile(
            title: Text(
              'Prochains tours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.warning.withOpacity(0.1),
              child: const Icon(Icons.schedule, color: AppColors.warning),
            ),
            title: const Text('Tour #4'),
            subtitle: const Text('Bénéficiaire: Abdoulaye Diallo'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(widget.group.montant),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  '25 Nov 2025',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
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
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.success.withOpacity(0.1),
              child: const Icon(Icons.check_circle, color: AppColors.success),
            ),
            title: const Text('Paiement reçu'),
            subtitle: const Text('Tour #3 - 15 Nov 2025'),
            trailing: Text(
              CurrencyFormatter.format(widget.group.montant),
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.success.withOpacity(0.1),
              child: const Icon(Icons.check_circle, color: AppColors.success),
            ),
            title: const Text('Paiement reçu'),
            subtitle: const Text('Tour #2 - 15 Oct 2025'),
            trailing: Text(
              CurrencyFormatter.format(widget.group.montant),
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
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
          ListTile(
            leading: const Icon(Icons.group_add, color: AppColors.primary),
            title: const Text('Rejoindre un groupe'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AcceptInvitationPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.primary),
            title: const Text('Modifier le groupe'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Modifier le groupe')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive, color: AppColors.warning),
            title: const Text('Archiver'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Archiver le groupe')),
              );
            },
          ),
          if (userRole == 'ADMIN' || userRole == 'CREATOR')
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment, color: AppColors.warning),
              ),
              title: const Text('Valider les paiements'),
              subtitle: const Text('Gérer les paiements en attente'),
              trailing: Badge(
                label: Text('$pendingPaymentsCount'),
                backgroundColor: AppColors.warning,
                isLabelVisible: pendingPaymentsCount > 0,
                child: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                final groupEntity = _convertToEntity();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) =>
                          PaymentBloc(paymentService: PaymentService()),
                      child: AdminPaymentValidationPage(group: groupEntity),
                    ),
                  ),
                );
              },
            ),

          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.error),
            title: const Text('Quitter le groupe'),
            onTap: () {
              Navigator.pop(context);
              _showLeaveGroupDialog(context);
            },
          ),
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
              context.read<GroupBloc>().add(LeaveGroupEvent(widget.group.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vous avez quitté le groupe')),
              );
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
              context.read<GroupBloc>().add(DeleteGroupEvent(widget.group.id));
              Navigator.pop(context);
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
}
