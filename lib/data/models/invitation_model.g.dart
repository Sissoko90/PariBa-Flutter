// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationModel _$InvitationModelFromJson(Map<String, dynamic> json) =>
    InvitationModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      groupId: json['groupId'] as String,
      targetPhone: json['targetPhone'] as String?,
      targetEmail: json['targetEmail'] as String?,
      linkCode: json['linkCode'] as String,
      status: json['status'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$InvitationModelToJson(InvitationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'groupId': instance.groupId,
      'targetPhone': instance.targetPhone,
      'targetEmail': instance.targetEmail,
      'linkCode': instance.linkCode,
      'status': instance.status,
      'expiresAt': instance.expiresAt,
    };
