import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Notifications Page
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications data
    final notifications = [
      {
        'title': 'Nouveau paiement reçu',
        'message': 'Votre paiement de 50,000 FCFA a été confirmé',
        'time': 'Il y a 2 heures',
        'icon': Icons.payment,
        'color': AppColors.success,
        'read': false,
      },
      {
        'title': 'Rappel de cotisation',
        'message': 'Votre cotisation pour "Tontine Famille" est due dans 3 jours',
        'time': 'Il y a 5 heures',
        'icon': Icons.schedule,
        'color': AppColors.warning,
        'read': false,
      },
      {
        'title': 'Invitation à un groupe',
        'message': 'Abdoulaye vous a invité à rejoindre "Tontine Amis"',
        'time': 'Hier',
        'icon': Icons.group_add,
        'color': AppColors.info,
        'read': true,
      },
      {
        'title': 'Tour complété',
        'message': 'Le tour #3 de "Tontine Bureau" est terminé',
        'time': 'Il y a 2 jours',
        'icon': Icons.check_circle,
        'color': AppColors.success,
        'read': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les notifications marquées comme lues'),
                ),
              );
            },
            tooltip: 'Tout marquer comme lu',
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationCard(
                  context,
                  notif['title'] as String,
                  notif['message'] as String,
                  notif['time'] as String,
                  notif['icon'] as IconData,
                  notif['color'] as Color,
                  notif['read'] as bool,
                );
              },
            ),
    );
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
            'Aucune notification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous n\'avez pas de nouvelles notifications',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
    bool isRead,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isRead ? null : color.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: !isRead
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
          // TODO: Navigate to notification details
        },
      ),
    );
  }
}
