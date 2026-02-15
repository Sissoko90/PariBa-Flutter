import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/remote/tour_remote_datasource.dart';
import '../../../data/models/tour_model.dart';
import 'tour_event.dart';
import 'tour_state.dart';

class TourBloc extends Bloc<TourEvent, TourState> {
  final TourRemoteDataSource tourRemoteDataSource;

  TourBloc({required this.tourRemoteDataSource}) : super(TourInitial()) {
    on<LoadNextTourEvent>(_onLoadNextTour);
    on<LoadCurrentTourEvent>(_onLoadCurrentTour);
    on<LoadGroupToursEvent>(_onLoadGroupTours);
    on<GenerateToursEvent>(_onGenerateTours);
  }

  Future<void> _onLoadNextTour(
    LoadNextTourEvent event,
    Emitter<TourState> emit,
  ) async {
    emit(TourLoading());
    try {
      final tourData = await tourRemoteDataSource.getNextTour(event.groupId);
      final tour = TourModel.fromJson(tourData);
      emit(TourLoaded(tour));
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('non trouvé')) {
        emit(const TourEmpty('Aucun prochain tour disponible'));
      } else {
        emit(TourError(e.toString()));
      }
    }
  }

  Future<void> _onLoadCurrentTour(
    LoadCurrentTourEvent event,
    Emitter<TourState> emit,
  ) async {
    emit(TourLoading());
    try {
      final tourData = await tourRemoteDataSource.getCurrentTour(event.groupId);
      final tour = TourModel.fromJson(tourData);
      emit(TourLoaded(tour));
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('non trouvé')) {
        emit(const TourEmpty('Aucun tour en cours'));
      } else {
        emit(TourError(e.toString()));
      }
    }
  }

  Future<void> _onLoadGroupTours(
    LoadGroupToursEvent event,
    Emitter<TourState> emit,
  ) async {
    emit(TourLoading());
    try {
      final toursData = await tourRemoteDataSource.getToursByGroup(
        event.groupId,
      );
      final tours = toursData.map((data) => TourModel.fromJson(data)).toList();
      emit(ToursLoaded(tours));
    } catch (e) {
      emit(TourError(e.toString()));
    }
  }

  Future<void> _onGenerateTours(
    GenerateToursEvent event,
    Emitter<TourState> emit,
  ) async {
    emit(TourLoading());
    try {
      print(
        '🔵 TourBloc - Génération des tours pour le groupe: ${event.groupId}',
      );
      final toursData = await tourRemoteDataSource.generateTours(
        event.groupId,
        event.shuffle,
        customBeneficiaryOrder: event.customBeneficiaryOrder,
      );
      final tours = toursData.map((data) => TourModel.fromJson(data)).toList();
      print('✅ TourBloc - ${tours.length} tours générés avec succès');
      emit(ToursLoaded(tours));
    } catch (e) {
      print('❌ TourBloc - Erreur génération tours: $e');
      emit(TourError(e.toString()));
    }
  }
}
