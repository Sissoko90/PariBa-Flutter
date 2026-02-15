import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/join_request.dart';
import '../../blocs/join_request/join_request_bloc.dart';
import '../../blocs/join_request/join_request_event.dart';
import '../../blocs/join_request/join_request_state.dart';
import '../../widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

class JoinRequestsPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final bool isAdmin;

  const JoinRequestsPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.isAdmin,
  });

  @override
  State<JoinRequestsPage> createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    if (widget.isAdmin) {
      context.read<JoinRequestBloc>().add(LoadGroupJoinRequestsEvent(widget.groupId));
    } else {
      context.read<JoinRequestBloc>().add(const LoadMyJoinRequestsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Demandes d\'adhésion' : 'Mes demandes'),
        centerTitle: true,
      ),
      body: BlocConsumer<JoinRequestBloc, JoinRequestState>(
        listener: (context, state) {
          if (state is JoinRequestReviewed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Demande traitée avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
            _loadRequests();
          } else if (state is JoinRequestCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Demande annulée'),
                backgroundColor: AppColors.success,
              ),
            );
            _loadRequests();
          } else if (state is JoinRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is JoinRequestLoading) {
            return const LoadingIndicator();
          }

          if (state is JoinRequestsLoaded) {
            final requests = state.joinRequests;

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isAdmin
                          ? 'Aucune demande d\'adhésion'
                          : 'Vous n\'avez aucune demande en cours',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadRequests(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildRequestCard(request);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRequestCard(JoinRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    request.personName.isNotEmpty
                        ? request.personName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.personName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.personPhone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(request.status),
              ],
            ),
            if (request.message != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.message!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Demandé le ${DateFormat('dd/MM/yyyy à HH:mm').format(request.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (request.reviewedBy != null) ...[
              const SizedBox(height: 8),
              Text(
                'Traité par ${request.reviewedBy} le ${DateFormat('dd/MM/yyyy à HH:mm').format(request.reviewedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (request.reviewNote != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: request.isApproved
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.reviewNote!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ],
            if (request.isPending) ...[
              const SizedBox(height: 12),
              if (widget.isAdmin)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showApproveDialog(request),
                        icon: const Icon(Icons.check),
                        label: const Text('Approuver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(request),
                        icon: const Icon(Icons.close),
                        label: const Text('Rejeter'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelRequest(request.id),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Annuler la demande'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'PENDING':
        color = AppColors.warning;
        label = 'En attente';
        icon = Icons.schedule;
        break;
      case 'APPROVED':
        color = AppColors.success;
        label = 'Approuvée';
        icon = Icons.check_circle;
        break;
      case 'REJECTED':
        color = AppColors.error;
        label = 'Rejetée';
        icon = Icons.cancel;
        break;
      case 'CANCELLED':
        color = Colors.grey;
        label = 'Annulée';
        icon = Icons.block;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(JoinRequest request) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approuver la demande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Approuver ${request.personName} ?'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
                hintText: 'Bienvenue dans le groupe !',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              context.read<JoinRequestBloc>().add(
                    ApproveJoinRequestEvent(
                      request.id,
                      note: noteController.text.isEmpty
                          ? null
                          : noteController.text,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Approuver'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(JoinRequest request) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter la demande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rejeter ${request.personName} ?'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Raison (optionnel)',
                hintText: 'Le groupe est complet...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              context.read<JoinRequestBloc>().add(
                    RejectJoinRequestEvent(
                      request.id,
                      note: noteController.text.isEmpty
                          ? null
                          : noteController.text,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  void _cancelRequest(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la demande'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette demande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<JoinRequestBloc>().add(CancelJoinRequestEvent(requestId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }
}
