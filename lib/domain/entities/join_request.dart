import 'package:equatable/equatable.dart';

class JoinRequest extends Equatable {
  final String id;
  final String groupId;
  final String groupName;
  final String personId;
  final String personName;
  final String personPhone;
  final String? personPhoto;
  final String status; // PENDING, APPROVED, REJECTED, CANCELLED
  final String? message;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final DateTime createdAt;

  const JoinRequest({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.personId,
    required this.personName,
    required this.personPhone,
    this.personPhoto,
    required this.status,
    this.message,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNote,
    required this.createdAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';

  @override
  List<Object?> get props => [
        id,
        groupId,
        groupName,
        personId,
        personName,
        personPhone,
        personPhoto,
        status,
        message,
        reviewedBy,
        reviewedAt,
        reviewNote,
        createdAt,
      ];
}
