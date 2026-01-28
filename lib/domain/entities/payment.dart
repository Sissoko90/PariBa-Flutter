import 'package:flutter/material.dart';

class Payment {
  final String id;
  final double amount;
  final String paymentType;
  final String status; // PENDING, CONFIRMED, REJECTED, PROCESSING
  final DateTime createdAt;
  final String? payerName;
  final String? groupName;
  final String? transactionRef;
  final String? notes;
  final String? adminNotes;
  final DateTime? validatedAt;
  final Map<String, dynamic>? payer;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentType,
    required this.status,
    required this.createdAt,
    this.payerName,
    this.groupName,
    this.transactionRef,
    this.notes,
    this.adminNotes,
    this.validatedAt,
    this.payer,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Extraire le nom du payeur depuis l'objet payer
    String? payerName;
    if (json['payer'] != null) {
      final payerData = json['payer'] as Map<String, dynamic>;
      final prenom = payerData['prenom'] as String? ?? '';
      final nom = payerData['nom'] as String? ?? '';
      payerName = '$prenom $nom'.trim();
      if (payerName.isEmpty) {
        payerName = payerData['email'] as String?;
      }
    }

    return Payment(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentType: json['paymentType'] as String? ?? 'UNKNOWN',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] is DateTime 
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      payerName: payerName,
      groupName: json['groupName'] as String?,
      transactionRef: json['externalRef'] as String?,
      notes: json['notes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      validatedAt: json['validatedAt'] != null
          ? (json['validatedAt'] is DateTime
              ? json['validatedAt'] as DateTime
              : DateTime.parse(json['validatedAt'] as String))
          : null,
      payer: json['payer'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'paymentType': paymentType,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (payerName != null) 'payerName': payerName,
      if (groupName != null) 'groupName': groupName,
      if (transactionRef != null) 'externalRef': transactionRef,
      if (notes != null) 'notes': notes,
      if (adminNotes != null) 'adminNotes': adminNotes,
      if (validatedAt != null) 'validatedAt': validatedAt!.toIso8601String(),
      if (payer != null) 'payer': payer,
    };
  }

  // Méthodes utilitaires
  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isRejected => status == 'REJECTED';
  bool get isProcessing => status == 'PROCESSING';

  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'CONFIRMED':
        return 'Confirmé';
      case 'REJECTED':
        return 'Rejeté';
      case 'PROCESSING':
        return 'En traitement';
      default:
        return status;
    }
  }

  String get paymentTypeLabel {
    switch (paymentType) {
      case 'ORANGE_MONEY':
        return 'Orange Money';
      case 'MOOV_MONEY':
        return 'Moov Money';
      case 'WAVE_MONEY':
        return 'Wave Money';
      case 'SAMA_MONEY':
        return 'Sama Money';
      case 'BANK_TRANSFER':
        return 'Virement bancaire';
      case 'CASH':
        return 'Espèces';
      default:
        return paymentType;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'PROCESSING':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'REJECTED':
        return Icons.cancel;
      case 'PROCESSING':
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
  }
}