import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String groupId;
  final String payerPersonId;
  final double amount;
  final String paymentType; // ORANGE_MONEY, MOOV_MONEY, WAVE, CASH, BANK
  final String status; // PENDING, SUCCESS, FAILED
  final String? externalRef;
  final String? invoice;
  final bool payout;

  PaymentModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.groupId,
    required this.payerPersonId,
    required this.amount,
    required this.paymentType,
    required this.status,
    this.externalRef,
    this.invoice,
    required this.payout,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}
