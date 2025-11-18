// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tontine_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TontineGroupModel _$TontineGroupModelFromJson(Map<String, dynamic> json) =>
    TontineGroupModel(
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
      creatorPersonId: json['creatorPersonId'] as String,
    );

Map<String, dynamic> _$TontineGroupModelToJson(TontineGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'nom': instance.nom,
      'description': instance.description,
      'montant': instance.montant,
      'frequency': instance.frequency,
      'rotationMode': instance.rotationMode,
      'totalTours': instance.totalTours,
      'startDate': instance.startDate,
      'latePenaltyAmount': instance.latePenaltyAmount,
      'graceDays': instance.graceDays,
      'creatorPersonId': instance.creatorPersonId,
    };
