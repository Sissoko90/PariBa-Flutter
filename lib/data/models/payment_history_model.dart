import 'package:json_annotation/json_annotation.dart';

part 'payment_history_model.g.dart';

@JsonSerializable()
class PaymentHistoryModel {
  final String id;
  final String tourNumber;
  final String? tourTitle;
  final double amount;
  final String paymentType;
  final String status;
  final String paymentDate;
  final String formattedDate;
  final bool? isPayout;

  PaymentHistoryModel({
    required this.id,
    required this.tourNumber,
    this.tourTitle,
    required this.amount,
    required this.paymentType,
    required this.status,
    required this.paymentDate,
    required this.formattedDate,
    this.isPayout,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryModelToJson(this);
}
