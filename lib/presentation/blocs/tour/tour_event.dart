import 'package:equatable/equatable.dart';

abstract class TourEvent extends Equatable {
  const TourEvent();

  @override
  List<Object?> get props => [];
}

class LoadNextTourEvent extends TourEvent {
  final String groupId;

  const LoadNextTourEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LoadCurrentTourEvent extends TourEvent {
  final String groupId;

  const LoadCurrentTourEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LoadGroupToursEvent extends TourEvent {
  final String groupId;

  const LoadGroupToursEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class GenerateToursEvent extends TourEvent {
  final String groupId;
  final bool shuffle;
  final List<String>? customBeneficiaryOrder;

  const GenerateToursEvent({
    required this.groupId,
    this.shuffle = false,
    this.customBeneficiaryOrder,
  });

  @override
  List<Object?> get props => [groupId, shuffle, customBeneficiaryOrder];
}
