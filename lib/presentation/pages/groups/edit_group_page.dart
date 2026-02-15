import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/tontine_group_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';

/// Edit Group Page - Modifier un groupe
class EditGroupPage extends StatefulWidget {
  final TontineGroupModel group;

  const EditGroupPage({super.key, required this.group});

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
  late String _selectedFrequency;
  late String _selectedRotationMode;
  bool _isLoading = false;

  final Map<String, String> _frequencyMap = {
    'DAILY': 'Quotidien',
    'WEEKLY': 'Hebdomadaire',
    'HEBDOMADAIRE': 'Hebdomadaire',
    'BIWEEKLY': 'Bi-hebdomadaire',
    'BIHEBDOMADAIRE': 'Bi-hebdomadaire',
    'MONTHLY': 'Mensuel',
    'MENSUEL': 'Mensuel',
    'QUARTERLY': 'Trimestriel',
    'YEARLY': 'Annuel',
  };

  final List<String> _frequencies = [
    'Quotidien',
    'Hebdomadaire',
    'Bi-hebdomadaire',
    'Mensuel',
    'Trimestriel',
    'Annuel',
  ];

  final Map<String, String> _rotationModeMap = {
    'SEQUENTIAL': 'Séquentiel',
    'RANDOM': 'Aléatoire',
    'SHUFFLE': 'Mélangé',
    'CUSTOM': 'Personnalisé',
  };

  final List<String> _rotationModes = [
    'Séquentiel',
    'Aléatoire',
    'Mélangé',
    'Personnalisé',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.nom);
    _descriptionController = TextEditingController(
      text: widget.group.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.group.montant.toString(),
    );
    _graceDaysController = TextEditingController(
      text: widget.group.graceDays?.toString() ?? '',
    );
    _penaltyController = TextEditingController(
      text: widget.group.latePenaltyAmount?.toString() ?? '',
    );
    // Convertir la fréquence du backend vers le label français
    _selectedFrequency = _frequencyMap[widget.group.frequency] ?? 'Mensuel';
    // Convertir le mode de rotation du backend vers le label français
    _selectedRotationMode =
        _rotationModeMap[widget.group.rotationMode] ?? 'Séquentiel';
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

      // Convertir les labels français vers les valeurs backend
      String frequencyBackend = _frequencyMap.entries
          .firstWhere(
            (entry) => entry.value == _selectedFrequency,
            orElse: () => const MapEntry('MENSUEL', 'Mensuel'),
          )
          .key;

      String rotationModeBackend = _rotationModeMap.entries
          .firstWhere(
            (entry) => entry.value == _selectedRotationMode,
            orElse: () => const MapEntry('SEQUENTIAL', 'Séquentiel'),
          )
          .key;

      // Appeler le BLoC pour mettre à jour le groupe
      context.read<GroupBloc>().add(
        UpdateGroupEvent(
          groupId: widget.group.id,
          nom: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          montant: double.parse(_amountController.text),
          frequency: frequencyBackend,
          rotationMode: rotationModeBackend,
          latePenaltyAmount: _penaltyController.text.isEmpty
              ? null
              : double.parse(_penaltyController.text),
          graceDays: _graceDaysController.text.isEmpty
              ? null
              : int.parse(_graceDaysController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is GroupLoading) {
          // Le chargement est déjà géré par _isLoading
          return;
        }

        setState(() => _isLoading = false);

        if (state is GroupDetailsLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Groupe modifié avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(
            context,
            true,
          ); // Retourner true pour indiquer la modification
        } else if (state is GroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Modifier le groupe')),
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

                // Rotation Mode
                DropdownButtonFormField<String>(
                  value: _selectedRotationMode,
                  decoration: const InputDecoration(
                    labelText: 'Mode de rotation',
                    prefixIcon: Icon(Icons.sync),
                    border: OutlineInputBorder(),
                  ),
                  items: _rotationModes.map((mode) {
                    return DropdownMenuItem(value: mode, child: Text(mode));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedRotationMode = value!);
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
