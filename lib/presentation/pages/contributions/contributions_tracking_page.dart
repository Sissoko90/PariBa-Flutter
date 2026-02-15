import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/services/export_service.dart';
import '../../../domain/entities/contribution.dart';
import '../../blocs/contribution/contribution_bloc.dart';
import '../../blocs/contribution/contribution_event.dart';
import '../../blocs/contribution/contribution_state.dart';

/// Page de suivi des cotisations par tour pour l'ADMIN
class ContributionsTrackingPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ContributionsTrackingPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ContributionsTrackingPage> createState() =>
      _ContributionsTrackingPageState();
}

class _ContributionsTrackingPageState extends State<ContributionsTrackingPage> {
  String? _selectedTourId;

  @override
  void initState() {
    super.initState();
    // Charger les contributions du groupe
    context.read<ContributionBloc>().add(
      LoadGroupContributionsEvent(widget.groupId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotisations - ${widget.groupName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
            tooltip: 'Exporter en PDF',
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: _exportToExcel,
            tooltip: 'Exporter en Excel',
          ),
        ],
      ),
      body: BlocBuilder<ContributionBloc, ContributionState>(
        builder: (context, state) {
          if (state is ContributionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ContributionError) {
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
                      context.read<ContributionBloc>().add(
                        LoadGroupContributionsEvent(widget.groupId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (state is ContributionsLoaded) {
            final contributions = state.contributions;

            if (contributions.isEmpty) {
              return _buildEmptyState();
            }

            // Grouper les contributions par tour
            final contributionsByTour = _groupContributionsByTour(
              contributions,
            );

            return Column(
              children: [
                _buildTourSelector(contributionsByTour.keys.toList()),
                Expanded(
                  child: _selectedTourId == null
                      ? _buildAllToursView(contributionsByTour)
                      : _buildSingleTourView(
                          contributionsByTour[_selectedTourId]!,
                        ),
                ),
              ],
            );
          }

          return const Center(child: Text('Chargement...'));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune cotisation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Les cotisations apparaîtront ici une fois les tours générés',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTourSelector(List<String> tourIds) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrer par tour',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTourChip('Tous les tours', null),
                const SizedBox(width: 8),
                ...tourIds.map(
                  (tourId) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildTourChip(
                      'Tour ${tourIds.indexOf(tourId) + 1}',
                      tourId,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourChip(String label, String? tourId) {
    final isSelected = _selectedTourId == tourId;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTourId = selected ? tourId : null;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildAllToursView(
    Map<String, List<Contribution>> contributionsByTour,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contributionsByTour.length,
      itemBuilder: (context, index) {
        final tourId = contributionsByTour.keys.elementAt(index);
        final contributions = contributionsByTour[tourId]!;
        return _buildTourCard(tourId, contributions, index + 1);
      },
    );
  }

  Widget _buildSingleTourView(List<Contribution> contributions) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ContributionBloc>().add(
          LoadGroupContributionsEvent(widget.groupId),
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contributions.length,
        itemBuilder: (context, index) {
          final contribution = contributions[index];
          return _buildContributionCard(contribution);
        },
      ),
    );
  }

  Widget _buildTourCard(
    String tourId,
    List<Contribution> contributions,
    int tourNumber,
  ) {
    final paid = contributions.where((c) => c.status == 'PAID').length;
    final pending = contributions.where((c) => c.status == 'PENDING').length;
    final overdue = contributions.where((c) => c.status == 'OVERDUE').length;
    final total = contributions.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            '$tourNumber',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Tour $tourNumber',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$paid/$total payés'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Payés', paid, AppColors.success),
                const SizedBox(height: 8),
                _buildStatRow('En attente', pending, AppColors.warning),
                const SizedBox(height: 8),
                _buildStatRow('En retard', overdue, AppColors.error),
                const Divider(height: 24),
                ...contributions.map((c) => _buildContributionCard(c)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildContributionCard(Contribution contribution) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (contribution.status) {
      case 'PAID':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Payé';
        break;
      case 'OVERDUE':
        statusColor = AppColors.error;
        statusIcon = Icons.warning;
        statusText = 'En retard';
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        statusText = 'En attente';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(
          contribution.memberName ?? 'Membre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Échéance: ${contribution.dueDateFormatted}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(contribution.amountDue),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<Contribution>> _groupContributionsByTour(
    List<Contribution> contributions,
  ) {
    final Map<String, List<Contribution>> grouped = {};
    for (var contribution in contributions) {
      if (!grouped.containsKey(contribution.tourId)) {
        grouped[contribution.tourId] = [];
      }
      grouped[contribution.tourId]!.add(contribution);
    }
    return grouped;
  }

  Future<void> _exportToPdf() async {
    final state = context.read<ContributionBloc>().state;
    if (state is! ContributionsLoaded) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export PDF en cours...'),
        backgroundColor: AppColors.info,
      ),
    );

    try {
      final contributionsByTour = _groupContributionsByTour(
        state.contributions,
      );
      final filePath = await ExportService.exportToPdf(
        groupName: widget.groupName,
        contributions: state.contributions,
        contributionsByTour: contributionsByTour,
      );

      if (filePath != null) {
        // Afficher la notification de téléchargement
        final fileName = filePath.split('/').last;
        await ExportService.showDownloadNotification(
          fileName: fileName,
          filePath: filePath,
          fileType: 'PDF',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF exporté avec succès'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Partager',
              textColor: Colors.white,
              onPressed: () => ExportService.shareFile(filePath),
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'export PDF'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _exportToExcel() async {
    final state = context.read<ContributionBloc>().state;
    if (state is! ContributionsLoaded) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export Excel en cours...'),
        backgroundColor: AppColors.info,
      ),
    );

    try {
      final contributionsByTour = _groupContributionsByTour(
        state.contributions,
      );
      final filePath = await ExportService.exportToExcel(
        groupName: widget.groupName,
        contributions: state.contributions,
        contributionsByTour: contributionsByTour,
      );

      if (filePath != null) {
        // Afficher la notification de téléchargement
        final fileName = filePath.split('/').last;
        await ExportService.showDownloadNotification(
          fileName: fileName,
          filePath: filePath,
          fileType: 'Excel',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Excel exporté avec succès'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Partager',
              textColor: Colors.white,
              onPressed: () => ExportService.shareFile(filePath),
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'export Excel'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
