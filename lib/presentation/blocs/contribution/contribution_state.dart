import 'package:equatable/equatable.dart';
import '../../../domain/entities/contribution.dart';

abstract class ContributionState extends Equatable {
  const ContributionState();

  @override
  List<Object?> get props => [];
}

class ContributionInitial extends ContributionState {}

class ContributionLoading extends ContributionState {}

class ContributionsLoaded extends ContributionState {
  final List<Contribution> contributions;

  const ContributionsLoaded(this.contributions);

  @override
  List<Object?> get props => [contributions];
}

class ContributionError extends ContributionState {
  final String message;

  const ContributionError(this.message);

  @override
  List<Object?> get props => [message];
}
