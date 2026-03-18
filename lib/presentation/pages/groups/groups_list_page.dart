import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_state.dart';
import '../../blocs/group/group_event.dart';
import '../../widgets/common/loading_indicator.dart';
import 'group_details_page.dart';
import 'create_group_page.dart';
import 'accept_invitation_page.dart';
import '../../../data/models/tontine_group_model.dart';

class GroupsListPage extends StatefulWidget {
  const GroupsListPage({super.key});

  @override
  State<GroupsListPage> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupBloc>().add(const LoadGroupsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is GroupDeleted ||
            state is GroupLeft ||
            state is GroupDetailsLoaded) {
          context.read<GroupBloc>().add(const LoadGroupsEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Groupes'),
          centerTitle: true,
          actions: [
            // ✅ BOUTON UNIQUE dans l'AppBar avec menu déroulant
            PopupMenuButton<String>(
              icon: const Icon(Icons.group_add),
              tooltip: 'Options de groupe',
              onSelected: (value) {
                if (value == 'create') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGroupPage(),
                    ),
                  );
                } else if (value == 'join') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AcceptInvitationPage(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'create',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text('Créer un groupe'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'join',
                  child: Row(
                    children: [
                      Icon(Icons.group_add, color: AppColors.secondary),
                      SizedBox(width: 12),
                      Text('Rejoindre un groupe'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<GroupBloc, GroupState>(
          builder: (context, state) {
            if (state is GroupLoading) {
              return const LoadingIndicator(
                message: 'Chargement des groupes...',
              );
            }

            if (state is GroupError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<GroupBloc>().add(const LoadGroupsEvent());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (state is GroupsLoaded) {
              if (state.groups.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildGroupsList(context, state.groups);
            }

            return const SizedBox.shrink();
          },
        ),
        // ❌ FLOATING ACTION BUTTON SUPPRIMÉ
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_work_outlined,
                size: 80,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Aucun groupe pour le moment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Créez votre premier groupe ou rejoignez-en un pour commencer',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Message indiquant d'utiliser le menu dans l'AppBar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Utilisez le menu + dans la barre pour créer ou rejoindre',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsList(
    BuildContext context,
    List<TontineGroupModel> groups,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GroupBloc>().add(const LoadGroupsEvent());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            shadowColor: Colors.black12,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailsPage(group: group),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.group_work,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group.nom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (group.currentUserRole != null &&
                                  group.currentUserRole == 'ADMIN') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      group.status ?? 'active',
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getStatusLabel(group.status ?? 'active'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(
                                        group.status ?? 'active',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.payments,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  CurrencyFormatter.format(group.montant),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.calendar_month,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  group.frequency,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Actif',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.people_outline,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${group.totalTours} membres',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Actif';
      case 'pending':
        return 'En attente';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}
