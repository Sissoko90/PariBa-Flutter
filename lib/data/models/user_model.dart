import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String username;
  final String password;
  final String personId;

  UserModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.password,
    required this.personId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
