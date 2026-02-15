// presentation/pages/payments/payment_validation_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../blocs/payment/payment_event.dart';
import '../../blocs/payment/payment_state.dart';
import '../../../domain/entities/payment.dart';

class PaymentValidationPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const PaymentValidationPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<PaymentValidationPage> createState() => _PaymentValidationPageState();
}

class _PaymentValidationPageState extends State<PaymentValidationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Charger tous les paiements du groupe
    context.read<PaymentBloc>().add(LoadGroupPaymentsEvent(widget.groupId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validation paiements - ${widget.groupName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En attente', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Validés', icon: Icon(Icons.check_circle)),
            Tab(text: 'Rejetés', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          if (state is PaymentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PaymentBloc>().add(
                        LoadGroupPaymentsEvent(widget.groupId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (state is PaymentsEmpty || state is PaymentsLoaded) {
            final allPayments = state is PaymentsLoaded
                ? state.payments
                : <Payment>[];

            // Filtrer les paiements par statut
            final pendingPayments = allPayments
                .where((p) => p.status == 'PENDING' || p.status == 'PROCESSING')
                .toList();
            final validatedPayments = allPayments
                .where(
                  (p) => p.status == 'CONFIRMED' || p.status == 'COMPLETED',
                )
                .toList();
            final rejectedPayments = allPayments
                .where((p) => p.status == 'REJECTED')
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentsList(pendingPayments, 'En attente', true),
                _buildPaymentsList(validatedPayments, 'Validés', false),
                _buildPaymentsList(rejectedPayments, 'Rejetés', false),
              ],
            );
          }

          return const Center(child: Text('Chargement...'));
        },
      ),
    );
  }

  Widget _buildPaymentsList(
    List<Payment> payments,
    String emptyMessage,
    bool showActions,
  ) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showActions ? Icons.check_circle_outline : Icons.info_outline,
              size: 80,
              color: showActions ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun paiement $emptyMessage',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              showActions
                  ? 'Tous les paiements ont été traités'
                  : 'Aucun paiement dans cette catégorie',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PaymentBloc>().add(LoadGroupPaymentsEvent(widget.groupId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(payment, showActions);
        },
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment, bool showActions) {
    Color statusColor;
    switch (payment.status) {
      case 'CONFIRMED':
      case 'COMPLETED':
        statusColor = AppColors.success;
        break;
      case 'REJECTED':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    payment.payerName ?? 'Membre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    payment.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Détails
            Row(
              children: [
                const Icon(Icons.payment, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(payment.paymentTypeLabel),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.format(payment.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            if (payment.transactionRef != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.receipt, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Ref: ${payment.transactionRef}'),
                ],
              ),
            ],

            if (payment.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${payment.notes}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            if (showActions) ...[
              const SizedBox(height: 16),
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(payment),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Rejeter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _validatePayment(payment, true),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Valider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _validatePayment(Payment payment, bool confirmed) {
    context.read<PaymentBloc>().add(
      ValidatePaymentEvent(
        paymentId: payment.id,
        confirmed: confirmed,
        notes: confirmed ? 'Paiement vérifié et validé' : null,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          confirmed ? 'Paiement validé avec succès' : 'Paiement rejeté',
        ),
        backgroundColor: confirmed ? AppColors.success : AppColors.error,
      ),
    );

    // Recharger les paiements après validation
    Future.delayed(const Duration(seconds: 1), () {
      context.read<PaymentBloc>().add(LoadGroupPaymentsEvent(widget.groupId));
    });
  }

  void _showRejectDialog(Payment payment) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rejeter le paiement de ${payment.payerName ?? "ce membre"}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison du rejet (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _validatePayment(payment, false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }
}
