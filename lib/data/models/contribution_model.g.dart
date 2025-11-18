// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionModel _$ContributionModelFromJson(Map<String, dynamic> json) =>
    ContributionModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      groupId: json['groupId'] as String,
      memberPersonId: json['memberPersonId'] as String,
      tourId: json['tourId'] as String,
      amountDue: (json['amountDue'] as num).toDouble(),
      status: json['status'] as String,
      dueDate: json['dueDate'] as String,
      paymentId: json['paymentId'] as String?,
      penaltyApplied: (json['penaltyApplied'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ContributionModelToJson(ContributionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'groupId': instance.groupId,
      'memberPersonId': instance.memberPersonId,
      'tourId': instance.tourId,
      'amountDue': instance.amountDue,
      'status': instance.status,
      'dueDate': instance.dueDate,
      'paymentId': instance.paymentId,
      'penaltyApplied': instance.penaltyApplied,
    };
