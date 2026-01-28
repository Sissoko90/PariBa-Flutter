// presentation/pages/groups/group_invitations_page.dart - CORRIGÉ

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../data/models/tontine_group_model.dart';
import '../../../core/services/invitation_service.dart';
import '../../../domain/entities/invitation.dart';
import '../../../core/services/auth_service.dart';

/// Group Invitations Page - Gérer les invitations d'un groupe
class GroupInvitationsPage extends StatefulWidget {
  final TontineGroupModel group;

  const GroupInvitationsPage({super.key, required this.group});

  @override
  State<GroupInvitationsPage> createState() => _GroupInvitationsPageState();
}

class _GroupInvitationsPageState extends State<GroupInvitationsPage> {
  late InvitationService _invitationService;

  List<Invitation> _pendingInvitations = [];
  bool _isLoading = false;
  bool _isInviting = false;
  bool _isGeneratingLink = false; // Ajouté pour générer un lien
  String? _activeInvitationCode; // Code d'invitation actif
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _invitationService = InvitationService(client: http.Client());
    _loadPendingInvitations();
  }

  Future<void> _loadPendingInvitations() async {
    setState(() => _isLoading = true);
    try {
      _pendingInvitations = await _invitationService.getGroupInvitations(
        widget.group.id,
      );

      // Si des invitations existent, utiliser le premier code
      if (_pendingInvitations.isNotEmpty) {
        setState(() {
          _activeInvitationCode = _pendingInvitations.first.linkCode;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
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

  /// Générer un nouveau code d'invitation
  Future<void> _generateInvitationLink() async {
    setState(() => _isGeneratingLink = true);

    try {
      // Créer une invitation générique pour obtenir un code
      final result = await _invitationService.inviteMember(
        groupId: widget.group.id,
        email: 'invitation@pariba.app', // Email générique
        phone: null,
      );

      if (result['success'] == true && result['data'] != null) {
        final invitationData = result['data'] as Map<String, dynamic>;
        final linkCode = invitationData['linkCode'] as String?;

        if (linkCode != null) {
          setState(() => _activeInvitationCode = linkCode);

          // Recharger la liste
          await _loadPendingInvitations();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nouveau code généré: $linkCode'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de génération: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isGeneratingLink = false);
    }
  }

  Future<void> _sendInvitation() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty && phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un email ou un numéro de téléphone'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isInviting = true);

    final result = await _invitationService.inviteMember(
      groupId: widget.group.id,
      email: email.isNotEmpty ? email : '',
      phone: phone.isNotEmpty ? phone : null,
    );

    setState(() => _isInviting = false);

    if (result['success'] == true) {
      // Vider les champs
      _emailController.clear();
      _phoneController.clear();

      // Recharger la liste des invitations
      await _loadPendingInvitations();

      // Afficher le message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser le code réel ou le code généré localement
    final displayCode =
        _activeInvitationCode ??
        'GRP${widget.group.id.substring(0, 6).toUpperCase()}';

    return Scaffold(
      appBar: AppBar(title: const Text('Inviter des membres')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Code d'invitation
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.vpn_key,
                            size: 60,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Code d\'invitation du groupe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.group.nom,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  displayCode,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (_activeInvitationCode == null)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      '(Code généré localement)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Bouton Copier
                              ElevatedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: displayCode),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Code copié dans le presse-papiers',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Copier'),
                              ),
                              const SizedBox(width: 12),
                              // Bouton Générer
                              ElevatedButton.icon(
                                onPressed: _isGeneratingLink
                                    ? null
                                    : _generateInvitationLink,
                                icon: _isGeneratingLink
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.refresh),
                                label: const Text('Générer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Formulaire d'invitation
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inviter par email ou téléphone',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'email@example.com',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone (optionnel)',
                              hintText: '+223 50 18 39 20',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isInviting ? null : _sendInvitation,
                            icon: _isInviting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(
                              _isInviting
                                  ? 'Envoi en cours...'
                                  : 'Envoyer l\'invitation',
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Partager le lien
                  if (_activeInvitationCode != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Partager le lien',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'https://pariba.app/join/$_activeInvitationCode',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildShareButton(
                                    'WhatsApp',
                                    Icons.message,
                                    AppColors.success,
                                    () {
                                      final message =
                                          "🎉 Vous êtes invité à rejoindre le groupe *${widget.group.nom}* sur Pariba!\n\n"
                                          "Cliquez sur ce lien pour rejoindre: https://pariba.app/join/$_activeInvitationCode\n\n"
                                          "⏰ Ce lien expire dans 24h";
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Prêt à partager sur WhatsApp',
                                          ),
                                          action: SnackBarAction(
                                            label: 'Partager',
                                            onPressed: () {
                                              // TODO: Implémenter le partage WhatsApp
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildShareButton(
                                    'Copier lien',
                                    Icons.link,
                                    AppColors.info,
                                    () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              'https://pariba.app/join/$_activeInvitationCode',
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Lien copié'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Invitations en attente
                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Invitations en attente',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _loadPendingInvitations,
                                tooltip: 'Actualiser',
                              ),
                            ],
                          ),
                        ),
                        if (_pendingInvitations.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.group_off,
                                  size: 60,
                                  color: AppColors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Aucune invitation en attente',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._pendingInvitations.map((invitation) {
                            return _buildPendingInvitationItem(invitation);
                          }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info card
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Comment inviter ?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.info,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '1. Partagez le code: $_activeInvitationCode\n'
                                '2. Ou partagez le lien d\'invitation\n'
                                '3. Ou entrez directement l\'email/téléphone',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary.withOpacity(
                                    0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildShareButton(
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

  Widget _buildPendingInvitationItem(Invitation invitation) {
    String timeAgo = _getTimeAgo(invitation.createdAt);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.warning.withOpacity(0.1),
        child: Text(
          invitation.targetEmail?[0] ?? invitation.targetPhone?[0] ?? '?',
          style: const TextStyle(
            color: AppColors.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(invitation.targetEmail ?? invitation.targetPhone ?? 'Invité'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Code: ${invitation.linkCode}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          Text(
            timeAgo,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(
            invitation.status ?? 'PENDING',
          ).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _getStatusLabel(invitation.status ?? 'PENDING'),
          style: TextStyle(
            fontSize: 10,
            color: _getStatusColor(invitation.status ?? 'PENDING'),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.warning;
      case 'ACCEPTED':
        return AppColors.success;
      case 'EXPIRED':
        return AppColors.error;
      case 'DECLINED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'ACCEPTED':
        return 'Acceptée';
      case 'EXPIRED':
        return 'Expirée';
      case 'DECLINED':
        return 'Refusée';
      default:
        return status;
    }
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'Date inconnue';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
