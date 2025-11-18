import 'package:json_annotation/json_annotation.dart';

part 'tontine_group_model.g.dart';

@JsonSerializable()
class TontineGroupModel {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String nom;
  final String? description;
  final double montant;
  final String frequency; // WEEKLY, BIWEEKLY, MONTHLY
  final String rotationMode; // FIXED_ORDER, SHUFFLE, RANDOM, CUSTOM
  final int totalTours;
  final String startDate;
  final double? latePenaltyAmount;
  final int? graceDays;
  final String creatorPersonId;

  TontineGroupModel({
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
    required this.creatorPersonId,
  });

  factory TontineGroupModel.fromJson(Map<String, dynamic> json) {
    // Le backend retourne 'creator' (objet) au lieu de 'creatorPersonId' (String)
    // On extrait l'ID du créateur si c'est un objet
    String creatorId;
    if (json['creator'] != null && json['creator'] is Map) {
      creatorId = json['creator']['id'] as String;
    } else if (json['creatorPersonId'] != null) {
      creatorId = json['creatorPersonId'] as String;
    } else {
      creatorId = '';
    }
    
    return TontineGroupModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      nom: json['nom'] as String,
      description: json['description'] as String?,
      montant: (json['montant'] as num).toDouble(),
      frequency: json['frequency'] as String,
      rotationMode: json['rotationMode'] as String,
      totalTours: (json['totalTours'] as num).toInt(),
      startDate: json['startDate'] as String,
      latePenaltyAmount: (json['latePenaltyAmount'] as num?)?.toDouble(),
      graceDays: (json['graceDays'] as num?)?.toInt(),
      creatorPersonId: creatorId,
    );
  }

  Map<String, dynamic> toJson() => _$TontineGroupModelToJson(this);
}
