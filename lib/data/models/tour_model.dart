import 'package:json_annotation/json_annotation.dart';

part 'tour_model.g.dart';

@JsonSerializable()
class TourModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String groupId;
  final int indexInGroup;
  final String beneficiaryPersonId;
  final String scheduledDate;
  final String status; // SCHEDULED, IN_PROGRESS, PAID_OUT, CLOSED
  final double totalDue;
  final double totalCollected;
  final String? payoutPaymentId;

  TourModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.groupId,
    required this.indexInGroup,
    required this.beneficiaryPersonId,
    required this.scheduledDate,
    required this.status,
    required this.totalDue,
    required this.totalCollected,
    this.payoutPaymentId,
  });

  factory TourModel.fromJson(Map<String, dynamic> json) =>
      _$TourModelFromJson(json);

  Map<String, dynamic> toJson() => _$TourModelToJson(this);
}
