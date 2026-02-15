// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionModel _$ContributionModelFromJson(Map<String, dynamic> json) =>
    ContributionModel(
      id: json['id'] as String,
      member: json['member'] == null
          ? null
          : PersonModel.fromJson(json['member'] as Map<String, dynamic>),
      tourId: json['tourId'] as String,
      tourIndex: (json['tourIndex'] as num?)?.toInt(),
      amountDue: (json['amountDue'] as num).toDouble(),
      status: json['status'] as String,
      dueDate: json['dueDate'] as String,
      penaltyApplied: (json['penaltyApplied'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ContributionModelToJson(ContributionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'member': instance.member,
      'tourId': instance.tourId,
      'tourIndex': instance.tourIndex,
      'amountDue': instance.amountDue,
      'status': instance.status,
      'dueDate': instance.dueDate,
      'penaltyApplied': instance.penaltyApplied,
      'createdAt': instance.createdAt.toIso8601String(),
    };
