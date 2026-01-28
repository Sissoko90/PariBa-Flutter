import 'package:equatable/equatable.dart';
import '../../../data/models/tontine_group_model.dart';

/// Group States
abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class GroupInitial extends GroupState {
  const GroupInitial();
}

/// Loading State
class GroupLoading extends GroupState {
  const GroupLoading();
}

/// Groups Loaded State
class GroupsLoaded extends GroupState {
  final List<TontineGroupModel> groups;

  const GroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

/// Group Details Loaded State
class GroupDetailsLoaded extends GroupState {
  final TontineGroupModel group;

  const GroupDetailsLoaded(this.group);

  @override
  List<Object?> get props => [group];
}

/// Group Created State
class GroupCreated extends GroupState {
  final TontineGroupModel group;

  const GroupCreated(this.group);

  @override
  List<Object?> get props => [group];
}

/// Group Deleted State
class GroupDeleted extends GroupState {
  const GroupDeleted();
}

/// Group Left State
class GroupLeft extends GroupState {
  const GroupLeft();
}

/// Group Error State
class GroupError extends GroupState {
  final String message;

  const GroupError(this.message);

  @override
  List<Object?> get props => [message];
}
