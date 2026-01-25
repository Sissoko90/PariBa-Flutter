// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guide_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuideModel _$GuideModelFromJson(Map<String, dynamic> json) => GuideModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      content: json['content'] as String,
      category: json['category'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
      active: json['active'] as bool,
      viewCount: (json['viewCount'] as num).toInt(),
      iconName: json['iconName'] as String?,
      estimatedReadTime: (json['estimatedReadTime'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GuideModelToJson(GuideModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'content': instance.content,
      'category': instance.category,
      'displayOrder': instance.displayOrder,
      'active': instance.active,
      'viewCount': instance.viewCount,
      'iconName': instance.iconName,
      'estimatedReadTime': instance.estimatedReadTime,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
