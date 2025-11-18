// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      groupId: json['groupId'] as String,
      payerPersonId: json['payerPersonId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentType: json['paymentType'] as String,
      status: json['status'] as String,
      externalRef: json['externalRef'] as String?,
      invoice: json['invoice'] as String?,
      payout: json['payout'] as bool,
    );

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'groupId': instance.groupId,
      'payerPersonId': instance.payerPersonId,
      'amount': instance.amount,
      'paymentType': instance.paymentType,
      'status': instance.status,
      'externalRef': instance.externalRef,
      'invoice': instance.invoice,
      'payout': instance.payout,
    };
