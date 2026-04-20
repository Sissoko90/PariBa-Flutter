// lib/domain/entities/payment_history_item.dart

class PaymentHistoryItem {
  final String id;
  final String? tourNumber;
  final String? tourTitle;
  final double amount;
  final String paymentType;
  final String status;
  final String? paymentDate;
  final String? formattedDate;
  final bool isPayout;

  PaymentHistoryItem({
    required this.id,
    this.tourNumber,
    this.tourTitle,
    required this.amount,
    required this.paymentType,
    required this.status,
    this.paymentDate,
    this.formattedDate,
    required this.isPayout,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      id: json['id'] ?? '',
      tourNumber: json['tourNumber']?.toString(),
      tourTitle: json['tourTitle'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentType: json['paymentType'] ?? 'CASH',
      status: json['status'] ?? 'CONFIRMED',
      paymentDate: json['paymentDate'],
      formattedDate: json['formattedDate'],
      isPayout: json['payout'] ?? false,
    );
  }
}
