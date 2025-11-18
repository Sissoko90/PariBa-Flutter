import 'package:json_annotation/json_annotation.dart';

part 'invitation_model.g.dart';

@JsonSerializable()
class InvitationModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String groupId;
  final String? targetPhone;
  final String? targetEmail;
  final String linkCode;
  final String status; // PENDING, ACCEPTED, DECLINED, EXPIRED
  final String expiresAt;

  InvitationModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.groupId,
    this.targetPhone,
    this.targetEmail,
    required this.linkCode,
    required this.status,
    required this.expiresAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationModelToJson(this);
}
