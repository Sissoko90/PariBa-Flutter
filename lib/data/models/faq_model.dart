import 'package:json_annotation/json_annotation.dart';

part 'faq_model.g.dart';

@JsonSerializable()
class FAQModel {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int displayOrder;
  final bool active;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  FAQModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.displayOrder,
    required this.active,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) =>
      _$FAQModelFromJson(json);

  Map<String, dynamic> toJson() => _$FAQModelToJson(this);
}

enum FAQCategory {
  @JsonValue('ACCOUNT')
  account,
  @JsonValue('TONTINE')
  tontine,
  @JsonValue('PAYMENT')
  payment,
  @JsonValue('SECURITY')
  security,
  @JsonValue('FEATURES')
  features,
  @JsonValue('TECHNICAL')
  technical,
  @JsonValue('GENERAL')
  general,
  @JsonValue('OTHER')
  other,
}

extension FAQCategoryExtension on FAQCategory {
  String get label {
    switch (this) {
      case FAQCategory.account:
        return 'Compte utilisateur';
      case FAQCategory.tontine:
        return 'Tontines';
      case FAQCategory.payment:
        return 'Paiements';
      case FAQCategory.security:
        return 'Sécurité';
      case FAQCategory.features:
        return 'Fonctionnalités';
      case FAQCategory.technical:
        return 'Technique';
      case FAQCategory.general:
        return 'Général';
      case FAQCategory.other:
        return 'Autre';
    }
  }
}
