import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/group_member.dart';

/// Page de configuration de l'ordre des tours
class TourOrderConfigurationPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<GroupMember> members;
  final int totalTours;

  const TourOrderConfigurationPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.totalTours,
  }) : super(key: key);

  @override
  State<TourOrderConfigurationPage> createState() =>
      _TourOrderConfigurationPageState();
}

class _TourOrderConfigurationPageState
    extends State<TourOrderConfigurationPage> {
  late List<GroupMember> orderedMembers;

  @override
  void initState() {
    super.initState();
    orderedMembers = List.from(widget.members);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordre personnalisé des tours'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Définir l\'ordre de passage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maintenez et glissez les membres pour réorganiser l\'ordre de passage des tours.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste réorganisable
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderedMembers.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = orderedMembers.removeAt(oldIndex);
                  orderedMembers.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final member = orderedMembers[index];
                return _buildMemberCard(member, index);
              },
            ),
          ),

          // Bouton de validation
          _buildValidationButton(),
        ],
      ),
    );
  }

  Widget _buildMemberCard(GroupMember member, int index) {
    return Card(
      key: ValueKey(member.personId),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Numéro du tour
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Icône de drag
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
        title: Text(
          member.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Tour ${index + 1} sur ${widget.totalTours}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: CircleAvatar(
          radius: 24,
          backgroundColor: member.photo != null
              ? Colors.transparent
              : AppColors.primary.withOpacity(0.2),
          backgroundImage: member.photo != null ? NetworkImage(member.photo!) : null,
          child: member.photo == null
              ? Text(
                  member.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildValidationButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.totalTours} tours seront créés selon cet ordre',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateAndGenerate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Générer les tours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndGenerate() {
    // Préparer l'ordre personnalisé (liste des IDs des membres)
    final customOrder = orderedMembers.map((m) => m.personId).toList();

    // Retourner l'ordre à la page précédente
    Navigator.pop(context, customOrder);
  }
}
