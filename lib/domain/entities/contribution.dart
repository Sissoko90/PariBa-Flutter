import 'package:equatable/equatable.dart';

/// Contribution Entity - Cotisation
class Contribution extends Equatable {
  final String id;
  final DateTime createdAt;
  final String tourId;
  final int? tourIndex;
  final double amountDue;
  final String status;
  final String dueDate;
  final double? penaltyApplied;
  final String? memberName;
  final String? memberPersonId;

  const Contribution({
    required this.id,
    required this.createdAt,
    required this.tourId,
    this.tourIndex,
    required this.amountDue,
    required this.status,
    required this.dueDate,
    this.penaltyApplied,
    this.memberName,
    this.memberPersonId,
  });

  bool get isPaid => status == 'PAID';
  bool get isLate => status == 'LATE' || status == 'OVERDUE';
  bool get isDue => status == 'DUE' || status == 'PENDING';

  String get dueDateFormatted {
    try {
      final date = DateTime.parse(dueDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dueDate;
    }
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    tourId,
    tourIndex,
    amountDue,
    status,
    dueDate,
    penaltyApplied,
    memberName,
    memberPersonId,
  ];
}
