import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/services/invitation_service.dart';
import '../groups/accept_invitation_page.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';

class EnhancedNotificationsPage extends StatefulWidget {
  const EnhancedNotificationsPage({super.key});

  @override
  State<EnhancedNotificationsPage> createState() =>
      _EnhancedNotificationsPageState();
}

class _EnhancedNotificationsPageState extends State<EnhancedNotificationsPage>
    with SingleTickerProviderStateMixin {
  String _filter = 'all';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotificationsEvent());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.primary, // ✅ Couleur d'origine conservée
        foregroundColor: Colors.white,
        actions: [_buildPopupMenu()],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return _buildLoadingState();
                }

                if (state is NotificationError) {
                  return _buildErrorState(state.message);
                }

                if (state is NotificationLoaded) {
                  final filteredNotifications = _filterNotifications(
                    state.notifications,
                  );

                  if (filteredNotifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshNotifications,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = filteredNotifications[index];
                        return TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          curve: Curves.easeOut,
                          builder: (context, double opacity, child) {
                            return Opacity(
                              opacity: opacity,
                              child: _buildNotificationCard(
                                context,
                                notification,
                              ),
                            );
                          },
                        );
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

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      onSelected: (value) {
        switch (value) {
          case 'mark_all_read':
            context.read<NotificationBloc>().add(
              const MarkAllNotificationsAsReadEvent(),
            );
            _showSnackBar('Toutes les notifications marquées comme lues');
            HapticFeedback.lightImpact();
            break;
          case 'delete_all':
            _showDeleteAllDialog(context);
            break;
          case 'refresh':
            context.read<NotificationBloc>().add(
              const RefreshNotificationsEvent(),
            );
            HapticFeedback.mediumImpact();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'mark_all_read',
          child: Row(
            children: [
              Icon(Icons.done_all, color: AppColors.success, size: 20),
              SizedBox(width: 12),
              Text('Tout marquer comme lu'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete_all',
          child: Row(
            children: [
              Icon(Icons.delete_sweep, color: AppColors.error, size: 20),
              SizedBox(width: 12),
              Text('Tout supprimer', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              Icon(Icons.refresh, color: AppColors.info, size: 20),
              SizedBox(width: 12),
              Text('Actualiser'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildAnimatedFilterChip('Toutes', 'all', 0),
            const SizedBox(width: 8),
            _buildAnimatedFilterChip('Non lues', 'unread', 1),
            const SizedBox(width: 8),
            _buildAnimatedFilterChip('Lues', 'read', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedFilterChip(String label, String value, int index) {
    final isSelected = _filter == value;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: FilterChip(
            label: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _filter = value);
              HapticFeedback.lightImpact();
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: isSelected ? 4 : 0,
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 3,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des notifications...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, double opacity, child) {
            return Opacity(
              opacity: opacity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oups ! Une erreur est survenue',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                        const LoadNotificationsEvent(),
                      );
                      HapticFeedback.mediumImpact();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_off_outlined,
                        size: 80,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Aucune notification',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _filter == 'unread'
                          ? "Vous n'avez aucune notification non lue"
                          : "Vous n'avez aucune notification pour le moment",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _filter == 'unread'
                          ? "Les nouvelles notifications apparaîtront ici"
                          : "Les notifications de vos activités apparaîtront ici",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                    if (_filter != 'all') ...[
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _filter = 'all');
                          HapticFeedback.lightImpact();
                        },
                        icon: const Icon(Icons.remove_red_eye),
                        label: const Text('Voir toutes les notifications'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    final iconData = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);
    final isInvitation = notification.type.toUpperCase().contains('INVITATION');

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, double opacity, child) {
            return Opacity(
              opacity: opacity,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Supprimer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.delete, color: Colors.white),
                ],
              ),
            );
          },
        ),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.heavyImpact();
        return await _showDeleteConfirmationDialog(context);
      },
      onDismissed: (direction) {
        context.read<NotificationBloc>().add(
          DeleteNotificationEvent(notification.id),
        );
        _showSnackBar('Notification supprimée', isSuccess: false);
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: notification.readFlag
                    ? Colors.white
                    : color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (!notification.readFlag) {
                      context.read<NotificationBloc>().add(
                        MarkNotificationAsReadEvent(notification.id),
                      );
                      HapticFeedback.selectionClick();
                      _showSnackBar('Notification marquée comme lue');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icône animée
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.elasticOut,
                          builder: (context, double scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(iconData, color: color, size: 28),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),

                        // Contenu
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: TextStyle(
                                        fontWeight: notification.readFlag
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (!notification.readFlag)
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(
                                        begin: 0.5,
                                        end: 1.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.elasticOut,
                                      builder: (context, double scale, child) {
                                        return Transform.scale(
                                          scale: scale,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: color.withOpacity(0.5),
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notification.body,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: notification.readFlag
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: AppColors.textSecondary.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormatter.formatRelative(
                                      notification.createdAt,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              if (isInvitation) ...[
                                const SizedBox(height: 12),
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0.9, end: 1.0),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.elasticOut,
                                  builder: (context, double scale, child) {
                                    return Transform.scale(
                                      scale: scale,
                                      child: Row(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _handleInvitationTap(
                                                  context,
                                                  notification,
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              elevation: 2,
                                            ),
                                            icon: const Icon(
                                              Icons.check_circle,
                                              size: 16,
                                            ),
                                            label: const Text('Accepter'),
                                          ),
                                          const SizedBox(width: 12),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              if (notification.invitationCode !=
                                                  null) {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: notification
                                                        .invitationCode!,
                                                  ),
                                                );
                                                _showSnackBar('Code copié !');
                                                HapticFeedback.lightImpact();
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.info,
                                              side: BorderSide(
                                                color: AppColors.info
                                                    .withOpacity(0.5),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.copy,
                                              size: 16,
                                            ),
                                            label: const Text('Copier code'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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

  Future<void> _refreshNotifications() async {
    context.read<NotificationBloc>().add(const RefreshNotificationsEvent());
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning, size: 28),
                  SizedBox(width: 12),
                  Text('Confirmation'),
                ],
              ),
              content: const Text(
                'Voulez-vous vraiment supprimer cette notification ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Supprimer'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 28),
              SizedBox(width: 12),
              Text('Confirmer la suppression'),
            ],
          ),
          content: const Text(
            'Voulez-vous vraiment supprimer TOUTES vos notifications ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<NotificationBloc>().add(
                  const DeleteAllNotificationsEvent(),
                );
                _showSnackBar(
                  'Toutes les notifications ont été supprimées',
                  isSuccess: false,
                );
                HapticFeedback.heavyImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tout supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
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
      _showSnackBar(
        'Code d\'invitation non trouvé dans la notification',
        isSuccess: false,
      );
      return;
    }

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: _InvitationDialog(
                  invitationCode: invitationCode,
                  notificationTitle: notification.title,
                ),
              ),
            );
          },
        );
      },
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

class _InvitationDialogState extends State<_InvitationDialog>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late InvitationService _invitationService;

  @override
  void initState() {
    super.initState();
    _invitationService = InvitationService(client: http.Client());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _acceptInvitation() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await _invitationService.acceptInvitation(
        widget.invitationCode,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.of(context).pop();
        context.read<GroupBloc>().add(const LoadGroupsEvent());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result['message'] ?? 'Invitation acceptée avec succès',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

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
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'Erreur lors de l\'acceptation',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
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
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Code copié ! Redirection vers "Rejoindre un groupe"...',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );

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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  builder: (context, double scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.group_add,
                          color: AppColors.info,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Invitation de groupe',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.notificationTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Code d\'invitation :',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            widget.invitationCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.invitationCode),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Code copié !'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 1),
                            ),
                          );
                          HapticFeedback.lightImpact();
                        },
                        icon: const Icon(Icons.copy),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choisissez une action :',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Bouton Accepter directement
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.95, end: 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _acceptInvitation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle),
                              SizedBox(width: 12),
                              Text(
                                'Accepter directement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Bouton Copier et rejoindre
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.95, end: 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _copyCodeAndNavigate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: BorderSide(color: AppColors.info.withOpacity(0.5)),
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 12),
                        Text(
                          'Saisir manuellement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Bouton Annuler
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
