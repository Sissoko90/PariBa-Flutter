import 'package:equatable/equatable.dart';

/// Contribution Entity - Cotisation
class Contribution extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String groupId;
  final String memberPersonId;
  final String tourId;
  final double amountDue;
  final String status;
  final String dueDate;
  final String? paymentId;
  final double? penaltyApplied;

  const Contribution({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.groupId,
    required this.memberPersonId,
    required this.tourId,
    required this.amountDue,
    required this.status,
    required this.dueDate,
    this.paymentId,
    this.penaltyApplied,
  });

  bool get isPaid => status == 'PAID';
  bool get isLate => status == 'LATE';
  bool get isDue => status == 'DUE';

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        groupId,
        memberPersonId,
        tourId,
        amountDue,
        status,
        dueDate,
        paymentId,
        penaltyApplied,
      ];
}
