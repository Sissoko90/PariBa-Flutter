import 'package:json_annotation/json_annotation.dart';

part 'advertisement_model.g.dart';

enum AdPlacement {
  @JsonValue('FULLSCREEN')
  fullscreen,
  @JsonValue('BANNER')
  banner,
  @JsonValue('POPUP')
  popup,
}

@JsonSerializable()
class AdvertisementModel {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String title;
  final String? description;
  final String imageUrl;
  final String? linkUrl;
  final String? videoUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
  final AdPlacement placement;
  final int impressions;
  final int clicks;

  AdvertisementModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.title,
    this.description,
    required this.imageUrl,
    this.linkUrl,
    this.videoUrl,
    this.startDate,
    this.endDate,
    required this.active,
    required this.placement,
    this.impressions = 0,
    this.clicks = 0,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) =>
      _$AdvertisementModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdvertisementModelToJson(this);

  bool get isActive {
    if (!active) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
}
