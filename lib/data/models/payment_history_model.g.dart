// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentHistoryModel _$PaymentHistoryModelFromJson(Map<String, dynamic> json) =>
    PaymentHistoryModel(
      id: json['id'] as String,
      tourNumber: json['tourNumber'] as String,
      tourTitle: json['tourTitle'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paymentType: json['paymentType'] as String,
      status: json['status'] as String,
      paymentDate: json['paymentDate'] as String,
      formattedDate: json['formattedDate'] as String,
      isPayout: json['isPayout'] as bool?,
    );

Map<String, dynamic> _$PaymentHistoryModelToJson(
        PaymentHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourNumber': instance.tourNumber,
      'tourTitle': instance.tourTitle,
      'amount': instance.amount,
      'paymentType': instance.paymentType,
      'status': instance.status,
      'paymentDate': instance.paymentDate,
      'formattedDate': instance.formattedDate,
      'isPayout': instance.isPayout,
    };
