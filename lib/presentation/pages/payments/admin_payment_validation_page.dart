import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/tontine_group.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../blocs/payment/payment_event.dart';
import '../../blocs/payment/payment_state.dart';

class AdminPaymentValidationPage extends StatefulWidget {
  final TontineGroup group;

  const AdminPaymentValidationPage({super.key, required this.group});

  @override
  State<AdminPaymentValidationPage> createState() =>
      _AdminPaymentValidationPageState();
}

class _AdminPaymentValidationPageState
    extends State<AdminPaymentValidationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingPayments();
    });
  }

  void _loadPendingPayments() {
    context.read<PaymentBloc>().add(LoadPendingPaymentsEvent(widget.group.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation des paiements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingPayments,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugState,
            tooltip: 'Déboguer',
          ),
        ],
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          print(
            '🔄 AdminPaymentValidationPage - Nouvel état: ${state.runtimeType}',
          );
          if (state is PaymentValidated) {
            _showValidationSuccess(state.payment);
            // Recharger la liste après validation
            Future.delayed(const Duration(seconds: 2), _loadPendingPayments);
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
          print(
            '🏗️ AdminPaymentValidationPage - Builder appelé avec état: ${state.runtimeType}',
          );

          if (state is PaymentsLoading) {
            print('🏗️ Affichage du loading state');
            return _buildLoadingState();
          }

          if (state is PaymentError) {
            print('🏗️ Affichage de l\'erreur: ${state.message}');
            return _buildErrorState(state.message);
          }

          if (state is PaymentsLoaded) {
            final pendingPayments = state.pendingPayments;
            print(
              '🏗️ PaymentsLoaded - ${pendingPayments.length} paiements en attente',
            );

            if (pendingPayments.isEmpty) {
              print('🏗️ Aucun paiement en attente');
              return _buildEmptyState();
            }

            print(
              '🏗️ Construction de la liste avec ${pendingPayments.length} éléments',
            );
            return _buildPaymentsList(pendingPayments);
          }

          if (state is PaymentsEmpty) {
            print('🏗️ PaymentsEmpty: ${state.message}');
            return _buildEmptyStateWithMessage(state.message);
          }

          print('🏗️ État initial ou inconnu');
          return _buildInitialState();
        },
      ),
    );
  }

  Widget _buildEmptyStateWithMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: AppColors.success),
          const SizedBox(height: 20),
          const Text(
            'Aucun paiement en attente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadPendingPayments,
            icon: const Icon(Icons.refresh),
            label: const Text('Rafraîchir'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des paiements...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadPendingPayments,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: AppColors.success),
          const SizedBox(height: 20),
          const Text(
            'Aucun paiement en attente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Tous les paiements du groupe "${widget.group.nom}" ont été validés.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement...'),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<Payment> payments) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadPendingPayments();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom du membre et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.payerName ?? 'Membre',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (payment.payer != null)
                        Text(
                          _getPayerPhone(payment.payer!) ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'En attente',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Détails du paiement
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Montant',
              value: CurrencyFormatter.format(payment.amount),
              color: AppColors.success,
            ),

            const SizedBox(height: 8),

            _buildDetailRow(
              icon: Icons.payment,
              label: 'Méthode',
              value: payment.paymentTypeLabel,
              color: AppColors.primary,
            ),

            if (payment.transactionRef != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.receipt,
                label: 'Référence',
                value: payment.transactionRef!,
                color: AppColors.info,
              ),
            ],

            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: _formatDate(payment.createdAt),
              color: AppColors.secondary,
            ),

            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes du membre:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.notes!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],

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
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _getPayerPhone(Map<String, dynamic> payer) {
    return payer['phone'] as String?;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _validatePayment(Payment payment, bool confirmed) {
    context.read<PaymentBloc>().add(
      ValidatePaymentEvent(
        paymentId: payment.id,
        confirmed: confirmed,
        notes: confirmed ? 'Paiement vérifié et validé' : null,
      ),
    );
  }

  void _debugState() {
    final state = context.read<PaymentBloc>().state;
    print('🐛 État actuel du PaymentBloc: ${state.runtimeType}');

    if (state is PaymentsLoaded) {
      print('🐛 Payments chargés: ${state.payments.length}');
      print('🐛 Payments en attente: ${state.pendingPayments.length}');

      for (var i = 0; i < state.pendingPayments.length; i++) {
        final payment = state.pendingPayments[i];
        print(
          '🐛 Payment $i: ${payment.id}, ${payment.payerName}, ${payment.amount}, ${payment.status}',
        );
      }
    } else if (state is PaymentsEmpty) {
      print('🐛 Message empty: ${state.message}');
    } else if (state is PaymentError) {
      print('🐛 Erreur: ${state.message}');
    }
  }

  void _showRejectDialog(Payment payment) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rejeter le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir rejeter le paiement de ${payment.payerName ?? "ce membre"} ?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Raison du rejet (optionnel):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Ex: Référence incorrecte, montant erroné...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _validatePayment(payment, false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  void _showValidationSuccess(Payment payment) {
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
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                payment.isConfirmed ? Icons.check_circle : Icons.close,
                size: 50,
                color: payment.isConfirmed
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              payment.isConfirmed ? 'Paiement validé !' : 'Paiement rejeté !',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              payment.isConfirmed
                  ? 'Le paiement de ${payment.payerName ?? "ce membre"} a été validé avec succès.'
                  : 'Le paiement a été rejeté.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 48),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}
