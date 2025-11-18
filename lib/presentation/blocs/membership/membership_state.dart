import 'package:equatable/equatable.dart';

/// Membership States
abstract class MembershipState extends Equatable {
  const MembershipState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MembershipInitial extends MembershipState {
  const MembershipInitial();
}

/// Loading state
class MembershipLoading extends MembershipState {
  const MembershipLoading();
}

/// Members loaded
class MembersLoaded extends MembershipState {
  final List<Map<String, dynamic>> members;

  const MembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

/// My memberships loaded
class MyMembershipsLoaded extends MembershipState {
  final List<Map<String, dynamic>> memberships;

  const MyMembershipsLoaded(this.memberships);

  @override
  List<Object?> get props => [memberships];
}

/// Member role updated
class MemberRoleUpdated extends MembershipState {
  const MemberRoleUpdated();
}

/// Member removed
class MemberRemoved extends MembershipState {
  const MemberRemoved();
}

/// Error state
class MembershipError extends MembershipState {
  final String message;

  const MembershipError(this.message);

  @override
  List<Object?> get props => [message];
}
