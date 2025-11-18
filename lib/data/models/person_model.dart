import 'package:json_annotation/json_annotation.dart';

part 'person_model.g.dart';

@JsonSerializable()
class PersonModel {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String prenom;
  final String nom;
  final String email;
  final String phone;
  final String? photo;
  final String role; // SUPERADMIN, ADMIN, USER

  PersonModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.phone,
    this.photo,
    required this.role,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) =>
      _$PersonModelFromJson(json);

  Map<String, dynamic> toJson() => _$PersonModelToJson(this);

  String get fullName => '$prenom $nom';
}
