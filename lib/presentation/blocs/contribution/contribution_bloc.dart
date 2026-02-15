import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/contribution_repository.dart';
import 'contribution_event.dart';
import 'contribution_state.dart';

class ContributionBloc extends Bloc<ContributionEvent, ContributionState> {
  final ContributionRepository contributionRepository;

  ContributionBloc({required this.contributionRepository})
      : super(ContributionInitial()) {
    on<LoadGroupContributionsEvent>(_onLoadGroupContributions);
    on<LoadTourContributionsEvent>(_onLoadTourContributions);
    on<LoadMemberContributionsEvent>(_onLoadMemberContributions);
  }

  Future<void> _onLoadGroupContributions(
    LoadGroupContributionsEvent event,
    Emitter<ContributionState> emit,
  ) async {
    emit(ContributionLoading());

    try {
      final contributions =
          await contributionRepository.getContributionsByGroup(event.groupId);
      emit(ContributionsLoaded(contributions));
    } catch (e) {
      emit(ContributionError('Erreur de chargement: $e'));
    }
  }

  Future<void> _onLoadTourContributions(
    LoadTourContributionsEvent event,
    Emitter<ContributionState> emit,
  ) async {
    emit(ContributionLoading());

    try {
      final contributions =
          await contributionRepository.getContributionsByTour(event.tourId);
      emit(ContributionsLoaded(contributions));
    } catch (e) {
      emit(ContributionError('Erreur de chargement: $e'));
    }
  }

  Future<void> _onLoadMemberContributions(
    LoadMemberContributionsEvent event,
    Emitter<ContributionState> emit,
  ) async {
    emit(ContributionLoading());

    try {
      final contributions =
          await contributionRepository.getContributionsByMember(event.memberId);
      emit(ContributionsLoaded(contributions));
    } catch (e) {
      emit(ContributionError('Erreur de chargement: $e'));
    }
  }
}
