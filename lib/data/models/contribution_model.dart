import 'package:json_annotation/json_annotation.dart';

part 'contribution_model.g.dart';

@JsonSerializable()
class ContributionModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String groupId;
  final String memberPersonId;
  final String tourId;
  final double amountDue;
  final String status; // DUE, PAID, LATE, WAIVED
  final String dueDate;
  final String? paymentId;
  final double? penaltyApplied;

  ContributionModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.groupId,
    required this.memberPersonId,
    required this.tourId,
    required this.amountDue,
    required this.status,
    required this.dueDate,
    this.paymentId,
    this.penaltyApplied,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionModelToJson(this);
}
