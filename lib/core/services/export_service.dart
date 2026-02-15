import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/contribution.dart';

class ExportService {
  /// Exporter les cotisations en PDF
  static Future<String?> exportToPdf({
    required String groupName,
    required List<Contribution> contributions,
    required Map<String, List<Contribution>> contributionsByTour,
  }) async {
    try {
      final pdf = pw.Document();

      // Page de titre
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildPdfHeader(groupName),
            pw.SizedBox(height: 20),
            _buildPdfSummary(contributions),
            pw.SizedBox(height: 20),
            _buildPdfTourDetails(contributionsByTour),
          ],
        ),
      );

      // Sauvegarder le fichier dans Downloads
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath =
          '${directory.path}/cotisations_${groupName}_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      print('❌ Erreur export PDF: $e');
      return null;
    }
  }

  /// Exporter les cotisations en Excel
  static Future<String?> exportToExcel({
    required String groupName,
    required List<Contribution> contributions,
    required Map<String, List<Contribution>> contributionsByTour,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Cotisations'];

      // En-têtes
      sheet.appendRow([
        'Tour',
        'Membre',
        'Montant dû',
        'Statut',
        'Date d\'échéance',
        'Pénalité',
      ]);

      // Style des en-têtes
      for (var i = 0; i < 6; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: '#4F46E5',
          fontColorHex: '#FFFFFF',
        );
      }

      // Données par tour
      int tourIndex = 1;
      for (var entry in contributionsByTour.entries) {
        final tourContributions = entry.value;

        for (var contribution in tourContributions) {
          sheet.appendRow([
            'Tour $tourIndex',
            contribution.memberName ?? 'Membre',
            contribution.amountDue,
            _getStatusLabel(contribution.status),
            contribution.dueDateFormatted,
            contribution.penaltyApplied ?? 0,
          ]);
        }
        tourIndex++;
      }

      // Auto-ajuster les colonnes
      for (var i = 0; i < 6; i++) {
        sheet.setColWidth(i, 20);
      }

      // Sauvegarder le fichier dans Downloads
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath =
          '${directory.path}/cotisations_${groupName}_$timestamp.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      return filePath;
    } catch (e) {
      print('❌ Erreur export Excel: $e');
      return null;
    }
  }

  /// Partager un fichier exporté
  static Future<void> shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      print('❌ Erreur partage fichier: $e');
    }
  }

  /// Afficher une notification de téléchargement
  static Future<void> showDownloadNotification({
    required String fileName,
    required String filePath,
    required String fileType, // 'PDF' ou 'Excel'
  }) async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'downloads_channel',
            'Téléchargements',
            channelDescription: 'Notifications pour les fichiers téléchargés',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(''),
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Fichier $fileType téléchargé',
        fileName,
        notificationDetails,
        payload: filePath,
      );

      print('✅ Notification de téléchargement affichée: $fileName');
    } catch (e) {
      print('❌ Erreur notification téléchargement: $e');
    }
  }

  // ========== Helpers PDF ==========

  static pw.Widget _buildPdfHeader(String groupName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Rapport des Cotisations',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Groupe: $groupName', style: const pw.TextStyle(fontSize: 16)),
        pw.Text(
          'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildPdfSummary(List<Contribution> contributions) {
    final paid = contributions.where((c) => c.status == 'PAID').length;
    final pending = contributions.where((c) => c.status == 'PENDING').length;
    final overdue = contributions.where((c) => c.status == 'OVERDUE').length;
    final total = contributions.length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Résumé',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildPdfStat('Total', total, PdfColors.blue),
              _buildPdfStat('Payés', paid, PdfColors.green),
              _buildPdfStat('En attente', pending, PdfColors.orange),
              _buildPdfStat('En retard', overdue, PdfColors.red),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfStat(String label, int value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '$value',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfTourDetails(
    Map<String, List<Contribution>> contributionsByTour,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Détails par tour',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        ...contributionsByTour.entries.map((entry) {
          final tourIndex =
              contributionsByTour.keys.toList().indexOf(entry.key) + 1;
          final contributions = entry.value;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Tour $tourIndex',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Membre', 'Montant', 'Statut', 'Échéance'],
                data: contributions
                    .map(
                      (c) => [
                        c.memberName ?? 'Membre',
                        '${c.amountDue.toStringAsFixed(0)} FCFA',
                        _getStatusLabel(c.status),
                        c.dueDateFormatted,
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(color: PdfColors.grey300),
              ),
              pw.SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }

  static String _getStatusLabel(String status) {
    switch (status) {
      case 'PAID':
        return 'Payé';
      case 'OVERDUE':
        return 'En retard';
      case 'PENDING':
        return 'En attente';
      default:
        return status;
    }
  }
}
