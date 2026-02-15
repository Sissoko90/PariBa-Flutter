import 'package:json_annotation/json_annotation.dart';
import 'person_model.dart';

part 'contribution_model.g.dart';

@JsonSerializable()
class ContributionModel {
  final String id;
  final PersonModel? member;
  final String tourId;
  final int? tourIndex;
  final double amountDue;
  final String status; // DUE, PAID, LATE, WAIVED, PENDING, OVERDUE
  final String dueDate;
  final double? penaltyApplied;
  final DateTime createdAt;

  ContributionModel({
    required this.id,
    this.member,
    required this.tourId,
    this.tourIndex,
    required this.amountDue,
    required this.status,
    required this.dueDate,
    this.penaltyApplied,
    required this.createdAt,
  });

  // Helper pour obtenir le nom du membre
  String? get memberName => member?.fullName;

  // Helper pour obtenir l'ID du membre
  String? get memberPersonId => member?.id;

  // Helper pour obtenir l'ID du groupe (via le tour si nécessaire)
  String? get groupId => null; // Sera récupéré du contexte

  factory ContributionModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionModelToJson(this);
}
