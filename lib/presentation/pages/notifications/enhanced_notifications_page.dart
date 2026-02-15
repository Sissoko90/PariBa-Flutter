import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/services/invitation_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../groups/accept_invitation_page.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';

class EnhancedNotificationsPage extends StatefulWidget {
  const EnhancedNotificationsPage({super.key});

  @override
  State<EnhancedNotificationsPage> createState() =>
      _EnhancedNotificationsPageState();
}

class _EnhancedNotificationsPageState extends State<EnhancedNotificationsPage> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  context.read<NotificationBloc>().add(
                    const MarkAllNotificationsAsReadEvent(),
                  );
                  break;
                case 'delete_all':
                  _showDeleteAllDialog(context);
                  break;
                case 'refresh':
                  context.read<NotificationBloc>().add(
                    const RefreshNotificationsEvent(),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all),
                    SizedBox(width: 8),
                    Text('Tout marquer comme lu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(
                      'Tout supprimer',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Actualiser'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NotificationError) {
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
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<NotificationBloc>().add(
                              const LoadNotificationsEvent(),
                            );
                          },
                          child: const Text(AppConstants.notificationRetry),
                        ),
                      ],
                    ),
                  );
                }

                if (state is NotificationLoaded) {
                  final filteredNotifications = _filterNotifications(
                    state.notifications,
                  );

                  if (filteredNotifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NotificationBloc>().add(
                        const RefreshNotificationsEvent(),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = filteredNotifications[index];
                        return _buildNotificationCard(context, notification);
                      },
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(AppConstants.notificationFilterAll, 'all'),
          const SizedBox(width: 8),
          _buildFilterChip(AppConstants.notificationFilterUnread, 'unread'),
          const SizedBox(width: 8),
          _buildFilterChip(AppConstants.notificationFilterRead, 'read'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> notifications,
  ) {
    switch (_filter) {
      case 'unread':
        return notifications.where((n) => !n.readFlag).toList();
      case 'read':
        return notifications.where((n) => n.readFlag).toList();
      default:
        return notifications;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            AppConstants.notificationEmptyTitle,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _filter == 'unread'
                ? AppConstants.notificationEmptyUnread
                : AppConstants.notificationEmptyAll,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    final iconData = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmer la suppression'),
              content: const Text(
                'Voulez-vous vraiment supprimer cette notification ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Supprimer'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<NotificationBloc>().add(
          DeleteNotificationEvent(notification.id),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification supprimée'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.readFlag ? null : color.withOpacity(0.05),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(iconData, color: color),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.readFlag
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.body),
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatRelative(notification.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              // Bouton d'action pour les invitations
              if (notification.type.toUpperCase().contains('INVITATION')) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          _handleInvitationTap(context, notification),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                      ),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text(
                        'Rejoindre',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: !notification.readFlag
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            if (!notification.readFlag) {
              context.read<NotificationBloc>().add(
                MarkNotificationAsReadEvent(notification.id),
              );
            }
          },
        ),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
            'Voulez-vous vraiment supprimer toutes les notifications ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<NotificationBloc>().add(
                  const DeleteAllNotificationsEvent(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Toutes les notifications ont été supprimées',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Tout supprimer'),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'PAYMENT_SUCCESS':
      case 'PAYMENT_RECEIVED':
        return Icons.payment;
      case 'REMINDER_DUE':
      case 'PAYMENT_DUE':
        return Icons.schedule;
      case 'GROUP_INVITATION':
        return Icons.group_add;
      case 'TOUR_COMPLETED':
        return Icons.check_circle;
      case 'SYSTEM_UPDATE':
      case 'SYSTEM_ANNOUNCEMENT':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toUpperCase()) {
      case 'PAYMENT_SUCCESS':
      case 'PAYMENT_RECEIVED':
      case 'TOUR_COMPLETED':
        return AppColors.success;
      case 'REMINDER_DUE':
      case 'PAYMENT_DUE':
        return AppColors.warning;
      case 'GROUP_INVITATION':
      case 'SYSTEM_UPDATE':
        return AppColors.info;
      case 'SYSTEM_ANNOUNCEMENT':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  void _handleInvitationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    final invitationCode = notification.invitationCode;

    if (invitationCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code d\'invitation non trouvé dans la notification'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => _InvitationDialog(
        invitationCode: invitationCode,
        notificationTitle: notification.title,
      ),
    );
  }
}

class _InvitationDialog extends StatefulWidget {
  final String invitationCode;
  final String notificationTitle;

  const _InvitationDialog({
    required this.invitationCode,
    required this.notificationTitle,
  });

  @override
  State<_InvitationDialog> createState() => _InvitationDialogState();
}

class _InvitationDialogState extends State<_InvitationDialog> {
  bool _isLoading = false;
  late InvitationService _invitationService;

  @override
  void initState() {
    super.initState();
    _invitationService = InvitationService(client: http.Client());
  }

  Future<void> _acceptInvitation() async {
    setState(() => _isLoading = true);

    try {
      final result = await _invitationService.acceptInvitation(
        widget.invitationCode,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.of(context).pop();

        // Recharger la liste des groupes
        context.read<GroupBloc>().add(const LoadGroupsEvent());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Invitation acceptée avec succès',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Rediriger vers la page des groupes après 1 seconde
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/groups',
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Erreur lors de l\'acceptation',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _copyCodeAndNavigate() {
    Clipboard.setData(ClipboardData(text: widget.invitationCode));
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copié! Redirection vers "Rejoindre un groupe"...'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    // Naviguer vers la page AcceptInvitationPage avec le code pré-rempli
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AcceptInvitationPage(linkCode: widget.invitationCode),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.group_add, color: AppColors.info),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Invitation de groupe', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.notificationTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greyLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.vpn_key,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.invitationCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.invitationCode),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copié dans le presse-papiers'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: 'Copier le code',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choisissez une action :',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton Accepter directement
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _acceptInvitation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: const Text('Accepter directement'),
            ),
            const SizedBox(height: 8),
            // Bouton Copier et rejoindre
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _copyCodeAndNavigate,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: const BorderSide(color: AppColors.info),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.edit),
              label: const Text('Saisir manuellement'),
            ),
            const SizedBox(height: 8),
            // Bouton Annuler
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
}
