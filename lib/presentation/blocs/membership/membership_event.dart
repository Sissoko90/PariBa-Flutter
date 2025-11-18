import 'package:equatable/equatable.dart';

/// Membership Events
abstract class MembershipEvent extends Equatable {
  const MembershipEvent();

  @override
  List<Object?> get props => [];
}

/// Load group members
class LoadGroupMembersEvent extends MembershipEvent {
  final String groupId;

  const LoadGroupMembersEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Load my memberships
class LoadMyMembershipsEvent extends MembershipEvent {
  const LoadMyMembershipsEvent();
}

/// Update member role
class UpdateMemberRoleEvent extends MembershipEvent {
  final String groupId;
  final String personId;
  final String newRole;

  const UpdateMemberRoleEvent({
    required this.groupId,
    required this.personId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [groupId, personId, newRole];
}

/// Remove member
class RemoveMemberEvent extends MembershipEvent {
  final String groupId;
  final String personId;

  const RemoveMemberEvent({
    required this.groupId,
    required this.personId,
  });

  @override
  List<Object?> get props => [groupId, personId];
}
