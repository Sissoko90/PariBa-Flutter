import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/group/create_group_usecase.dart';
import '../../../domain/usecases/group/get_groups_usecase.dart';
import '../../../domain/repositories/group_repository.dart';
import 'group_event.dart';
import 'group_state.dart';
import '../../../data/mappers/tontine_group_mapper.dart';

/// Group BLoC
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GetGroupsUseCase getGroupsUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final GroupRepository groupRepository;

  GroupBloc({
    required this.getGroupsUseCase,
    required this.createGroupUseCase,
    required this.groupRepository,
  }) : super(const GroupInitial()) {
    on<LoadGroupsEvent>(_onLoadGroups);
    on<CreateGroupEvent>(_onCreateGroup);
    on<LoadGroupDetailsEvent>(_onLoadGroupDetails);
    on<DeleteGroupEvent>(_onDeleteGroup);
    on<LeaveGroupEvent>(_onLeaveGroup);
  }

  /// Handle Load Groups
  Future<void> _onLoadGroups(
    LoadGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading());

    final result = await getGroupsUseCase();

    result.fold((failure) => emit(GroupError(failure.message)), (groups) {
      final models = TontineGroupMapper.toModelList(groups);
      emit(GroupsLoaded(models));
    });
  }

  /// Handle Create Group
  Future<void> _onCreateGroup(
    CreateGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    print('🔵 GroupBloc - Début création groupe: ${event.nom}');
    emit(const GroupLoading());

    final result = await createGroupUseCase(
      nom: event.nom,
      description: event.description,
      montant: event.montant,
      frequency: event.frequency,
      rotationMode: event.rotationMode,
      totalTours: event.totalTours,
      startDate: event.startDate,
      latePenaltyAmount: event.latePenaltyAmount,
      graceDays: event.graceDays,
    );

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      print('❌ GroupBloc - Création échouée: ${failure.message}');
      emit(GroupError(failure.message));
    } else {
      final group = result.fold((l) => null, (r) => r)!;
      print('✅ GroupBloc - Groupe créé: ${group.nom}');
      print('🚀 GroupBloc - Émission état GroupCreated');

      // CONVERTIR EN MODÈLE
      final groupModel = TontineGroupMapper.toModel(group);
      emit(GroupCreated(groupModel)); // <-- CORRECTION ICI

      print('✅ GroupBloc - État GroupCreated émis');
    }
  }

  /// Handle Load Group Details
  Future<void> _onLoadGroupDetails(
    LoadGroupDetailsEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading());

    final result = await groupRepository.getGroupById(event.groupId);

    result.fold((failure) => emit(GroupError(failure.message)), (group) {
      // CONVERTIR EN MODÈLE
      final groupModel = TontineGroupMapper.toModel(group);
      emit(GroupDetailsLoaded(groupModel)); // <-- CORRECTION ICI
    });
  }

  /// Handle Delete Group
  Future<void> _onDeleteGroup(
    DeleteGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    print('🔵 GroupBloc - Suppression groupe: ${event.groupId}');
    emit(const GroupLoading());

    final result = await groupRepository.deleteGroup(event.groupId);

    result.fold(
      (failure) {
        print('❌ GroupBloc - Suppression échouée: ${failure.message}');
        emit(GroupError(failure.message));
      },
      (_) {
        print('✅ GroupBloc - Groupe supprimé');
        emit(const GroupDeleted());
      },
    );
  }

  /// Handle Leave Group
  Future<void> _onLeaveGroup(
    LeaveGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    print('🔵 GroupBloc - Quitter groupe: ${event.groupId}');
    emit(const GroupLoading());

    final result = await groupRepository.leaveGroup(event.groupId);

    result.fold(
      (failure) {
        print('❌ GroupBloc - Échec: ${failure.message}');
        emit(GroupError(failure.message));
      },
      (_) {
        print('✅ GroupBloc - Groupe quitté');
        emit(const GroupLeft());
      },
    );
  }
}
