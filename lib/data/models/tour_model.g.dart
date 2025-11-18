// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourModel _$TourModelFromJson(Map<String, dynamic> json) => TourModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      groupId: json['groupId'] as String,
      indexInGroup: (json['indexInGroup'] as num).toInt(),
      beneficiaryPersonId: json['beneficiaryPersonId'] as String,
      scheduledDate: json['scheduledDate'] as String,
      status: json['status'] as String,
      totalDue: (json['totalDue'] as num).toDouble(),
      totalCollected: (json['totalCollected'] as num).toDouble(),
      payoutPaymentId: json['payoutPaymentId'] as String?,
    );

Map<String, dynamic> _$TourModelToJson(TourModel instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'groupId': instance.groupId,
      'indexInGroup': instance.indexInGroup,
      'beneficiaryPersonId': instance.beneficiaryPersonId,
      'scheduledDate': instance.scheduledDate,
      'status': instance.status,
      'totalDue': instance.totalDue,
      'totalCollected': instance.totalCollected,
      'payoutPaymentId': instance.payoutPaymentId,
    };
