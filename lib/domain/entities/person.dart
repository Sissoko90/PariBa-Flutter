import 'package:equatable/equatable.dart';

/// Person Entity - Profil utilisateur
class Person extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String prenom;
  final String nom;
  final String email;
  final String phone;
  final String? photo;
  final String role;

  const Person({
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

  String get fullName => '$prenom $nom';

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        prenom,
        nom,
        email,
        phone,
        photo,
        role,
      ];
}
