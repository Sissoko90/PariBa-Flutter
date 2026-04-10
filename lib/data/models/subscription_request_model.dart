// lib/data/models/subscription_request_model.dart

class SubscriptionRequestModel {
  final String id;
  final String planId;
  final String planName;
  final String planType;
  final double planPrice;
  final String billingPeriod;
  final bool autoRenew;
  final String status; // PENDING, APPROVED, REJECTED, CANCELLED
  final String? notes;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? processedAt;

  SubscriptionRequestModel({
    required this.id,
    required this.planId,
    required this.planName,
    required this.planType,
    required this.planPrice,
    required this.billingPeriod,
    required this.autoRenew,
    required this.status,
    this.notes,
    this.adminNotes,
    required this.createdAt,
    this.processedAt,
  });

  factory SubscriptionRequestModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionRequestModel(
      id: json['id'],
      planId: json['planId'],
      planName: json['planName'],
      planType: json['planType'],
      planPrice: (json['planPrice'] ?? 0).toDouble(),
      billingPeriod: json['billingPeriod'] ?? 'monthly',
      autoRenew: json['autoRenew'] ?? false,
      status: json['status'] ?? 'PENDING',
      notes: json['notes'],
      adminNotes: json['adminNotes'],
      createdAt: DateTime.parse(json['createdAt']),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';
}
