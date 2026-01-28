import 'package:equatable/equatable.dart';

/// Group Events
abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

/// Load Groups Event
class LoadGroupsEvent extends GroupEvent {
  const LoadGroupsEvent();
}

/// Create Group Event
class CreateGroupEvent extends GroupEvent {
  final String nom;
  final String? description;
  final double montant;
  final String frequency;
  final String rotationMode;
  final int totalTours;
  final String startDate;
  final double? latePenaltyAmount;
  final int? graceDays;

  const CreateGroupEvent({
    required this.nom,
    this.description,
    required this.montant,
    required this.frequency,
    required this.rotationMode,
    required this.totalTours,
    required this.startDate,
    this.latePenaltyAmount,
    this.graceDays,
  });

  @override
  List<Object?> get props => [
    nom,
    description,
    montant,
    frequency,
    rotationMode,
    totalTours,
    startDate,
    latePenaltyAmount,
    graceDays,
  ];
}

/// Load Group Details Event
class LoadGroupDetailsEvent extends GroupEvent {
  final String groupId;

  const LoadGroupDetailsEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Delete Group Event
class DeleteGroupEvent extends GroupEvent {
  final String groupId;

  const DeleteGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Leave Group Event
class LeaveGroupEvent extends GroupEvent {
  final String groupId;

  const LeaveGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}
