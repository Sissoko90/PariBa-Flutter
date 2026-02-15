import 'package:equatable/equatable.dart';
import '../../../data/models/tour_model.dart';

abstract class TourState extends Equatable {
  const TourState();

  @override
  List<Object?> get props => [];
}

class TourInitial extends TourState {}

class TourLoading extends TourState {}

class TourLoaded extends TourState {
  final TourModel tour;

  const TourLoaded(this.tour);

  @override
  List<Object?> get props => [tour];
}

class ToursLoaded extends TourState {
  final List<TourModel> tours;

  const ToursLoaded(this.tours);

  @override
  List<Object?> get props => [tours];
}

class TourError extends TourState {
  final String message;

  const TourError(this.message);

  @override
  List<Object?> get props => [message];
}

class TourEmpty extends TourState {
  final String message;

  const TourEmpty(this.message);

  @override
  List<Object?> get props => [message];
}
