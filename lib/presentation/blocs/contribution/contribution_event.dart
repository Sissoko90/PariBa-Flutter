import 'package:equatable/equatable.dart';

abstract class ContributionEvent extends Equatable {
  const ContributionEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupContributionsEvent extends ContributionEvent {
  final String groupId;

  const LoadGroupContributionsEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LoadTourContributionsEvent extends ContributionEvent {
  final String tourId;

  const LoadTourContributionsEvent(this.tourId);

  @override
  List<Object?> get props => [tourId];
}

class LoadMemberContributionsEvent extends ContributionEvent {
  final String memberId;

  const LoadMemberContributionsEvent(this.memberId);

  @override
  List<Object?> get props => [memberId];
}
