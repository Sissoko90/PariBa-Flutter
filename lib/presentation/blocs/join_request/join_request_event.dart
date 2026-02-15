import 'package:equatable/equatable.dart';

abstract class JoinRequestEvent extends Equatable {
  const JoinRequestEvent();

  @override
  List<Object?> get props => [];
}

class CreateJoinRequestEvent extends JoinRequestEvent {
  final String groupId;
  final String? message;

  const CreateJoinRequestEvent(this.groupId, {this.message});

  @override
  List<Object?> get props => [groupId, message];
}

class ApproveJoinRequestEvent extends JoinRequestEvent {
  final String requestId;
  final String? note;

  const ApproveJoinRequestEvent(this.requestId, {this.note});

  @override
  List<Object?> get props => [requestId, note];
}

class RejectJoinRequestEvent extends JoinRequestEvent {
  final String requestId;
  final String? note;

  const RejectJoinRequestEvent(this.requestId, {this.note});

  @override
  List<Object?> get props => [requestId, note];
}

class CancelJoinRequestEvent extends JoinRequestEvent {
  final String requestId;

  const CancelJoinRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class LoadGroupJoinRequestsEvent extends JoinRequestEvent {
  final String groupId;

  const LoadGroupJoinRequestsEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LoadMyJoinRequestsEvent extends JoinRequestEvent {
  const LoadMyJoinRequestsEvent();
}

class LoadPendingCountEvent extends JoinRequestEvent {
  final String groupId;

  const LoadPendingCountEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class GenerateShareLinkEvent extends JoinRequestEvent {
  final String groupId;

  const GenerateShareLinkEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}
