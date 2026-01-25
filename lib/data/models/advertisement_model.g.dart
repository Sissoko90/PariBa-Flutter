// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advertisement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvertisementModel _$AdvertisementModelFromJson(Map<String, dynamic> json) =>
    AdvertisementModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String,
      linkUrl: json['linkUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      active: json['active'] as bool,
      placement: $enumDecode(_$AdPlacementEnumMap, json['placement']),
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AdvertisementModelToJson(AdvertisementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'linkUrl': instance.linkUrl,
      'videoUrl': instance.videoUrl,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'active': instance.active,
      'placement': _$AdPlacementEnumMap[instance.placement]!,
      'impressions': instance.impressions,
      'clicks': instance.clicks,
    };

const _$AdPlacementEnumMap = {
  AdPlacement.fullscreen: 'FULLSCREEN',
  AdPlacement.banner: 'BANNER',
  AdPlacement.popup: 'POPUP',
};
