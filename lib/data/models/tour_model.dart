import 'package:json_annotation/json_annotation.dart';
import 'person_model.dart';

part 'tour_model.g.dart';

@JsonSerializable()
class TourModel {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? groupId;
  final int indexInGroup;
  final String? beneficiaryPersonId;
  final PersonModel? beneficiary;
  final String? scheduledDate;
  final String status; // SCHEDULED, IN_PROGRESS, PAID_OUT, CLOSED
  final double? totalDue;
  final double? totalCollected;
  final String? payoutPaymentId;

  TourModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    this.groupId,
    required this.indexInGroup,
    this.beneficiaryPersonId,
    this.beneficiary,
    this.scheduledDate,
    required this.status,
    this.totalDue,
    this.totalCollected,
    this.payoutPaymentId,
  });

  factory TourModel.fromJson(Map<String, dynamic> json) =>
      _$TourModelFromJson(json);

  Map<String, dynamic> toJson() => _$TourModelToJson(this);
}
