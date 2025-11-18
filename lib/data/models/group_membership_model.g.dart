// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMembershipModel _$GroupMembershipModelFromJson(
        Map<String, dynamic> json) =>
    GroupMembershipModel(
      groupId: json['groupId'] as String,
      personId: json['personId'] as String,
      role: json['role'] as String,
      joinedAt: json['joinedAt'] as String,
    );

Map<String, dynamic> _$GroupMembershipModelToJson(
        GroupMembershipModel instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'personId': instance.personId,
      'role': instance.role,
      'joinedAt': instance.joinedAt,
    };
