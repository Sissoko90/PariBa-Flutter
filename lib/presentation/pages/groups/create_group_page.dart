import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Create Group Page
class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();
  final _totalToursController = TextEditingController();
  final _graceDaysController = TextEditingController();
  final _latePenaltyController = TextEditingController();

  String _selectedFrequency = 'MENSUEL';
  String _selectedRotationMode = 'SEQUENTIAL';
  DateTime _selectedStartDate = DateTime.now().add(const Duration(days: 1));

  final List<Map<String, String>> _frequencies = [
    {'value': 'HEBDOMADAIRE', 'label': 'Hebdomadaire'},
    {'value': 'BIHEBDOMADAIRE', 'label': 'Bi-hebdomadaire'},
    {'value': 'MENSUEL', 'label': 'Mensuel'},
    {'value': 'QUARTERLY', 'label': 'Trimestriel'},
  ];

  final List<Map<String, String>> _rotationModes = [
    {'value': 'SEQUENTIAL', 'label': 'Séquentiel'},
    {'value': 'RANDOM', 'label': 'Aléatoire'},
    {'value': 'BIDDING', 'label': 'Enchères'},
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _montantController.dispose();
    _totalToursController.dispose();
    _graceDaysController.dispose();
    _latePenaltyController.dispose();
    super.dispose();
  }

  void _handleCreateGroup() {
    if (_formKey.currentState!.validate()) {
      context.read<GroupBloc>().add(
        CreateGroupEvent(
          nom: _nomController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          montant: double.parse(_montantController.text),
          frequency: _selectedFrequency,
          rotationMode: _selectedRotationMode,
          totalTours: int.parse(_totalToursController.text),
          startDate: _selectedStartDate.toIso8601String().split('T')[0],
          graceDays: _graceDaysController.text.isEmpty
              ? null
              : int.parse(_graceDaysController.text),
          latePenaltyAmount: _latePenaltyController.text.isEmpty
              ? null
              : double.parse(_latePenaltyController.text),
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un Groupe'), elevation: 0),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is GroupCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Groupe "${state.group.nom}" créé avec succès !'),
                backgroundColor: AppColors.success,
              ),
            );
            // Recharger les groupes
            context.read<GroupBloc>().add(const LoadGroupsEvent());
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is GroupLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nom du groupe
                  CustomTextField(
                    controller: _nomController,
                    label: 'Nom du groupe',
                    hint: 'Ex: Tontine Famille',
                    prefixIcon: Icons.group,
                    validator: (value) =>
                        Validators.required(value, fieldName: 'Le nom'),
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description (optionnel)',
                    hint: 'Décrivez votre groupe',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Montant
                  CustomTextField(
                    controller: _montantController,
                    label: 'Montant par tour',
                    hint: '10000',
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
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Fréquence
                  DropdownButtonFormField<String>(
                    value: _selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Fréquence',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    items: _frequencies.map((freq) {
                      return DropdownMenuItem(
                        value: freq['value'],
                        child: Text(freq['label']!),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedFrequency = value!;
                            });
                          },
                  ),

                  const SizedBox(height: 16),

                  // Mode de rotation
                  DropdownButtonFormField<String>(
                    value: _selectedRotationMode,
                    decoration: const InputDecoration(
                      labelText: 'Mode de rotation',
                      prefixIcon: Icon(Icons.rotate_right),
                    ),
                    items: _rotationModes.map((mode) {
                      return DropdownMenuItem(
                        value: mode['value'],
                        child: Text(mode['label']!),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedRotationMode = value!;
                            });
                          },
                  ),

                  const SizedBox(height: 16),

                  // Nombre de tours
                  CustomTextField(
                    controller: _totalToursController,
                    label: 'Nombre de tours',
                    hint: '12',
                    prefixIcon: Icons.repeat,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nombre de tours est requis';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Date de début
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event),
                    title: const Text('Date de début'),
                    subtitle: Text(
                      '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: isLoading ? null : _selectDate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.greyLight),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Pénalités (optionnel)
                  const Text(
                    'Pénalités (optionnel)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // Jours de grâce
                  CustomTextField(
                    controller: _graceDaysController,
                    label: 'Jours de grâce',
                    hint: '3',
                    prefixIcon: Icons.timer,
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Montant de la pénalité
                  CustomTextField(
                    controller: _latePenaltyController,
                    label: 'Montant de la pénalité',
                    hint: '1000',
                    prefixIcon: Icons.warning,
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 32),

                  // Bouton Créer
                  CustomButton(
                    text: 'Créer le Groupe',
                    onPressed: isLoading ? null : _handleCreateGroup,
                    isLoading: isLoading,
                    icon: Icons.add_circle,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
