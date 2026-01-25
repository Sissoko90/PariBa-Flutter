import 'package:json_annotation/json_annotation.dart';

part 'support_ticket_model.g.dart';

@JsonSerializable()
class SupportTicketModel {
  final String id;
  final String personId;
  final String type;
  final String status;
  final String priority;
  final String subject;
  final String message;
  final String? adminResponse;
  final String? adminId;
  final DateTime? respondedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicketModel({
    required this.id,
    required this.personId,
    required this.type,
    required this.status,
    required this.priority,
    required this.subject,
    required this.message,
    this.adminResponse,
    this.adminId,
    this.respondedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketModelToJson(this);
}

enum TicketType {
  @JsonValue('BUG_REPORT')
  bugReport,
  @JsonValue('FEATURE_REQUEST')
  featureRequest,
  @JsonValue('GENERAL_INQUIRY')
  generalInquiry,
  @JsonValue('ACCOUNT_ISSUE')
  accountIssue,
  @JsonValue('PAYMENT_ISSUE')
  paymentIssue,
  @JsonValue('TECHNICAL_ISSUE')
  technicalIssue,
  @JsonValue('OTHER')
  other,
}

enum TicketStatus {
  @JsonValue('OPEN')
  open,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('WAITING_USER')
  waitingUser,
  @JsonValue('RESOLVED')
  resolved,
  @JsonValue('CLOSED')
  closed,
}

enum TicketPriority {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('URGENT')
  urgent,
}

extension TicketTypeExtension on TicketType {
  String get label {
    switch (this) {
      case TicketType.bugReport:
        return 'Signalement de bug';
      case TicketType.featureRequest:
        return 'Demande de fonctionnalité';
      case TicketType.generalInquiry:
        return 'Question générale';
      case TicketType.accountIssue:
        return 'Problème de compte';
      case TicketType.paymentIssue:
        return 'Problème de paiement';
      case TicketType.technicalIssue:
        return 'Problème technique';
      case TicketType.other:
        return 'Autre';
    }
  }
}

extension TicketStatusExtension on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Ouvert';
      case TicketStatus.inProgress:
        return 'En cours';
      case TicketStatus.waitingUser:
        return 'En attente';
      case TicketStatus.resolved:
        return 'Résolu';
      case TicketStatus.closed:
        return 'Fermé';
    }
  }
}
