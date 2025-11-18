import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/remote/membership_remote_datasource.dart';
import 'membership_event.dart';
import 'membership_state.dart';

/// Membership BLoC
class MembershipBloc extends Bloc<MembershipEvent, MembershipState> {
  final MembershipRemoteDataSource membershipDataSource;

  MembershipBloc({
    required this.membershipDataSource,
  }) : super(const MembershipInitial()) {
    on<LoadGroupMembersEvent>(_onLoadGroupMembers);
    on<LoadMyMembershipsEvent>(_onLoadMyMemberships);
    on<UpdateMemberRoleEvent>(_onUpdateMemberRole);
    on<RemoveMemberEvent>(_onRemoveMember);
  }

  /// Load group members
  Future<void> _onLoadGroupMembers(
    LoadGroupMembersEvent event,
    Emitter<MembershipState> emit,
  ) async {
    print('🔵 MembershipBloc - Chargement membres du groupe: ${event.groupId}');
    emit(const MembershipLoading());

    try {
      final members = await membershipDataSource.getGroupMembers(event.groupId);
      print('✅ MembershipBloc - ${members.length} membres chargés');
      emit(MembersLoaded(members));
    } catch (e) {
      print('❌ MembershipBloc - Erreur: $e');
      emit(MembershipError(e.toString()));
    }
  }

  /// Load my memberships
  Future<void> _onLoadMyMemberships(
    LoadMyMembershipsEvent event,
    Emitter<MembershipState> emit,
  ) async {
    print('🔵 MembershipBloc - Chargement de mes appartenances');
    emit(const MembershipLoading());

    try {
      final memberships = await membershipDataSource.getMyMemberships();
      print('✅ MembershipBloc - ${memberships.length} appartenances chargées');
      emit(MyMembershipsLoaded(memberships));
    } catch (e) {
      print('❌ MembershipBloc - Erreur: $e');
      emit(MembershipError(e.toString()));
    }
  }

  /// Update member role
  Future<void> _onUpdateMemberRole(
    UpdateMemberRoleEvent event,
    Emitter<MembershipState> emit,
  ) async {
    print('🔵 MembershipBloc - Mise à jour rôle membre');
    emit(const MembershipLoading());

    try {
      await membershipDataSource.updateMemberRole(
        event.groupId,
        event.personId,
        event.newRole,
      );
      print('✅ MembershipBloc - Rôle mis à jour');
      emit(const MemberRoleUpdated());
      
      // Recharger les membres
      add(LoadGroupMembersEvent(event.groupId));
    } catch (e) {
      print('❌ MembershipBloc - Erreur: $e');
      emit(MembershipError(e.toString()));
    }
  }

  /// Remove member
  Future<void> _onRemoveMember(
    RemoveMemberEvent event,
    Emitter<MembershipState> emit,
  ) async {
    print('🔵 MembershipBloc - Suppression membre');
    emit(const MembershipLoading());

    try {
      await membershipDataSource.removeMember(event.groupId, event.personId);
      print('✅ MembershipBloc - Membre supprimé');
      emit(const MemberRemoved());
      
      // Recharger les membres
      add(LoadGroupMembersEvent(event.groupId));
    } catch (e) {
      print('❌ MembershipBloc - Erreur: $e');
      emit(MembershipError(e.toString()));
    }
  }
}
