import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String personId;
  final String type; // REMINDER_DUE, GROUP_INVITATION, PAYMENT_SUCCESS, etc.
  final String channel; // PUSH, SMS, WHATSAPP, EMAIL
  final String title;
  final String body;
  final String? scheduledAt;
  final String? sentAt;
  final bool readFlag;

  NotificationModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.personId,
    required this.type,
    required this.channel,
    required this.title,
    required this.body,
    this.scheduledAt,
    this.sentAt,
    required this.readFlag,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
