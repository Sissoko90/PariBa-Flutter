import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../blocs/join_request/join_request_bloc.dart';
import '../../blocs/join_request/join_request_event.dart';
import '../../blocs/join_request/join_request_state.dart';
import '../../widgets/common/loading_indicator.dart';

class GroupJoinPage extends StatefulWidget {
  final String groupId;

  const GroupJoinPage({super.key, required this.groupId});

  @override
  State<GroupJoinPage> createState() => _GroupJoinPageState();
}

class _GroupJoinPageState extends State<GroupJoinPage> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les détails du groupe
    context.read<GroupBloc>().add(LoadGroupDetailsEvent(widget.groupId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre un groupe'),
        centerTitle: true,
      ),
      body: BlocConsumer<JoinRequestBloc, JoinRequestState>(
        listener: (context, state) {
          if (state is JoinRequestCreated) {
            Navigator.pop(context);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('✅ Demande envoyée'),
                content: const Text(
                  'Votre demande d\'adhésion a été envoyée avec succès. '
                  'L\'administrateur du groupe va l\'examiner et vous recevrez '
                  'une notification de sa décision.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is JoinRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, joinRequestState) {
          return BlocBuilder<GroupBloc, GroupState>(
            builder: (context, groupState) {
              if (groupState is GroupLoading) {
                return const LoadingIndicator();
              }

              if (groupState is GroupDetailsLoaded) {
                final group = groupState.group;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Carte du groupe
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.group,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.nom,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Groupe de tontine',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (group.description != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  group.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.account_balance_wallet,
                                'Montant par tour',
                                CurrencyFormatter.format(group.montant),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.calendar_today,
                                'Fréquence',
                                group.frequency,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.repeat,
                                'Nombre de tours',
                                '${group.totalTours}',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.rotate_right,
                                'Mode de rotation',
                                group.rotationMode,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Message de demande
                      const Text(
                        'Message pour l\'administrateur (optionnel)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText:
                              'Présentez-vous et expliquez pourquoi vous souhaitez rejoindre ce groupe...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 5,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 24),

                      // Bouton de demande
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: joinRequestState is JoinRequestLoading
                              ? null
                              : () => _sendJoinRequest(),
                          icon: joinRequestState is JoinRequestLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            joinRequestState is JoinRequestLoading
                                ? 'Envoi en cours...'
                                : 'Envoyer la demande',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Note d'information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Votre demande sera examinée par l\'administrateur du groupe. '
                                'Vous recevrez une notification dès qu\'une décision sera prise.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (groupState is GroupError) {
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
                        groupState.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.read<GroupBloc>().add(
                          LoadGroupDetailsEvent(widget.groupId),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _sendJoinRequest() {
    final message = _messageController.text.trim().isEmpty
        ? null
        : _messageController.text;

    context.read<JoinRequestBloc>().add(
      CreateJoinRequestEvent(widget.groupId, message: message),
    );
  }
}
