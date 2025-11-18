import 'package:json_annotation/json_annotation.dart';

part 'group_membership_model.g.dart';

@JsonSerializable()
class GroupMembershipModel {
  final String groupId;
  final String personId;
  final String role; // ADMIN, TREASURER, MEMBER
  final String joinedAt;

  GroupMembershipModel({
    required this.groupId,
    required this.personId,
    required this.role,
    required this.joinedAt,
  });

  factory GroupMembershipModel.fromJson(Map<String, dynamic> json) =>
      _$GroupMembershipModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupMembershipModelToJson(this);
}
