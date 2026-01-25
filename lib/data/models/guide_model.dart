import 'package:json_annotation/json_annotation.dart';

part 'guide_model.g.dart';

@JsonSerializable()
class GuideModel {
  final String id;
  final String title;
  final String? description;
  final String content;
  final String category;
  final int displayOrder;
  final bool active;
  final int viewCount;
  final String? iconName;
  final int? estimatedReadTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  GuideModel({
    required this.id,
    required this.title,
    this.description,
    required this.content,
    required this.category,
    required this.displayOrder,
    required this.active,
    required this.viewCount,
    this.iconName,
    this.estimatedReadTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GuideModel.fromJson(Map<String, dynamic> json) =>
      _$GuideModelFromJson(json);

  Map<String, dynamic> toJson() => _$GuideModelToJson(this);
}

enum GuideCategory {
  @JsonValue('GETTING_STARTED')
  gettingStarted,
  @JsonValue('ACCOUNT_MANAGEMENT')
  accountManagement,
  @JsonValue('TONTINE_CREATION')
  tontineCreation,
  @JsonValue('TONTINE_PARTICIPATION')
  tontineParticipation,
  @JsonValue('PAYMENTS')
  payments,
  @JsonValue('NOTIFICATIONS')
  notifications,
  @JsonValue('SECURITY')
  security,
  @JsonValue('TROUBLESHOOTING')
  troubleshooting,
  @JsonValue('OTHER')
  other,
}

extension GuideCategoryExtension on GuideCategory {
  String get label {
    switch (this) {
      case GuideCategory.gettingStarted:
        return 'Démarrage';
      case GuideCategory.accountManagement:
        return 'Gestion du compte';
      case GuideCategory.tontineCreation:
        return 'Création de tontine';
      case GuideCategory.tontineParticipation:
        return 'Participation aux tontines';
      case GuideCategory.payments:
        return 'Paiements';
      case GuideCategory.notifications:
        return 'Notifications';
      case GuideCategory.security:
        return 'Sécurité';
      case GuideCategory.troubleshooting:
        return 'Dépannage';
      case GuideCategory.other:
        return 'Autre';
    }
  }
}
