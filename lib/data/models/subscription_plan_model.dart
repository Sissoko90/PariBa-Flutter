// lib/data/models/subscription_plan_model.dart

class SubscriptionPlanModel {
  final String id;
  final String type; // FREE, BASIC, PRO, PREMIUM
  final String name;
  final String? description;
  final double monthlyPrice;
  final double? annualPrice;
  final int maxGroups;
  final bool canExportPdf;
  final bool canExportExcel;
  final bool active;

  final bool isActive;

  SubscriptionPlanModel({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.monthlyPrice,
    this.annualPrice,

    this.isActive = false,

    required this.maxGroups,
    required this.canExportPdf,
    required this.canExportExcel,
    required this.active,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      type: json['type'] ?? 'FREE',
      name: json['name'] ?? '',
      description: json['description'],
      monthlyPrice: (json['monthlyPrice'] ?? 0).toDouble(),
      annualPrice: json['annualPrice']?.toDouble(),
      maxGroups: json['maxGroups'] ?? 2,
      canExportPdf: json['canExportPdf'] ?? false,
      canExportExcel: json['canExportExcel'] ?? false,
      active: json['active'] ?? true,

      isActive: json['status'] == 'ACTIVE',
    );
  }
}

// lib/data/models/subscription_request_model.dart

// lib/data/models/subscription_model.dart

class SubscriptionModel {
  final String id;
  final String planType;
  final String planName;
  final double monthlyPrice;
  final String status; // ACTIVE, EXPIRED, CANCELLED
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;

  SubscriptionModel({
    required this.id,
    required this.planType,
    required this.planName,
    required this.monthlyPrice,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      planType: json['planType'] ?? 'FREE',
      planName: json['planName'] ?? 'Gratuit',
      monthlyPrice: (json['monthlyPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'ACTIVE',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      autoRenew: json['autoRenew'] ?? false,
    );
  }

  bool get isActive => status == 'ACTIVE';
  bool get isExpired => status == 'EXPIRED';
  bool get isFree => planType == 'FREE';
}
