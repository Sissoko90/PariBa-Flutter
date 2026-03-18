class SubscriptionModel {
  final String id;
  final String planName;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;

  SubscriptionModel({
    required this.id,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      planName: json['planName'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      autoRenew: json['autoRenew'],
    );
  }
}
