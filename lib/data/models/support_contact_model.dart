import 'package:json_annotation/json_annotation.dart';

part 'support_contact_model.g.dart';

@JsonSerializable()
class SupportContactModel {
  final String id;
  final String email;
  final String phone;
  final String? whatsappNumber;
  final String? supportHours;
  final bool active;

  SupportContactModel({
    required this.id,
    required this.email,
    required this.phone,
    this.whatsappNumber,
    this.supportHours,
    required this.active,
  });

  factory SupportContactModel.fromJson(Map<String, dynamic> json) =>
      _$SupportContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportContactModelToJson(this);
}
