// presentation/pages/groups/accept_invitation_page.dart - MIS À JOUR

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../core/services/invitation_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/group_service.dart';
import '../../../di/injection.dart' as di; // IMPORT AJOUTÉ

/// Page pour accepter une invitation et rejoindre un groupe
class AcceptInvitationPage extends StatefulWidget {
  final String? linkCode;

  const AcceptInvitationPage({super.key, this.linkCode});

  @override
  State<AcceptInvitationPage> createState() => _AcceptInvitationPageState();
}

class _AcceptInvitationPageState extends State<AcceptInvitationPage> {
  final TextEditingController _codeController = TextEditingController();
  late InvitationService _invitationService;
  late AuthService _authService; // MODIFIÉ
  late GroupService _groupService;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();

    // Récupérer les services depuis l'injection
    _authService = di.sl<AuthService>();
    _groupService = di.sl<GroupService>();
    _invitationService = InvitationService(client: http.Client());

    _checkAuthentication();

    if (widget.linkCode != null) {
      _codeController.text = widget.linkCode!;
    }
  }

  Future<void> _checkAuthentication() async {
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() => _isAuthenticated = isLoggedIn);

    if (!_isAuthenticated) {
      print('❌ AcceptInvitationPage - Utilisateur non authentifié');
    } else {
      print('✅ AcceptInvitationPage - Utilisateur authentifié');

      // Debug: vérifier l'état d'authentification
      await _authService.debugAuthStatus();
    }
  }

  Future<void> _acceptInvitation() async {
    if (!_isAuthenticated) {
      _showError('Veuillez vous connecter d\'abord');
      return;
    }

    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showError('Veuillez entrer un code d\'invitation');
      return;
    }

    // Vérifier le format (8 caractères alphanumériques)
    if (!RegExp(r'^[A-Z0-9]{8}$').hasMatch(code)) {
      _showError(
        'Format invalide. Le code doit contenir 8 caractères (ex: T0Y108OD)',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔵 AcceptInvitationPage - Tentative acceptation code: $code');

      final result = await _invitationService.acceptInvitation(code);

      if (result['success'] == true) {
        _showSuccess(result['message'] ?? 'Invitation acceptée avec succès');

        // Rediriger après 2 secondes
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/groups',
            (route) => false,
          );
        }
      } else {
        _showError(result['message'] ?? 'Erreur lors de l\'acceptation');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre un groupe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // Illustration
            Container(
              height: 120,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Icon(
                Icons.group_add,
                size: 80,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),

            const Text(
              'Rejoindre un groupe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              'Entrez le code d\'invitation à 8 caractères (ex: T0Y108OD)',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Champ de saisie
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Code d\'invitation',
                hintText: 'T0Y108OD',
                prefixIcon: const Icon(Icons.vpn_key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.greyLight.withOpacity(0.3),
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _acceptInvitation(),
            ),

            const SizedBox(height: 20),

            // Message d'authentification
            if (!_isAuthenticated)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vous devez être connecté pour rejoindre un groupe',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

            // Bouton principal
            ElevatedButton(
              onPressed: _isLoading || !_isAuthenticated
                  ? null
                  : _acceptInvitation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_add),
                        SizedBox(width: 8),
                        Text(
                          'Rejoindre le groupe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'À propos des codes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Format: 8 caractères majuscules/chiffres\n'
                    '• Expiration: 24 heures\n'
                    '• Exemple: T0Y108OD ou FSNFYGGQ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bouton debug
            if (_isAuthenticated)
              TextButton.icon(
                onPressed: () async {
                  await _authService.debugAuthStatus();
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Debug authentification'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
