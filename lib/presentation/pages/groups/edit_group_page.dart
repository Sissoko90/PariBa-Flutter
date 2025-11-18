import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/tontine_group.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Edit Group Page - Modifier un groupe
class EditGroupPage extends StatefulWidget {
  final TontineGroup group;

  const EditGroupPage({
    super.key,
    required this.group,
  });

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _graceDaysController;
  late TextEditingController _penaltyController;
  String _selectedFrequency = 'Mensuel';
  bool _isLoading = false;

  final List<String> _frequencies = [
    'Hebdomadaire',
    'Bimensuel',
    'Mensuel',
    'Trimestriel',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.nom);
    _descriptionController = TextEditingController(text: widget.group.description ?? '');
    _amountController = TextEditingController(text: widget.group.montant.toString());
    _graceDaysController = TextEditingController(text: widget.group.graceDays?.toString() ?? '');
    _penaltyController = TextEditingController(text: widget.group.latePenaltyAmount?.toString() ?? '');
    _selectedFrequency = widget.group.frequency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _graceDaysController.dispose();
    _penaltyController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simuler la mise à jour
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Groupe modifié avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }

      // TODO: Implémenter l'appel API pour modifier le groupe
      // await groupRepository.updateGroup(...)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le groupe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              CustomTextField(
                controller: _nameController,
                label: 'Nom du groupe',
                hint: 'Ex: Tontine Famille',
                prefixIcon: Icons.group,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description (optionnel)',
                hint: 'Décrivez votre groupe...',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Amount
              CustomTextField(
                controller: _amountController,
                label: 'Montant par tour',
                hint: '0',
                prefixIcon: Icons.account_balance_wallet,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le montant est requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Frequency
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Fréquence',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: _frequencies.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedFrequency = value!);
                },
              ),

              const SizedBox(height: 24),

              // Penalties section
              const Text(
                'Pénalités de retard (optionnel)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _graceDaysController,
                label: 'Jours de grâce',
                hint: '0',
                prefixIcon: Icons.timer,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _penaltyController,
                label: 'Montant de la pénalité',
                hint: '0',
                prefixIcon: Icons.warning,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),

              // Warning card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: AppColors.warning,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attention',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Les modifications affecteront tous les membres du groupe. Assurez-vous d\'informer les membres avant de modifier.',
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

              const SizedBox(height: 32),

              // Update button
              CustomButton(
                text: 'Enregistrer les modifications',
                onPressed: _isLoading ? null : _handleUpdate,
                isLoading: _isLoading,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
