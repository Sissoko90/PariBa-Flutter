// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportContactModel _$SupportContactModelFromJson(Map<String, dynamic> json) =>
    SupportContactModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      whatsappNumber: json['whatsappNumber'] as String?,
      supportHours: json['supportHours'] as String?,
      active: json['active'] as bool,
    );

Map<String, dynamic> _$SupportContactModelToJson(
        SupportContactModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'whatsappNumber': instance.whatsappNumber,
      'supportHours': instance.supportHours,
      'active': instance.active,
    };
