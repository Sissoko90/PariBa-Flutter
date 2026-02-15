import 'package:equatable/equatable.dart';
import '../../../data/models/group_share_link_model.dart';
import '../../../domain/entities/join_request.dart';

abstract class JoinRequestState extends Equatable {
  const JoinRequestState();

  @override
  List<Object?> get props => [];
}

class JoinRequestInitial extends JoinRequestState {}

class JoinRequestLoading extends JoinRequestState {}

class JoinRequestCreated extends JoinRequestState {
  final JoinRequest joinRequest;

  const JoinRequestCreated(this.joinRequest);

  @override
  List<Object?> get props => [joinRequest];
}

class JoinRequestReviewed extends JoinRequestState {
  final JoinRequest joinRequest;

  const JoinRequestReviewed(this.joinRequest);

  @override
  List<Object?> get props => [joinRequest];
}

class JoinRequestCancelled extends JoinRequestState {}

class JoinRequestsLoaded extends JoinRequestState {
  final List<JoinRequest> joinRequests;

  const JoinRequestsLoaded(this.joinRequests);

  @override
  List<Object?> get props => [joinRequests];
}

class PendingCountLoaded extends JoinRequestState {
  final int count;

  const PendingCountLoaded(this.count);

  @override
  List<Object?> get props => [count];
}

class ShareLinkGenerated extends JoinRequestState {
  final GroupShareLinkModel shareLink;

  const ShareLinkGenerated(this.shareLink);

  @override
  List<Object?> get props => [shareLink];
}

class JoinRequestError extends JoinRequestState {
  final String message;

  const JoinRequestError(this.message);

  @override
  List<Object?> get props => [message];
}
