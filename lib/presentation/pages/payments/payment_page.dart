// presentation/pages/payments/payment_page.dart - VERSION AMÉLIORÉE

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/tontine_group_model.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../blocs/payment/payment_event.dart';
import '../../blocs/payment/payment_state.dart';

class PaymentPage extends StatefulWidget {
  final TontineGroupModel group;

  const PaymentPage({super.key, required this.group});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transactionRefController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedPaymentMethod = 'Orange Money';

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod('Orange Money', Icons.phone_android, AppColors.secondary),
    PaymentMethod('Moov Money', Icons.phone_iphone, AppColors.info),
    PaymentMethod('Wave Money', Icons.waves, AppColors.info),
    PaymentMethod('Sama Money', Icons.currency_exchange, AppColors.warning),
    PaymentMethod(
      'Virement bancaire',
      Icons.account_balance,
      AppColors.primary,
    ),
    PaymentMethod('Espèces', Icons.money, AppColors.success),
  ];

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec le montant du groupe
    _amountController.text = widget.group.montant.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Déclarer un paiement - ${widget.group.nom}')),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            _showDeclarationConfirmation(state.message);
          }

          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Carte d'information du groupe (empruntée de MakePaymentPage)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.group,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.group.nom,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Cotisation ${widget.group.frequency}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Montant attendu:'),
                            Text(
                              CurrencyFormatter.format(widget.group.montant),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Instructions
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
                            'Instructions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Effectuez le paiement hors application\n'
                        '2. Indiquez le moyen de paiement utilisé\n'
                        '3. Saisissez la référence de transaction\n'
                        '4. L\'administrateur validera votre paiement',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Formulaire
                _buildPaymentForm(),

                const SizedBox(height: 24),

                // Info card importante
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
                        Icons.warning,
                        color: AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Information importante',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Assurez-vous d\'avoir effectué le paiement avant de valider. '
                              'Conservez votre preuve de transaction pour vérification.',
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

                // Bouton de soumission
                ElevatedButton(
                  onPressed: state is PaymentLoading ? null : _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: state is PaymentLoading
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
                            Icon(Icons.check_circle),
                            SizedBox(width: 8),
                            Text(
                              'Déclarer le paiement',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 16),

                // Message d'info
                Text(
                  'Une notification sera envoyée à l\'administrateur pour validation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Montant
        const Text(
          'Montant payé',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: 'Montant',
            hintText: 'Entrez le montant',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 16),

        // Méthode de paiement
        const Text(
          'Mode de paiement',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._paymentMethods.map((method) => _buildPaymentMethodTile(method)),

        const SizedBox(height: 16),

        // Référence de transaction
        const Text(
          'Référence de transaction (optionnel)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _transactionRefController,
          decoration: const InputDecoration(
            labelText: 'Référence',
            hintText: 'Ex: OM123456789',
            prefixIcon: Icon(Icons.receipt),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        // Notes
        const Text(
          'Notes supplémentaires (optionnel)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Informations complémentaires',
            prefixIcon: Icon(Icons.note),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.name;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        value: method.name,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          setState(() => _selectedPaymentMethod = value!);
        },
        title: Text(method.name),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: method.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(method.icon, color: method.color),
        ),
        activeColor: AppColors.primary,
        selected: isSelected,
      ),
    );
  }

  void _submitPayment() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant valide'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Convertir la méthode de paiement en enum
    final paymentType = _mapPaymentMethodToEnum(_selectedPaymentMethod);

    context.read<PaymentBloc>().add(
      DeclarePaymentEvent(
        groupId: widget.group.id,
        amount: amount,
        paymentType: paymentType,
        transactionRef: _transactionRefController.text.trim(),
        notes: _notesController.text.trim(),
      ),
    );
  }

  String _mapPaymentMethodToEnum(String method) {
    switch (method) {
      case 'Orange Money':
        return 'ORANGE_MONEY';
      case 'Moov Money':
        return 'MOOV_MONEY';
      case 'Wave Money':
        return 'WAVE_MONEY';
      case 'Sama Money':
        return 'SAMA_MONEY';
      case 'Virement bancaire':
        return 'BANK_TRANSFER';
      default:
        return 'CASH';
    }
  }

  void _showDeclarationConfirmation(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty,
                size: 50,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Paiement déclaré !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Votre paiement de ${CurrencyFormatter.format(double.parse(_amountController.text))} a été déclaré.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            const Text(
              'En attente de validation par l\'administrateur.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la boîte de dialogue
              Navigator.of(context).pop(); // Retourner à la page précédente
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionRefController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final Color color;

  PaymentMethod(this.name, this.icon, this.color);
}
