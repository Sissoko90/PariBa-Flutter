// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      personId: json['personId'] as String,
      type: json['type'] as String,
      channel: json['channel'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledAt: json['scheduledAt'] as String?,
      sentAt: json['sentAt'] as String?,
      readFlag: json['readFlag'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'personId': instance.personId,
      'type': instance.type,
      'channel': instance.channel,
      'title': instance.title,
      'body': instance.body,
      'scheduledAt': instance.scheduledAt,
      'sentAt': instance.sentAt,
      'readFlag': instance.readFlag,
      'metadata': instance.metadata,
    };
