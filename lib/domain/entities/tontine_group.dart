import 'package:equatable/equatable.dart';

/// TontineGroup Entity - Groupe de tontine
class TontineGroup extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String nom;
  final String? description;
  final double montant;
  final String frequency;
  final String rotationMode;
  final int totalTours;
  final String startDate;
  final double? latePenaltyAmount;
  final int? graceDays;
  final String? role;
  final String creatorPersonId;
  final String status;

  const TontineGroup({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.nom,
    this.description,
    required this.montant,
    required this.frequency,
    required this.rotationMode,
    required this.totalTours,
    required this.startDate,
    this.latePenaltyAmount,
    this.graceDays,
    this.role,
    this.status = 'active',
    required this.creatorPersonId,
  });

  @override
  List<Object?> get props => [
    id,
    createdAt,
    updatedAt,
    nom,
    description,
    montant,
    frequency,
    rotationMode,
    totalTours,
    startDate,
    latePenaltyAmount,
    graceDays,
    creatorPersonId,
    status,
  ];
}
