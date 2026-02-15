import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/services/payment_service.dart';
import '../../../domain/entities/payment.dart';
import '../../../di/injection.dart' as di;

/// Page d'historique des paiements personnels
class MyPaymentsHistoryPage extends StatefulWidget {
  const MyPaymentsHistoryPage({super.key});

  @override
  State<MyPaymentsHistoryPage> createState() => _MyPaymentsHistoryPageState();
}

class _MyPaymentsHistoryPageState extends State<MyPaymentsHistoryPage> {
  final _paymentService = di.sl<PaymentService>();
  bool _isLoading = true;
  List<Payment> _payments = [];
  String _selectedFilter = 'ALL'; // ALL, PENDING, CONFIRMED, REJECTED

  @override
  void initState() {
    super.initState();
    _loadMyPayments();
  }

  Future<void> _loadMyPayments() async {
    setState(() => _isLoading = true);

    try {
      final result = await _paymentService.getMyPayments();

      if (mounted) {
        final paymentsData = result['data'] as List? ?? [];
        setState(() {
          _payments = paymentsData
              .map((json) => Payment.fromJson(json))
              .toList();
          _isLoading = false;
        });

        // Afficher un message informatif seulement si nécessaire
        if (result['success'] != true && result['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: AppColors.info,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _payments = [];
          _isLoading = false;
        });
        // Ne pas afficher d'erreur rouge, juste un message informatif
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de charger les paiements pour le moment'),
            backgroundColor: AppColors.info,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  List<Payment> get _filteredPayments {
    if (_selectedFilter == 'ALL') return _payments;
    return _payments.where((p) => p.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Paiements'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyPayments,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildStatsSummary(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPayments.isEmpty
                ? _buildEmptyState()
                : _buildPaymentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tous', 'ALL', Icons.list),
            const SizedBox(width: 8),
            _buildFilterChip('En attente', 'PENDING', Icons.pending),
            const SizedBox(width: 8),
            _buildFilterChip('Confirmés', 'CONFIRMED', Icons.check_circle),
            const SizedBox(width: 8),
            _buildFilterChip('Rejetés', 'REJECTED', Icons.cancel),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatsSummary() {
    final total = _payments.length;
    final pending = _payments.where((p) => p.isPending).length;
    final confirmed = _payments.where((p) => p.isConfirmed).length;
    final totalAmount = _payments.fold<double>(0, (sum, p) => sum + p.amount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', total.toString(), Icons.payments),
          _buildStatItem('En attente', pending.toString(), Icons.pending),
          _buildStatItem('Confirmés', confirmed.toString(), Icons.check_circle),
          _buildStatItem(
            'Montant',
            CurrencyFormatter.formatCompact(totalAmount),
            Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun paiement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'ALL'
                ? 'Vous n\'avez effectué aucun paiement'
                : 'Aucun paiement ${_getFilterLabel()}',
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case 'PENDING':
        return 'en attente';
      case 'CONFIRMED':
        return 'confirmé';
      case 'REJECTED':
        return 'rejeté';
      default:
        return '';
    }
  }

  Widget _buildPaymentsList() {
    return RefreshIndicator(
      onRefresh: _loadMyPayments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPayments.length,
        itemBuilder: (context, index) {
          final payment = _filteredPayments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPaymentDetails(payment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: payment.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      payment.statusIcon,
                      color: payment.statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.groupName ?? 'Groupe inconnu',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormatter.formatRelative(payment.createdAt),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(payment.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: payment.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          payment.statusLabel,
                          style: TextStyle(
                            color: payment.statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _getPaymentIcon(payment.paymentType),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    payment.paymentTypeLabel,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String paymentType) {
    switch (paymentType) {
      case 'ORANGE_MONEY':
      case 'MOOV_MONEY':
      case 'WAVE_MONEY':
      case 'SAMA_MONEY':
        return Icons.phone_android;
      case 'BANK_TRANSFER':
        return Icons.account_balance;
      case 'CASH':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  void _showPaymentDetails(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: payment.statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    payment.statusIcon,
                    size: 48,
                    color: payment.statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  payment.statusLabel,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: payment.statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Groupe', payment.groupName ?? 'N/A'),
              _buildDetailRow(
                'Montant',
                CurrencyFormatter.format(payment.amount),
              ),
              _buildDetailRow('Mode de paiement', payment.paymentTypeLabel),
              _buildDetailRow(
                'Date',
                DateFormatter.formatDateTime(payment.createdAt),
              ),
              if (payment.notes != null && payment.notes!.isNotEmpty)
                _buildDetailRow('Notes', payment.notes!),
              if (payment.validatedAt != null)
                _buildDetailRow(
                  'Validé le',
                  DateFormatter.formatDateTime(payment.validatedAt!),
                ),
              if (payment.adminNotes != null && payment.adminNotes!.isNotEmpty)
                _buildDetailRow('Notes admin', payment.adminNotes!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
