import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/group_service.dart';
import '../../../di/injection.dart' as di;
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import 'qr_scanner_page.dart';

/// Join Group Page - Rejoindre un groupe via code d'invitation
class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _groupService = di.sl<GroupService>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinGroup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await _groupService.joinGroup(
          _codeController.text.trim(),
        );

        if (mounted) {
          setState(() => _isLoading = false);

          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'Demande envoyée avec succès !',
                ),
                backgroundColor: AppColors.success,
              ),
            );

            // Recharger la liste des groupes
            context.read<GroupBloc>().add(const LoadGroupsEvent());

            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Erreur lors de la demande'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _scanQRCode() async {
    try {
      final scannedCode = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerPage()),
      );

      if (scannedCode != null && scannedCode.isNotEmpty && mounted) {
        // Remplir le champ avec le code scanné
        _codeController.text = scannedCode;

        // Rejoindre automatiquement le groupe
        _handleJoinGroup();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du scan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rejoindre un Groupe'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_add,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Rejoindre un Groupe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                'Entrez le code d\'invitation ou scannez le QR code',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Code d'invitation
              CustomTextField(
                controller: _codeController,
                label: 'Code d\'invitation',
                hint: 'Ex: ABC123XYZ',
                prefixIcon: Icons.vpn_key,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le code est requis';
                  }
                  if (value.length < 6) {
                    return 'Code invalide';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),

              const SizedBox(height: 24),

              // Bouton Rejoindre
              CustomButton(
                text: 'Rejoindre le Groupe',
                onPressed: _isLoading ? null : _handleJoinGroup,
                isLoading: _isLoading,
                icon: Icons.check_circle,
              ),

              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OU',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              // Bouton Scanner QR
              CustomButton(
                text: 'Scanner un QR Code',
                onPressed: _isLoading ? null : _scanQRCode,
                isOutlined: true,
                icon: Icons.qr_code_scanner,
              ),

              const SizedBox(height: 32),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
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
                            'Comment obtenir un code ?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Demandez au créateur du groupe de vous partager le code d\'invitation ou le QR code.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary.withOpacity(0.8),
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
      ),
    );
  }
}
