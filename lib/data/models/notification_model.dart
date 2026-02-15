import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String personId;
  final String type; // REMINDER_DUE, GROUP_INVITATION, PAYMENT_SUCCESS, etc.
  final String channel; // PUSH, SMS, WHATSAPP, EMAIL
  final String title;
  final String body;
  final String? scheduledAt;
  final String? sentAt;
  final bool readFlag;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.personId,
    required this.type,
    required this.channel,
    required this.title,
    required this.body,
    this.scheduledAt,
    this.sentAt,
    required this.readFlag,
    this.metadata,
  });

  /// Extrait le code d'invitation du corps de la notification si présent
  String? get invitationCode {
    if (type.toUpperCase().contains('INVITATION')) {
      // 1. D'abord, chercher dans les metadata (plus fiable)
      if (metadata != null && metadata!.containsKey('code')) {
        return metadata!['code'] as String?;
      }

      // 2. Sinon, chercher dans le body avec regex
      // Chercher un pattern de code entre 6 et 10 caractères (ex: T0Y108OD, ABC123)
      final regex = RegExp(r'\b[A-Z0-9]{6,10}\b');
      final match = regex.firstMatch(body);
      return match?.group(0);
    }
    return null;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
